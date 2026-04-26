# tmux-batt

Minimal battery status for the tmux status line.

`tmux-batt` is a small tmux plugin for showing laptop battery state in a compact status segment. It is intended to fit naturally into an existing tmux status line without extra decoration.

## Output

The segment shows:

- a battery icon
- battery percentage
- current power draw in watts, when available

Example output:

- `B 40% 7W`
- `B 100%`
- `B 58% 25W`

`B` is a placeholder for the final battery icon. Charging and discharging use different icons. Wattage is omitted when the platform does not expose it.

## Platforms

- Linux
- macOS

## Usage

Run the script directly:

```bash
./scripts/tmux-batt.sh
```

Install with TPM by adding this plugin to your tmux plugin list:

```tmux
set -g @plugin 'martynasjocius/tmux-batt'
```

The TPM entry loads [tmux-batt.tmux](/home/mjoc/Projects/tmux-batt/tmux-batt.tmux), which appends the battery segment to `status-right`.
