#!/usr/bin/env bash

# Source dependencies
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/stack.sh"

# Main push function
push_location() {
    local mode="${1:-manual}"  # 'auto' or 'manual'
    local location="${2:-}"     # Optional: specific location to push

    # Check if auto-push is enabled
    local auto_push
    auto_push=$(get_tmux_option "$AUTO_PUSH_OPTION" "$DEFAULT_AUTO_PUSH")
    if [[ "$mode" == "auto" && "$auto_push" != "on" ]]; then
        exit 0
    fi

    # Get current location if not provided
    if [[ -z "$location" ]]; then
        location=$(get_current_location)
    fi

    acquire_lock || exit 1
    read_stack

    # In auto mode, skip if same as most recent entry
    if [[ "$mode" == "auto" && ${#STACK[@]} -gt 0 ]]; then
        local last_entry="${STACK[0]}"
        if [[ "$location" == "$last_entry" ]]; then
            debug_message "Skipping duplicate location: $location"
            exit 0
        fi
    fi

    # If we're not at position 0, we need to truncate the stack
    # This removes "forward" history when we navigate to a new location
    if [[ $CURRENT_INDEX -gt 0 && ${#STACK[@]} -gt 0 ]]; then
        STACK=("${STACK[@]:0:$CURRENT_INDEX}")
    fi

    # Add new location to front of stack
    STACK=("$location" "${STACK[@]}")
    CURRENT_INDEX=0

    # Trim to max size
    local max_size
    max_size=$(get_max_size)
    if [[ ${#STACK[@]} -gt $max_size ]]; then
        STACK=("${STACK[@]:0:$max_size}")
    fi

    write_stack

    # Update statusline indicator
    "$CURRENT_DIR/status.sh"

    debug_message "Pushed location (mode=$mode): $location"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    push_location "$@"
fi
