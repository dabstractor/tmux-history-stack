#!/usr/bin/env bash

# Source helpers
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

# Global variables for stack state
STACK=()
CURRENT_INDEX=0

# File locking to prevent race conditions
acquire_lock() {
    local lock_file="/tmp/tmux-history-stack-$USER.lock"
    local timeout=5
    local elapsed=0

    while [[ $elapsed -lt $timeout ]]; do
        if mkdir "$lock_file" 2>/dev/null; then
            trap "rmdir '$lock_file' 2>/dev/null" EXIT
            return 0
        fi
        sleep 0.1
        elapsed=$((elapsed + 1))
    done

    debug_message "Failed to acquire lock after ${timeout}s"
    return 1
}

# Read stack from file into global variables
read_stack() {
    local stack_file
    stack_file=$(get_stack_file)

    if [[ -f "$stack_file" ]]; then
        # Read first line as current index, rest as stack
        local first_line
        first_line=$(head -n 1 "$stack_file")
        if [[ "$first_line" =~ ^[0-9]+$ ]]; then
            CURRENT_INDEX="$first_line"
        else
            CURRENT_INDEX=0
        fi

        # Read stack entries (skip first line)
        mapfile -t STACK < <(tail -n +2 "$stack_file")
    else
        CURRENT_INDEX=0
        STACK=()
    fi

    debug_message "Read stack: index=$CURRENT_INDEX, size=${#STACK[@]}"
}

# Write stack from global variables to file
write_stack() {
    local stack_file
    stack_file=$(get_stack_file)

    {
        echo "$CURRENT_INDEX"
        printf '%s\n' "${STACK[@]}"
    } > "$stack_file"

    debug_message "Wrote stack: index=$CURRENT_INDEX, size=${#STACK[@]}"
}

# Get max stack size from config
get_max_size() {
    get_tmux_option "$MAX_SIZE_OPTION" "$DEFAULT_MAX_SIZE"
}

# Remove entry at index and compact stack
remove_stack_entry() {
    local index="$1"
    local new_stack=()
    local i=0

    for entry in "${STACK[@]}"; do
        if [[ $i -ne $index ]]; then
            new_stack+=("$entry")
        fi
        ((i++))
    done

    STACK=("${new_stack[@]}")

    # Adjust current index if needed
    if [[ $CURRENT_INDEX -gt $index ]]; then
        CURRENT_INDEX=$((CURRENT_INDEX - 1))
    elif [[ $CURRENT_INDEX -ge ${#new_stack[@]} ]]; then
        CURRENT_INDEX=$((${#new_stack[@]} - 1))
    fi
}
