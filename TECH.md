# Tech

## Stack

- Bash

## Form

Keep the battery rendering logic in a single Bash runtime script.

TPM integration may use a minimal tmux wrapper file that only wires tmux loading to that script surface.

The plugin must support both usage modes:

- run the Bash script directly
- install through tmux plugin manager

## Compatibility

- Linux
- macOS

## Battery Data

The implementation contract should assume platform-specific battery reads behind one script surface.

- On Linux, read battery state from `/sys/class/power_supply` and prefer standard battery fields such as `capacity`, `status`, `power_now`, `current_now`, and `voltage_now` when present.
- On macOS, read battery state from system commands already present on a default install. `pmset -g batt` should be the primary source for charge and charging state. `ioreg` can be used as a fallback source for fields that `pmset` does not expose directly.
- Wattage should be shown only when it can be derived from available battery data. On Linux, prefer `power_now` directly and otherwise derive watts from `current_now * voltage_now`. On macOS, only expose wattage if the required values are available from `ioreg`.
- The script should not depend on third-party packages such as `acpi`.

## Fallback Behavior

- If battery percentage is available but wattage is not, show percentage and state without wattage.
- If charging state is unavailable, omit it rather than guessing.
- If no supported battery data source is available, return a simple placeholder output instead of failing or printing stack-like shell errors.
- Direct-run and tmux plugin usage should share the same fallback behavior.

## Reference

Implementation style reference: [`tmux-whisper`](https://github.com/martynasjocius/tmux-whisper).
