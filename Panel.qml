import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.ruegen.rdp-monitor"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property var settings: ({})
  readonly property int configuredPort: {
    var n = parseInt(String(settings && settings.port != null ? settings.port : 0), 10)
    if (!isFinite(n) || n < 1 || n > 65535) return 0
    return n
  }
  readonly property bool remapSuper: !(settings && settings.remapSuper === false)
  property string helperPath: {
    var u = String(Qt.resolvedUrl("rdp-helper"))
    if (u.indexOf("file://") === 0)
      u = u.substring(7)
    return u
  }
  property string label: ""
  property string tooltipText: "Omarchy RDP Monitor — no session"
  property string connectionText: "No active session"
  property string connectionIps: "Waiting for a connection"
  property string connectionStatus: "disconnected"
  property string statusBuf: ""
  property string statusErr: ""
  readonly property int statusMax: 1024
  readonly property int statusErrMax: 256
  readonly property bool connected: connectionStatus === "connected"
  readonly property color themeGreen: hostWidget && hostWidget.themeGreen
    ? hostWidget.themeGreen
    : Color.accent
  readonly property color statusColor: connected ? themeGreen : root.barForeground

  function safeText(s, maxLen) {
    var t = String(s || "")
    var out = ""
    for (var i = 0; i < t.length && out.length < maxLen; i++) {
      var c = t.charAt(i)
      var o = t.charCodeAt(i)
      if (c === "<" || c === ">" || c === "&" || o < 32 || (o >= 0x7F && o <= 0x9F)
          || o === 0x202A || o === 0x202B || o === 0x202C || o === 0x202D || o === 0x202E
          || o === 0x2066 || o === 0x2067 || o === 0x2068 || o === 0x2069)
        continue
      out += c
    }
    return out
  }

  function helperCommand(args) {
    var cmd = ["/usr/bin/python3", "-I", "-S", root.helperPath]
    for (var i = 0; i < args.length; i++)
      cmd.push(args[i])
    return cmd
  }

  function open() {
    root.controller.show()
    root.pollNow()
  }

  function close() {
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function closeForPopoutSwitch() {
    root.controller.hide()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.hostWidget || root, direction)
    return false
  }

  function applyStatus(raw) {
    try {
      var data = JSON.parse(String(raw || "").trim() || "{}")
      if (data === null || typeof data !== "object")
        return
      var klass = String(data.class || "disconnected")
      if (klass !== "connected" && klass !== "disconnected")
        klass = "disconnected"
      var text = root.safeText(data.text || "", 45)
      var tip = root.safeText(String(data.tooltip || "").replace(/\\n/g, "\n"), 120)
      var green = root.safeText(data.green || "", 7)
      if (!/^#[0-9A-Fa-f]{6}$/.test(green))
        green = ""
      if (root.hostWidget && green.length > 0)
        root.hostWidget.themeGreen = green
      root.connectionStatus = klass
      if (klass === "connected" && text.length > 0) {
        root.label = text
        root.tooltipText = tip || ("Omarchy RDP Monitor\n" + text)
        root.connectionText = "A remote session is active"
        root.connectionIps = text
      } else {
        root.label = ""
        root.tooltipText = "Omarchy RDP Monitor — no session"
        root.connectionText = "No active session"
        root.connectionIps = "Waiting for a connection"
      }
    } catch (e) {
      console.error("Failed to parse remote desktop status")
      root.connectionIps = "Error parsing data"
    }
  }

  function pollNow() {
    if (statusProc.running) return
    root.statusBuf = ""
    root.statusErr = ""
    var remap = root.remapSuper ? "remap" : "noremap"
    if (root.configuredPort > 0)
      statusProc.command = root.helperCommand(["status", String(root.configuredPort), remap])
    else
      statusProc.command = root.helperCommand(["status", remap])
    statusProc.running = true
  }

  Process {
    id: statusProc
    command: root.helperCommand(["status", "remap"])
    running: false
    stdout: SplitParser {
      splitMarker: ""
      onRead: function(chunk) {
        root.statusBuf += chunk
        if (root.statusBuf.length > root.statusMax) {
          statusProc.signal(15)
          statusKill.start()
          root.statusBuf = ""
        }
      }
    }
    stderr: SplitParser {
      splitMarker: ""
      onRead: function(chunk) {
        root.statusErr += chunk
        if (root.statusErr.length > root.statusErrMax) {
          statusProc.signal(15)
          statusKill.start()
          root.statusErr = ""
        }
      }
    }
    onExited: function(code) {
      if (code === 0)
        root.applyStatus(root.statusBuf)
      root.statusBuf = ""
      root.statusErr = ""
    }
  }

  Timer {
    id: statusKill
    interval: 2000
    repeat: false
    onTriggered: statusProc.signal(9)
  }

  Timer {
    interval: 2000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.pollNow()
  }

  Component.onDestruction: statusProc.signal(15)

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(240))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(8)

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: "Omarchy RDP Monitor"
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.subtitle
          font.bold: true
          wrapMode: Text.WordWrap
        }

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: root.connectionText
          color: root.statusColor
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          wrapMode: Text.WordWrap
        }

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: root.connectionIps
          color: root.statusColor
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          wrapMode: Text.WordWrap
        }

        Button {
          text: "Refresh"
          width: parent.width
          onClicked: root.pollNow()
        }
      }
    }
  }
}
