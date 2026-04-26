# Vision

`tmux-batt` is a minimal tmux plugin that shows laptop battery status in the status line.

## Goal

Expose battery state at a glance, with zero visual noise and no extra interaction.

## Output

Display:

- battery icon
- battery percentage
- current power draw in watts, when available

Examples:

- `B 40% 7W`
- `B 100%`
- `B 58% 25W`

`B` stands for the battery icon placeholder. The final icon should feel as clean and readable as the Waybar battery icon used in Omarchy.

## States

- Charging: use a charging battery icon.
- Discharging: use the regular battery icon.
- If wattage is unavailable, omit it.

## Color Rules

- `>= 50%`: light pastel green
- `20% to 49%`: yellow
- `< 20%`: red

## Platforms

- Linux
- macOS

## Repository UX

The project README should be written as a clean landing page for a public GitHub repository.

It must include:

- a short project overview
- a visual example or preview, if available
- install instructions for the plugin
- concise usage notes

## Reference

The visual tone should align with [`tmux-whisper`](https://github.com/martynasjocius/tmux-whisper): compact, calm, and status-line native.
