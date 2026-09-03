# Omarchy RDP Monitor

A simple RDP monitor for Omarchy that shows active connections in your bar.

## Overview

A lightweight RDP monitor that integrates seamlessly with Omarchy.

## Features

✅ **Automatic Setup**: No manual shell.json configuration required  
✅ **Dynamic Visibility**: Indicator hides when no RDP connections are active  
✅ **Icon Display**: Shows remote-desktop glyph (󰢹) when connections are active  
✅ **IP Information**: Displays client IP address in tooltip when hovered  
✅ **Notifications**: Sends connect/disconnect notifications using notify-send  
✅ **Proper Filtering**: Skips loopback addresses and handles IPv4-mapped IPv6 addresses  
✅ **Edge-Triggered Notifications**: Only notifies on connection/disconnection changes  
✅ **Omarchy Compatible**: Works with Omarchy updates and follows plugin conventions  
✅ **Self-Installation Support**: Detects missing prerequisites and guides user through installation

## Plugin Structure

```
~/Documents/apps/omarchy-rdp-monitor/
├── .config/
│   └── omarchy/
│       └── plugins/
│           └── rdp-monitor/
│               ├── manifest.json      # Plugin manifest
│               ├── rdp-connection     # Main executable script  
│               ├── README.md          # Plugin documentation
│               └── LICENSE            # MIT License
├── PLUGIN-README.md       # Detailed plugin documentation
├── README.md              # Project overview (this file)
└── INSTALL.md             # Installation and removal instructions
```

## Installation

### Command Line Installation (Recommended)
```bash
omarchy plugin add https://github.com/ruegen/omarchy-rdp-monitor.git --enable
```

### Manual Installation
1. **Copy the plugin directory** to your Omarchy system:
   ```bash
   # Create the plugins directory if it doesn't exist
   mkdir -p ~/.config/omarchy/plugins
   
   # Copy the rdp-monitor plugin directory
   cp -r ~/Documents/apps/omarchy-rdp-monitor/.config/omarchy/plugins/rdp-monitor ~/.config/omarchy/plugins/
   ```

2. **Enable the plugin** through Omarchy shell:
   ```bash
   omarchy plugin enable rdp-monitor
   ```

3. **The indicator will automatically appear** in the Omarchy bar when RDP connections are active

## Usage

Once enabled:
- Shows a remote-desktop icon when RDP connections are active
- Displays client IP in tooltip on hover
- Sends notifications on connection/disconnection
- Hides when no active connections