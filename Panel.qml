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
  property string scriptPath: {
    var u = String(Qt.resolvedUrl("rdp-connection"))
    if (u.indexOf("file://") === 0)
      u = u.substring(7)
    return u
  }
  property string label: "RDP"
  property string tooltipText: "No controlling connection"
  property string connectionText: "No controlling connection"
  property string connectionIps: "Waiting for a Mac or PC to connect"
  property string connectionStatus: "disconnected"
  readonly property bool connected: connectionStatus === "connected"

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
      var text = String(data.text || "")
      var tip = String(data.tooltip || "")
      var klass = String(data.class || "disconnected")
      root.connectionStatus = klass
      if (klass === "connected" && text.length > 0) {
        root.label = text
        root.tooltipText = tip.replace(/\\n/g, "\n") || ("Controlling connection\n" + text)
        root.connectionText = "Controlling connection"
        root.connectionIps = text
      } else {
        root.label = "RDP"
        root.tooltipText = "No controlling connection"
        root.connectionText = "No controlling connection"
        root.connectionIps = "Waiting for a Mac or PC to connect"
      }
    } catch (e) {
      console.error("Failed to parse RDP status: " + e)
      root.connectionIps = "Error parsing data"
    }
  }

  function pollNow() {
    if (statusProc.running) return
    statusProc.command = ["bash", root.scriptPath]
    statusProc.running = true
  }

  Process {
    id: statusProc
    command: ["bash", root.scriptPath]
    running: false
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyStatus(text)
    }
  }

  Timer {
    interval: 2000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.pollNow()
  }

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
          text: "RDP Connection Status"
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.subtitle
          font.bold: true
          wrapMode: Text.WordWrap
        }

        Text {
          width: parent.width
          text: root.connectionText
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          wrapMode: Text.WordWrap
        }

        Text {
          width: parent.width
          text: root.connectionIps
          color: root.barForeground
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
