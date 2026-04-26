# tmux-batt

Minimal tmux battery status for the status line.

`tmux-batt` is a small tmux plugin that shows laptop battery state at a glance with as little visual noise as possible. It is designed to feel native to a tmux status line rather than like a separate dashboard.

## Target Output

The plugin should render a compact battery segment with:

- a battery icon
- battery percentage
- current power draw in watts, when available

Example outputs:

- `B 40% 7W`
- `B 100%`
- `B 58% 25W`

`B` is a placeholder for the final battery icon. Charging should use a charging icon, discharging should use the regular battery icon, and wattage should be omitted when the platform does not expose it.

## Platforms

First release target:

- Linux
- macOS

## What Good Looks Like

A good `tmux-batt` status segment is:

- readable in one glance
- compact enough to fit naturally into an existing tmux status line
- quiet by default, with no extra labels or decoration
- clear about charging vs. discharging state
- color-coded by battery level

Battery level colors:

- `>= 50%`: light pastel green
- `20% to 49%`: yellow
- `< 20%`: red

## Non-Goals For v1

This first release does not try to be:

- a full power management tool
- an interactive tmux widget
- a cross-desktop battery dashboard
- a plugin with heavy theming or deep configuration surface
