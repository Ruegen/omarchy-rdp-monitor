# Omarchy RDP Session Widget Plugin

This project provides a complete Omarchy plugin that automatically sets up an RDP session status widget without requiring manual configuration.

## Overview

This is a complete Omarchy plugin implementation that adds an RDP session monitoring widget to the Omarchy shell bar. The plugin automatically integrates with the Omarchy system and can be installed using Omarchy's command-line plugin management.

## Features

✅ **Automatic Setup**: No manual shell.json configuration required  
✅ **Dynamic Visibility**: Widget hides when no RDP sessions are active  
✅ **Icon Display**: Shows remote-desktop glyph (󰢹) when sessions are active  
✅ **IP Information**: Displays client IP address in tooltip when hovered  
✅ **Notifications**: Sends connect/disconnect notifications using notify-send  
✅ **Proper Filtering**: Skips loopback addresses and handles IPv4-mapped IPv6 addresses  
✅ **Edge-Triggered Notifications**: Only notifies on connection/disconnection changes  
✅ **Omarchy Compatible**: Works with Omarchy updates and follows plugin conventions  
✅ **Self-Installation Support**: Detects missing prerequisites and guides user through installation  

## Plugin Structure

```
~/Documents/apps/omarchy-rdp-widget/
├── .config/
│   └── omarchy/
│       └── plugins/
│           └── rdp-session/
│               ├── manifest.json      # Plugin manifest
│               ├── rdp-session        # Main executable script  
│               ├── README.md          # Plugin documentation
│               └── LICENSE            # MIT License
├── PLUGIN-README.md       # Detailed plugin documentation
├── README.md              # Project overview (this file)
└── INSTALL.md             # Installation and removal instructions
```

## Installation

### Command Line Installation (Recommended)
```bash
omarchy plugin add https://github.com/ruegen/omarchy-rdp-widget.git --enable
```

### Manual Installation
1. **Copy the plugin directory** to your Omarchy system:
   ```bash
   # Create the plugins directory if it doesn't exist
   mkdir -p ~/.config/omarchy/plugins
   
   # Copy the rdp-session plugin directory
   cp -r ~/Documents/apps/omarchy-rdp-widget/.config/omarchy/plugins/rdp-session ~/.config/omarchy/plugins/
   ```

2. **Enable the plugin** through Omarchy shell:
   ```bash
   omarchy plugin enable rdp-session
   ```

3. **The widget will automatically appear** in the Omarchy bar when RDP sessions are active

## Self-Installation Capabilities

The plugin now includes enhanced self-installation features:
- Automatically detects when required dependencies are missing
- Displays clear, actionable installation instructions 
- Guides users through installing hypr-rdp if needed
- Provides feedback when service needs to be started or configured

## Usage

Once installed and enabled:
- When no RDP sessions are active, the widget is completely hidden
- When RDP sessions are active, a remote-desktop icon appears on the bar
- Hover over the icon to see the client IP in the tooltip
- Receive notifications when users connect or disconnect

## Removal

To remove the plugin:

1. **Disable the plugin**:
   ```bash
   omarchy plugin disable rdp-session
   ```

2. **Remove the plugin directory**:
   ```bash
   rm -rf ~/.config/omarchy/plugins/rdp-session
   ```

3. **Restart the shell**:
   ```bash
   omarchy restart shell
   ```

## Requirements

- Omarchy + Hyprland system
- hypr-rdp 0.1.4 installed and running with user unit `hypr-rdp.service` enabled
- Port 3389 bound to `0.0.0.0:3389`

## How It Works

The plugin integrates automatically with Omarchy's plugin system by:
1. Using a proper `manifest.json` file to define the plugin with ID `ruegen.rdp-session`
2. Providing a `rdp-session` executable script that monitors RDP connections
3. Leveraging Omarchy's command-based widget system for automatic bar integration

When RDP sessions are detected:
- It monitors established TCP connections on port 3389 using the `ss` command
- Filters IP addresses to remove loopback and IPv4-mapped IPv6 addresses  
- Displays a remote-desktop icon (󰢹) when sessions are active
- Shows client IP in the tooltip when hovered
- Sends notifications on connection/disconnection events

## Compliance

This plugin:
- ✅ Works locally only, no changes to `/usr/share/omarchy`
- ✅ No upstream PRs required
- ✅ No root privileges needed  
- ✅ Persists across Omarchy updates
- ✅ Follows Omarchy plugin development standards
- ✅ Respects all system requirements in the original instructions