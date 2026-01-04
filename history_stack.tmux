#!/usr/bin/env bash

# tmux-history-stack - TPM Plugin
# Unified history stack for navigating tmux sessions and windows

# Get script directory
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helpers
source "$CURRENT_DIR/scripts/helpers.sh"

# Initialize the plugin
main() {
    # Initialize indicator variable
    tmux set-option -g @history-stack-indicator ""

    # Register hooks for automatic tracking (background mode to prevent blocking)
    tmux set-hook -g client-session-changed "run-shell -b '$CURRENT_DIR/scripts/push.sh auto'"
    tmux set-hook -g after-select-window "run-shell -b '$CURRENT_DIR/scripts/push.sh auto'"

    # Push initial location on first load
    "$CURRENT_DIR/scripts/push.sh" manual
}

main
