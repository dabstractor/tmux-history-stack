# tmux-history-stack

Unified history stack for navigating tmux sessions and windows. Tracks navigation and provides back/forward commands.

## Installation

Add to your TPM plugin list in `tmux.conf`:

```bash
set -g @plugin 'dabstractor/tmux-history-stack'
```

Press `prefix + I` to install.

## Quick Start

Add key bindings in `tmux.conf`:

```bash
# Navigate backward/forward in history
bind-key h run-shell '#{@history-stack-back}'
bind-key l run-shell '#{@history-stack-forward}'
```

Add the indicator to your statusline:

```bash
set -g status-right '#{?#{@history-stack-indicator},#{@history-stack-indicator} ,}%H:%M %Y-%m-%d'
```

Reload tmux with `tmux source-file ~/.tmux.conf`.

## Statusline

```
work:editor                    ◀                     14:32 2026-01-04
```

The `◀` appears when you have history to go back to. `▶` appears when you've gone back and can go forward. `◀ ▶` appears when both are available. Nothing appears when you're at the newest position.

## Commands

| Command | Description |
|---------|-------------|
| `#{@history-stack-back}` | Navigate backward in history |
| `#{@history-stack-forward}` | Navigate forward in history |
| `#{@history-stack-push}` | Push current location to history |
| `#{@history-stack-clear}` | Clear history stack |

## Configuration

| Option | Default | Description |
|--------|---------|-------------|
| `@history-stack-max-size` | `20` | Maximum stack depth |
| `@history-stack-indicator-back` | `◀` | Symbol for "can go back" |
| `@history-stack-indicator-forward` | `▶` | Symbol for "can go forward" |
| `@history-stack-auto-push` | `on` | Enable automatic tracking |

## How It Works

- Stores history in `/tmp/tmux-history-stack-$USER-$SERVER_PID.txt`
- Location format: `${server_pid}:${session_id}:${window_id}`
- Uses tmux hooks `client-session-changed` and `after-select-window` for automatic tracking
- Invalid sessions/windows are removed from history
- Stops at boundaries (no wrapping)

## License

MIT
