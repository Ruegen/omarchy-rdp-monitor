# Omarchy RDP Monitor

Omarchy bar widget that shows when a Mac or PC is controlling this machine over RDP (`hypr-rdp`).

The bar icon is a remote-desktop glyph, so it follows the current theme: dim when idle, theme active color when someone is connected.

## Install

```sh
omarchy plugin add https://github.com/Ruegen/omarchy-rdp-monitor.git --enable
```

Or copy this repo into `~/.config/omarchy/plugins/io.github.ruegen.rdp-monitor/` and reload the Omarchy shell:

```sh
mkdir -p ~/.config/omarchy/plugins
cp -r . ~/.config/omarchy/plugins/io.github.ruegen.rdp-monitor
omarchy-shell shell rescanPlugins
omarchy plugin enable io.github.ruegen.rdp-monitor
```

`omarchy plugin add` expects `manifest.json` at the repo root. The widget lands on the right of the bar by default (`omarchy bar move io.github.ruegen.rdp-monitor --section right` if you want to move it).

Requires `hypr-rdp` running. The plugin reads the listen port from the live `hypr-rdp` socket, then from `bind` in `~/.config/hypr-rdp/config.toml`, then 3389. Set **RDP port** on the widget (or pass a port to `rdp-connection`) to override. Detection uses `ss` for inbound sessions (the controlling client), not outbound RDP.

## Usage

1. Keep `hypr-rdp` running (`systemctl --user enable --now hypr-rdp.service`).
2. When a Mac or PC connects, the icon lights up and a notification fires.
3. A banner reads **This computer is being controlled remotely** plus the client IP. Drag it; the position is saved.
4. Hover or click the icon for the same IP.
5. When they disconnect, the banner hides, the icon dims, and the panel goes back to idle (within about two seconds).

## Remove

```sh
omarchy plugin remove io.github.ruegen.rdp-monitor
```

That disables the widget and deletes the plugin checkout.

## Update

```sh
omarchy plugin update io.github.ruegen.rdp-monitor
```

## License

MIT. You can use, copy, and modify this plugin, including commercially.
