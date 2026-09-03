# Omarchy RDP Plugin Checklist

## Plugin Requirements Verification

### ✅ Plugin Structure
- [x] Plugin directory in `~/.config/omarchy/plugins/rdp-session/`
- [x] Contains `manifest.json` with proper schema
- [x] Contains executable `rdp-session` script
- [x] Contains `README.md` and `LICENSE`

### ✅ Manifest.json Content
- [x] Has `schemaVersion`: 1
- [x] Has `id`: "omarchy.rdp-session"  
- [x] Has `name`: "RDP Session Widget"
- [x] Has `version`: "1.0.0"
- [x] Has `description`: Plugin description
- [x] Has `shell.type`: "command"
- [x] Has `shell.exec`: "rdp-session"
- [x] Has `shell.interval`: 1
- [x] Has `shell.tooltip`: "RDP"

### ✅ Script Requirements
- [x] Script is executable (`chmod +x`)
- [x] Script uses proper shebang (`#!/bin/bash`)
- [x] Script detects RDP sessions using `ss` command
- [x] Script properly filters IP addresses
- [x] Script outputs Waybar-style JSON for Omarchy bar
- [x] Script handles connect/disconnect notifications
- [x] Script manages state for edge-triggered notifications

### ✅ Compliance with Instructions
- [x] Works locally only (no `/usr/share/omarchy` changes)
- [x] No upstream PRs needed
- [x] No root privileges required
- [x] Works across Omarchy updates
- [x] Uses authoritative detection method (`ss` command)
- [x] Respects all specified IP filtering requirements
- [x] Polls every 1-2 seconds for instant feel
- [x] Does not treat "hypr-rdp running" as connected
- [x] Uses proper error handling

### ✅ Installation Process
- [x] Can be installed via `omarchy plugin add [url]` 
- [x] Can be manually copied to `~/.config/omarchy/plugins/`
- [x] Can be enabled via `omarchy plugin enable rdp-session`
- [x] Integrates with Omarchy bar automatically when enabled

## Testing Verification

### ✅ Functionality Tests
1. **Idle State**: Script returns empty/none when no sessions
2. **Active State**: Script returns proper JSON when sessions detected
3. **IP Filtering**: Loopback and IPv4-mapped addresses filtered correctly
4. **Notifications**: Only sent on state change (edge-triggered)
5. **State Persistence**: Uses `~/.local/state/omarchy/rdp-session` file
6. **Integration**: Works with Omarchy bar via command module type

### ✅ Requirements Verification
1. **Detection**: Uses `ss -Htn state established '( sport = :3389 )'`
2. **IP Parsing**: Strips loopback (`127.0.0.1`, `::1`) and IPv4-mapped IPv6 addresses
3. **No Password Exposure**: No access to credentials, keys, or certs
4. **Local Only**: All operations in user space only
5. **Polling**: Every 1-2 seconds as requested
6. **Widget Hiding**: Disappears when idle
7. **Tooltip Display**: Shows "User connected" with IP
8. **Command Module**: Uses `type: "command"` in manifest

## Final Implementation Check

The plugin at `~/.config/omarchy/plugins/rdp-session/` contains:

1. `manifest.json` - Proper Omarchy plugin manifest with shell integration
2. `rdp-session` - Executable bash script with all required functionality
3. `README.md` - Documentation
4. `LICENSE` - MIT License

This structure and content meets all the Omarchy plugin requirements and the specific instructions for the RDP session monitoring widget.