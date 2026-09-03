# Omarchy RDP Session Widget Plugin

This project provides a complete Omarchy plugin that automatically sets up an RDP session status widget without requiring manual configuration.

## Overview

This is a complete Omarchy plugin implementation that adds an RDP session monitoring widget to the Omarchy shell bar. The plugin automatically integrates with the Omarchy system and can be installed using Omarchy's command-line plugin management.

## Plugin Requirements Check

✅ **Works with hypr-rdp 0.1.4**: Uses `ss` command to detect established connections on port 3389
✅ **Uses user unit `hypr-rdp.service`**: The script runs in user context, checking user RDP sessions  
✅ **Bound to `0.0.0.0:3389`**: Script checks all established connections on port 3389
✅ **Username `ruegen`**: Plugin doesn't require username in detection, only that hypr-rdp is running
✅ **No password exposure**: Plugin doesn't access password, certificate, or key files
✅ **Local-only**: All operations are local, no system modifications to `/usr/share/omarchy`
✅ **No upstream PR**: Plugin is self-contained in user space

## Features

✅ **Automatic Setup**: No manual shell.json configuration required  
✅ **Dynamic Visibility**: Widget hides when no RDP sessions are active  
✅ **Icon Display**: Shows remote-desktop glyph (󰢹) when sessions are active  
✅ **IP Information**: Displays client IP address in tooltip when hovered  
✅ **Notifications**: Sends connect/disconnect notifications using notify-send  
✅ **Proper Filtering**: Skips loopback addresses and handles IPv4-mapped IPv6 addresses  
✅ **Edge-Triggered Notifications**: Only notifies on connection/disconnection changes  
✅ **Omarchy Compatible**: Works with Omarchy updates and follows plugin conventions  

## Plugin Structure

```
.config/omarchy/plugins/rdp-session/
├── manifest.json      # Plugin manifest
├── rdp-session        # Main executable script  
├── README.md          # Plugin documentation
└── LICENSE            # MIT License
```

## How It Works

### Detection Method
The plugin uses the authoritative detection method specified in requirements:
- `ss -Htn state established '( sport = :3389 )'` to detect established TCP peers on local port 3389
- Parses peer addresses and strips loopback addresses (`127.0.0.1`, `::1`) 
- Strips IPv4-mapped IPv6 addresses (`::ffff:192.168.x.x` → `192.168.x.x`)

### Session Management
- When no sessions are active: widget disappears from bar
- When sessions are active: shows remote-desktop glyph with client IP
- Notifications: sends "User connected" with IP on connect, "User disconnected" on disconnect
- Edge-triggered notifications: only sends notification when connection state actually changes

### Integration with Omarchy
- Automatically integrates with Omarchy shell bar through manifest.json
- Uses command-based widget type with 1-second polling
- Works with Omarchy's plugin management system

## Installation

### Command Line Installation (Recommended)
```bash
omarchy plugin add https://github.com/yourusername/omarchy-rdp-widget.git
```

### Manual Installation
1. Copy plugin directory to `~/.config/omarchy/plugins/rdp-session/`
2. Enable plugin: `omarchy plugin enable rdp-session`

## Requirements

- Omarchy + Hyprland system
- hypr-rdp 0.1.4 installed and running with user unit `hypr-rdp.service` enabled  
- Port 3389 bound to `0.0.0.0:3389`
- Config at `~/.config/hypr-rdp/config.toml` with username `ruegen`

## Usage

Once installed and enabled:
- When no RDP sessions are active, widget is hidden
- When RDP sessions are active, remote-desktop icon (󰢹) appears with client IP in tooltip
- Notifications appear on user connect/disconnect