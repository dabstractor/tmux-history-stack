#!/usr/bin/env bash

# Source dependencies
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/stack.sh"

# Navigate backward in history
navigate_back() {
    acquire_lock || exit 1
    read_stack

    local max_index
    max_index=$((${#STACK[@]} - 1))

    # Check if we can go back
    if [[ $max_index -lt 0 ]]; then
        display_message "History is empty"
        exit 1
    fi

    if [[ $CURRENT_INDEX -ge $max_index ]]; then
        display_message "Already at oldest history item"
        exit 1
    fi

    # Try to navigate back
    local next_index=$((CURRENT_INDEX + 1))
    local target="${STACK[$next_index]}"

    # Validate target location exists
    while ! location_exists "$target"; do
        debug_message "Location no longer exists, removing: $target"
        remove_stack_entry "$next_index"
        max_index=$((${#STACK[@]} - 1))

        # Check if we still can go back
        if [[ $max_index -lt 0 ]]; then
            write_stack
            display_message "History is empty"
            exit 1
        fi

        if [[ $CURRENT_INDEX -ge $max_index ]]; then
            write_stack
            display_message "Already at oldest history item"
            exit 1
        fi

        target="${STACK[$next_index]}"
    done

    # Navigate to target
    CURRENT_INDEX=$next_index
    write_stack
    navigate_to_location "$target"

    # Update statusline indicator
    "$CURRENT_DIR/status.sh"

    debug_message "Navigated back to index $CURRENT_INDEX: $target"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    navigate_back "$@"
fi
