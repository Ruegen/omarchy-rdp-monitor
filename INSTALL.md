# Installation and Removal Guide for Omarchy RDP Session Widget Plugin

This guide explains how to install and remove the Omarchy RDP Session Widget Plugin.

## Prerequisites

Before installing, ensure you have:
- An Omarchy system with Hyprland
- hypr-rdp 0.1.4 installed and running with user unit `hypr-rdp.service` enabled
- Port 3389 bound to `0.0.0.0:3389`

## Self-Installation Capabilities

This plugin includes enhanced self-installation capabilities:
- If prerequisites aren't met, the plugin will show helpful installation instructions
- It will guide you through installing hypr-rdp if it's missing
- It will notify you when the service needs to be started or configured

## Installation Methods

### Method 1: Command Line Installation (Recommended)

If you have a Git repository for your plugin:
```bash
omarchy plugin add https://github.com/yourusername/omarchy-rdp-widget.git
```

### Method 2: Manual Installation

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

## Verification

After installation and enabling:

1. The RDP session widget should appear in the Omarchy bar when RDP sessions are active
2. When no RDP sessions are active, the widget will be hidden
3. When active, you'll see a remote-desktop icon (󰢹) with client IP in tooltip
4. Notifications will appear when users connect or disconnect

## Usage

### Normal Operation
- **Idle State**: Widget is completely hidden from the bar
- **Active Session**: Remote-desktop icon (󰢹) appears on the bar
- **Hover**: Shows "User connected" with client IP in tooltip
- **Notifications**: Appear when users connect/disconnect

### Testing
To test the widget:
1. Connect to your Omarchy system via RDP from another device
2. The widget should immediately appear in the bar
3. Verify the client IP appears in the tooltip
4. Check for notifications when the connection starts and stops

## Troubleshooting

If the widget doesn't appear or shows installation errors:

1. **Verify prerequisites are installed**:
   ```bash
   # Check if hypr-rdp is installed
   which hypr-rdp
   
   # Check if service is running  
   systemctl --user is-active hypr-rdp.service
   
   # Check if port 3389 is listening
   ss -tuln | grep :3389
   ```

2. **Install hypr-rdp if missing**:
   ```bash
   # Install using your system's package manager (example for Debian/Ubuntu)
   sudo apt install hypr-rdp
   
   # Enable and start the service
   systemctl --user enable hypr-rdp.service
   systemctl --user start hypr-rdp.service
   ```

3. **Verify RDP is properly configured** to listen on 0.0.0.0:3389

4. **Restart the shell**:
   ```bash
   omarchy restart shell
   ```

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

## Plugin Structure

The plugin consists of:
- `manifest.json`: Defines plugin metadata and shell integration
- `rdp-session`: Main executable script with self-installation capabilities
- `README.md`: Documentation about the plugin
- `LICENSE`: MIT License information