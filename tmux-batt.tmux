#!/usr/bin/env bash

set -eu

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly RUNTIME_SCRIPT="$CURRENT_DIR/scripts/tmux-batt.sh"
readonly SEGMENT_COMMAND="#($RUNTIME_SCRIPT)"

status_right="$(tmux show-option -gqv status-right)"

case "$status_right" in
  *"$SEGMENT_COMMAND"*)
    exit 0
    ;;
esac

if [ -n "$status_right" ]; then
  tmux set-option -gq status-right "$status_right $SEGMENT_COMMAND"
  exit 0
fi

tmux set-option -gq status-right "$SEGMENT_COMMAND"
