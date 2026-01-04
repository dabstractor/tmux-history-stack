#!/usr/bin/env bash

# tmux-history-stack configuration variables
# All user-configurable options prefixed with @history-stack-

# Default values
DEFAULT_MAX_SIZE="20"
DEFAULT_INDICATOR_BACK=""
DEFAULT_INDICATOR_FORWARD=""
DEFAULT_INDICATOR_SEPARATOR=" "
DEFAULT_AUTO_PUSH="on"
DEFAULT_DEBUG="off"

# Option names (for tmux show-option -gqv)
MAX_SIZE_OPTION="@history-stack-max-size"
INDICATOR_BACK_OPTION="@history-stack-indicator-back"
INDICATOR_FORWARD_OPTION="@history-stack-indicator-forward"
INDICATOR_SEPARATOR_OPTION="@history-stack-indicator-separator"
AUTO_PUSH_OPTION="@history-stack-auto-push"
DEBUG_OPTION="@history-stack-debug"
