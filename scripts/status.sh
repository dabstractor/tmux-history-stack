#!/usr/bin/env bash

# Source dependencies
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/stack.sh"

# Update the statusline indicator
update_indicator() {
    acquire_lock || exit 1
    read_stack

    local indicator=""
    local max_index
    max_index=$((${#STACK[@]} - 1))

    # Get configured symbols
    local back_symbol forward_symbol separator
    back_symbol=$(get_tmux_option "$INDICATOR_BACK_OPTION" "$DEFAULT_INDICATOR_BACK")
    forward_symbol=$(get_tmux_option "$INDICATOR_FORWARD_OPTION" "$DEFAULT_INDICATOR_FORWARD")
    separator=$(get_tmux_option "$INDICATOR_SEPARATOR_OPTION" "$DEFAULT_INDICATOR_SEPARATOR")

    # Check if can go back
    if [[ $CURRENT_INDEX -lt $max_index && $max_index -ge 0 ]]; then
        if [[ -n "$back_symbol" ]]; then
            indicator="${back_symbol}${separator}"
        else
            indicator="◀${separator}"
        fi
    fi

    # Check if can go forward
    if [[ $CURRENT_INDEX -gt 0 ]]; then
        if [[ -n "$forward_symbol" ]]; then
            indicator="${indicator}${forward_symbol}"
        else
            indicator="${indicator}▶"
        fi
    fi

    # Trim trailing separator
    indicator="${indicator%$separator}"

    # Store in tmux option for statusline access
    tmux set-option -g @history-stack-indicator "$indicator"

    debug_message "Indicator updated: '$indicator' (index=$CURRENT_INDEX, max=$max_index)"
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    update_indicator "$@"
fi
