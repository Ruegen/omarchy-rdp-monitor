# Remote Desktop Protocol

A small Omarchy bar icon that tells you when someone is controlling this computer over **Remote Desktop Protocol** — the same protocol Microsoft Remote Desktop, Windows App, Remmina, and FreeRDP use.

![Preview](preview.png)

The bar icon and status text use the theme green while a session is active. The panel title is **Remote Desktop Protocol**.

**Copy and paste just works from a Mac or PC.** Omarchy’s Super hotkeys normally collide with Command (Mac) and the Windows key. This plugin remaps Super / Command / Win to **Ctrl** on the remote keyboard only, so Command-C and Ctrl-C reach the app instead of the compositor. Your physical keyboard is unchanged.

It does **not** start a Remote Desktop Protocol server. You still need [hypr-rdp](https://github.com/hyprwm/hypr-rdp) (or another Remote Desktop Protocol server) running on this machine. This plugin watches for a live connection, makes it obvious, and fixes those remote hotkeys.

## Before you start

1. Install `hypr-rdp` on this Omarchy PC.
2. Start it and keep it running:

```sh
systemctl --user enable --now hypr-rdp.service
```

3. From another device, connect with any Remote Desktop Protocol client (Microsoft Remote Desktop / Windows App, Remmina, FreeRDP, and so on) to this computer’s IP.

If nobody is connected yet, the icon is hidden. That is normal.

## Install

```sh
omarchy plugin add https://github.com/Ruegen/omarchy-rdp-monitor.git --enable
```

When someone is connected, the icon appears on the **right** of the bar. To move it:

```sh
omarchy bar move io.github.ruegen.rdp-monitor --section left
```

Or copy this folder to `~/.config/omarchy/plugins/io.github.ruegen.rdp-monitor/` and run `omarchy plugin enable io.github.ruegen.rdp-monitor`.

## What you will see

| | Meaning |
|---|---|
| No icon | Nobody is connected |
| Theme-green icon + notification | A remote desktop client just connected |
| Banner: **This computer is being controlled remotely** + an IP | That machine is in control right now |

Hover or click the icon to see the same IP.

The Super-as-Ctrl remap is on by default. Turn it off in the widget setting **Remap remote Super/Command to Ctrl**. Reconnect the client once after the first enable so Hyprland picks up the remote keyboard map.

Drag the banner anywhere. Double-click it to put it back under the bar. When they disconnect, the banner and the icon both go away (within a couple of seconds).

## If nothing happens

- Is `hypr-rdp` running? `systemctl --user status hypr-rdp.service`
- Did a client actually connect (not just sit on the login screen of the remote app)?
- Unusual listen port? The plugin follows whatever `hypr-rdp` is using. You can also set **Listen port** on the widget (0 = automatic).
- Remote copy/paste still hitting Omarchy? Reconnect once. Confirm **Remap remote Super/Command to Ctrl** is on.

## Remove

```sh
omarchy plugin remove io.github.ruegen.rdp-monitor
```

That removes the widget only. `hypr-rdp` stays installed. The plugin may leave `~/.local/state/io.github.ruegen.rdp-monitor/` (`peers` and `banner.json`). Delete that folder if you want the saved banner position gone too. If Super-as-Ctrl is still on, turn the setting off once before remove, or delete the marked block in `~/.config/hypr/hyprland.lua` and `~/.config/hypr/rdp-monitor.lua`.

## Files this plugin writes

| Path | What |
|---|---|
| `~/.local/state/io.github.ruegen.rdp-monitor/peers` | Last seen controller IPs, so connect/disconnect notifications can fire |
| `~/.local/state/io.github.ruegen.rdp-monitor/banner.json` | Banner position after you drag it |
| `~/.config/hypr/rdp-monitor.lua` | Super-as-Ctrl for the hypr-rdp virtual keyboard (removed if you turn the setting off) |
| `~/.config/hypr/hyprland.lua` | A marked `require("hypr.rdp-monitor")` block (removed if you turn the setting off) |

It never reads `hypr-rdp` config or credentials. Listen port comes from the widget setting, the live `hypr-rdp` socket, or 3389. Theme green is read only from a regular `colors.toml` opened without following a symlink.

## Update

```sh
omarchy plugin update io.github.ruegen.rdp-monitor
```

## License

MIT. You can use, copy, and modify this plugin, including commercially.
