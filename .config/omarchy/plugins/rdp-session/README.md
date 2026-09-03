# RDP Session Widget

Version 1.0.0

Omarchy bar widget: shows when remote desktop sessions are active via hypr-rdp.

Shows a remote-desktop icon (󰢹) when sessions are active, with client IP in tooltip.

![Preview](preview.png)

## Install

```sh
omarchy plugin add https://github.com/ruegen/omarchy-rdp-widget.git --enable
```

Or copy the repo into `~/.config/omarchy/plugins/ruegen.rdp-session/` and reload the Omarchy shell.

## Usage

1. When no RDP sessions are active, the widget is hidden
2. When RDP sessions are active, the remote-desktop icon (󰢹) appears on the bar
3. Hover over the icon to see the client IP in the tooltip
4. Notifications appear when users connect/disconnect

## Remove

```sh
omarchy plugin remove ruegen.rdp-session
```

That disables the widget and deletes the plugin checkout.

## Update

```sh
omarchy plugin update ruegen.rdp-session
```

## License

MIT. You can use, copy, and modify this plugin, including commercially.

The plugin works with the standard Omarchy shell and doesn't require any additional packages beyond what's already in Omarchy.