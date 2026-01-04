#!/usr/bin/env bash

# Source dependencies
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/stack.sh"

# Clear the history stack
clear_history() {
    acquire_lock || exit 1

    local stack_file
    stack_file=$(get_stack_file)

    # Initialize with position 0 and empty stack
    echo "0" > "$stack_file"

    # Reset indicator
    tmux set-option -g @history-stack-indicator ""

    display_message "History cleared"
    debug_message "History stack cleared"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    clear_history "$@"
fi
