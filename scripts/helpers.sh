#!/usr/bin/env bash

# Source variables
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/variables.sh"

# Get tmux option with default fallback
get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value
    option_value=$(tmux show-option -gqv "$option")
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

# Display a temporary message
display_message() {
    local message="$1"
    local saved_display_time
    saved_display_time=$(get_tmux_option "display-time" "750")
    tmux set-option -gq display-time "2000"
    tmux display-message "$message"
    tmux set-option -gq display-time "$saved_display_time"
}

# Debug message (only shown when debug mode is on)
debug_message() {
    local debug_mode
    debug_mode=$(get_tmux_option "$DEBUG_OPTION" "$DEFAULT_DEBUG")
    if [[ "$debug_mode" == "on" ]]; then
        display_message "[DEBUG] $1"
    fi
}

# Get the stack file path for current server
get_stack_file() {
    local server_pid
    server_pid=$(tmux display -p "#{pid}")
    echo "/tmp/tmux-history-stack-$USER-$server_pid.txt"
}

# Get current location identifier
get_current_location() {
    local server_pid session_id window_id
    server_pid=$(tmux display -p "#{pid}")
    session_id=$(tmux display -p "#{session_id}")
    window_id=$(tmux display -p "#{window_id}")
    echo "\${$server_pid}:${session_id}:${window_id}"
}

# Parse location into components
parse_location() {
    local location="$1"
    # Use sed to remove ${ and } from server pid
    local cleaned
    cleaned=$(echo "$location" | sed 's/\${\([^}]*\)}/\1/')
    IFS=':' read -r server_pid session_id window_id <<< "$cleaned"
    echo "$server_pid" "$session_id" "$window_id"
}

# Check if a location (session/window) still exists
location_exists() {
    local location="$1"
    local server_pid session_id window_id
    read -r server_pid session_id window_id <<< "$(parse_location "$location")"

    # Check if session exists
    if ! tmux list-sessions -F "#{session_id}" 2>/dev/null | grep -q "^${session_id}\$"; then
        return 1
    fi

    # Check if window exists in that session
    if ! tmux list-windows -t "$session_id" -F "#{window_id}" 2>/dev/null | grep -q "^${window_id}\$"; then
        return 1
    fi

    return 0
}

# Navigate to a location
navigate_to_location() {
    local location="$1"
    local server_pid session_id window_id
    read -r server_pid session_id window_id <<< "$(parse_location "$location")"

    # Switch to the session first, then select the window
    tmux switch-client -t "$session_id"
    tmux select-window -t "${session_id}:${window_id}"
}
