#!/usr/bin/env bash

set -u

readonly PLACEHOLDER_OUTPUT="B --"
readonly DEFAULT_POWER_SUPPLY_ROOT="/sys/class/power_supply"
readonly DEFAULT_PMSET_CMD="pmset -g batt"
readonly INSTALL_FLAG="--install"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_PATH="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_segment() {
  local segment_command
  local status_right

  segment_command="#($SCRIPT_PATH)"
  status_right="$(tmux show-option -gqv status-right)"

  case "$status_right" in
    *"$segment_command"*)
      return 0
      ;;
  esac

  if [ -n "$status_right" ]; then
    tmux set-option -gq status-right "$status_right $segment_command"
    return 0
  fi

  tmux set-option -gq status-right "$segment_command"
}

is_non_negative_integer() {
  case "${1-}" in
    ''|*[!0-9]*)
      return 1
      ;;
  esac

  return 0
}

trim_whitespace() {
  local value="${1-}"

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  printf '%s' "$value"
}

read_first_line() {
  local file_path="$1"

  if [ ! -r "$file_path" ]; then
    return 1
  fi

  local line

  IFS= read -r line <"$file_path" || true
  trim_whitespace "$line"
}

round_micro_watts_to_watts() {
  local micro_watts="$1"

  awk -v value="$micro_watts" 'BEGIN { printf "%d", (value / 1000000) + 0.5 }'
}

round_micro_amp_micro_volt_to_watts() {
  local micro_amps="$1"
  local micro_volts="$2"

  awk -v current="$micro_amps" -v voltage="$micro_volts" 'BEGIN {
    printf "%d", ((current * voltage) / 1000000000000) + 0.5
  }'
}

print_segment() {
  local icon="$1"
  local percent="$2"
  local watts="${3-}"

  if [ -n "$watts" ]; then
    printf '%s %s%% %sW\n' "$icon" "$percent" "$watts"
    return
  fi

  printf '%s %s%%\n' "$icon" "$percent"
}

find_linux_battery_dir() {
  local power_supply_root="${TMUX_BATT_POWER_SUPPLY_ROOT:-$DEFAULT_POWER_SUPPLY_ROOT}"
  local candidate

  shopt -s nullglob

  for candidate in "$power_supply_root"/BAT* "$power_supply_root"/battery*; do
    if [ -d "$candidate" ]; then
      printf '%s\n' "$candidate"
      shopt -u nullglob
      return 0
    fi
  done

  shopt -u nullglob
  return 1
}

linux_segment() {
  local battery_dir

  battery_dir="$(find_linux_battery_dir)" || return 1

  local capacity
  local status
  local power_now
  local current_now
  local voltage_now
  local icon="🔋"
  local watts=""

  capacity="$(read_first_line "$battery_dir/capacity")" || return 1

  if ! is_non_negative_integer "$capacity"; then
    return 1
  fi

  status="$(read_first_line "$battery_dir/status" 2>/dev/null || true)"

  case "$status" in
    Charging)
      icon="⚡"
      ;;
  esac

  power_now="$(read_first_line "$battery_dir/power_now" 2>/dev/null || true)"
  current_now="$(read_first_line "$battery_dir/current_now" 2>/dev/null || true)"
  voltage_now="$(read_first_line "$battery_dir/voltage_now" 2>/dev/null || true)"

  if [ -n "$power_now" ] && is_non_negative_integer "$power_now"; then
    watts="$(round_micro_watts_to_watts "$power_now")"
  elif [ -n "$current_now" ] && [ -n "$voltage_now" ] \
    && is_non_negative_integer "$current_now" \
    && is_non_negative_integer "$voltage_now"; then
    watts="$(round_micro_amp_micro_volt_to_watts "$current_now" "$voltage_now")"
  fi

  print_segment "$icon" "$capacity" "$watts"
}

macos_segment() {
  local pmset_cmd="${TMUX_BATT_PMSET_CMD:-$DEFAULT_PMSET_CMD}"

  if [ "$pmset_cmd" = "$DEFAULT_PMSET_CMD" ] && ! command_exists pmset; then
    return 1
  fi

  local batt_output
  local percent
  local status
  local icon="🔋"

  batt_output="$($pmset_cmd 2>/dev/null)" || return 1
  percent="$(printf '%s\n' "$batt_output" | grep -Eo '[0-9]+%' | head -n 1 | tr -d '%')"
  status="$(printf '%s\n' "$batt_output" | sed -n '2s/^[^;]*; *\([^;]*\).*/\1/p')"
  status="$(trim_whitespace "$status")"

  if ! is_non_negative_integer "$percent"; then
    return 1
  fi

  case "$status" in
    charging*)
      icon="⚡"
      ;;
  esac

  print_segment "$icon" "$percent"
}

main() {
  if [ "${1-}" = "$INSTALL_FLAG" ]; then
    install_segment
    return 0
  fi

  local platform

  platform="${TMUX_BATT_PLATFORM:-$(uname -s 2>/dev/null || printf 'unknown')}"

  case "$platform" in
    Linux)
      linux_segment && return 0
      ;;
    Darwin)
      macos_segment && return 0
      ;;
  esac

  printf '%s\n' "$PLACEHOLDER_OUTPUT"
}

main "$@"
