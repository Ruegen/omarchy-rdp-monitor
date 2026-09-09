import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.ruegen.rdp-monitor"

  readonly property bool opened: panelLoader.item
    ? panelLoader.item.opened === true
    : false
  readonly property bool popoutSwitchClosing: panelLoader.item
    ? panelLoader.item.popoutSwitchClosing === true
    : false
  readonly property string tooltipText: panelLoader.item ? panelLoader.item.tooltipText : "Remote Desktop Protocol"
  readonly property bool connected: panelLoader.item ? panelLoader.item.connected : false
  readonly property string controllerIp: {
    if (!root.connected || !panelLoader.item) return ""
    return String(panelLoader.item.label || "")
  }
  property string helperPath: {
    var u = String(Qt.resolvedUrl("rdp-helper"))
    if (u.indexOf("file://") === 0)
      u = u.substring(7)
    return u
  }

  property color themeGreen: Color.accent
  property string bannerBuf: ""
  property string bannerErr: ""

  visible: root.connected
  implicitWidth: root.connected ? button.implicitWidth : 0
  implicitHeight: root.connected ? button.implicitHeight : 0

  property real bannerX: -1
  property real bannerY: -1
  property bool bannerDragging: false

  readonly property real bannerW: bannerCard.implicitWidth
  readonly property real bannerH: bannerCard.implicitHeight
  readonly property real placedX: bannerX < 0 ? defaultBannerX() : clampX(bannerX)
  readonly property real placedY: bannerY < 0 ? defaultBannerY() : clampY(bannerY)

  function helperCommand(args) {
    var cmd = ["/usr/bin/python3", "-I", "-S", root.helperPath]
    for (var i = 0; i < args.length; i++)
      cmd.push(args[i])
    return cmd
  }

  function open() {
    if (panelLoader.item) panelLoader.item.open()
  }

  function close() {
    if (panelLoader.item) panelLoader.item.close()
  }

  function toggle() {
    if (panelLoader.item) panelLoader.item.toggle()
  }

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  function injectPanel() {
    if (!panelLoader.item) return
    panelLoader.item.bar = root.bar
    panelLoader.item.anchorItem = button
    panelLoader.item.hostWidget = root
    if ("settings" in panelLoader.item)
      panelLoader.item.settings = root.settings
  }

  function screenW() {
    if (observeBanner.width > 0) return observeBanner.width
    var s = observeBanner.screen
    return s && s.width ? s.width : 1920
  }

  function screenH() {
    if (observeBanner.height > 0) return observeBanner.height
    var s = observeBanner.screen
    return s && s.height ? s.height : 1080
  }

  function defaultBannerX() {
    return Math.round((screenW() - root.bannerW) / 2)
  }

  function defaultBannerY() {
    return Style.bar.sizeHorizontal + Style.gapsOut
  }

  function clampX(x) {
    return Math.round(Math.min(Math.max(0, x), Math.max(0, screenW() - root.bannerW)))
  }

  function clampY(y) {
    return Math.round(Math.min(Math.max(0, y), Math.max(0, screenH() - root.bannerH)))
  }

  function applyBannerPos() {
    if (!observeBanner.visible || root.bannerW <= 0) return
    bannerCard.x = root.placedX
    bannerCard.y = root.placedY
  }

  function applyBannerJson(raw) {
    try {
      var data = JSON.parse(String(raw || "").trim() || "{}")
      if (data && isFinite(data.x) && isFinite(data.y)) {
        root.bannerX = Number(data.x)
        root.bannerY = Number(data.y)
      }
    } catch (e) {}
    Qt.callLater(root.applyBannerPos)
  }

  function loadBannerPos() {
    if (bannerRead.running) return
    root.bannerBuf = ""
    root.bannerErr = ""
    bannerRead.command = root.helperCommand(["banner-get"])
    bannerRead.running = true
  }

  function saveBannerPos() {
    root.bannerX = root.clampX(bannerCard.x)
    root.bannerY = root.clampY(bannerCard.y)
    bannerCard.x = root.bannerX
    bannerCard.y = root.bannerY
    bannerWrite.command = root.helperCommand([
      "banner-set", String(root.bannerX), String(root.bannerY)
    ])
    bannerWrite.running = true
  }

  function resetBannerPos() {
    root.bannerX = -1
    root.bannerY = -1
    bannerWrite.command = root.helperCommand(["banner-clear"])
    bannerWrite.running = true
    root.applyBannerPos()
  }

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()
  Component.onCompleted: root.loadBannerPos()

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰢹"
    tooltipText: root.tooltipText
    active: false
    useActiveColor: false
    foreground: root.themeGreen
    slotSize: Style.bar.statusSlot
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.LeftButton) root.toggle()
    }
  }

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  Process {
    id: bannerRead
    command: root.helperCommand(["banner-get"])
    running: false
    stdout: SplitParser {
      splitMarker: ""
      onRead: function(chunk) {
        root.bannerBuf += chunk
        if (root.bannerBuf.length > 256) {
          bannerRead.signal(15)
          root.bannerBuf = ""
        }
      }
    }
    stderr: SplitParser {
      splitMarker: ""
      onRead: function(chunk) {
        root.bannerErr += chunk
        if (root.bannerErr.length > 256) {
          bannerRead.signal(15)
          root.bannerErr = ""
        }
      }
    }
    onExited: function(code) {
      if (code === 0)
        root.applyBannerJson(root.bannerBuf)
      else
        Qt.callLater(root.applyBannerPos)
      root.bannerBuf = ""
      root.bannerErr = ""
    }
  }

  Process {
    id: bannerWrite
    command: root.helperCommand(["banner-clear"])
    running: false
  }

  PanelWindow {
    id: observeBanner
    visible: root.connected
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "io.github.ruegen.rdp-monitor"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    mask: Region { item: bannerCard }

    onVisibleChanged: if (visible) Qt.callLater(root.applyBannerPos)
    onWidthChanged: if (visible && !root.bannerDragging) root.applyBannerPos()
    onHeightChanged: if (visible && !root.bannerDragging) root.applyBannerPos()

    BorderSurface {
      id: bannerCard
      x: 0
      y: 0
      color: Color.popups.background
      borderSpec: Border.surfaceSpec("popups", "border", root.themeGreen, Math.max(1, Style.space(2)))
      radius: Style.cornerRadius
      implicitWidth: bannerRow.implicitWidth + Style.space(28)
      implicitHeight: bannerRow.implicitHeight + Style.space(16)

      Row {
        id: bannerRow
        anchors.centerIn: parent
        spacing: Style.space(10)

        Text {
          textFormat: Text.PlainText
          text: "󰢹"
          color: root.themeGreen
          font.family: Style.font.family
          font.pixelSize: Style.font.icon
        }

        Text {
          textFormat: Text.PlainText
          text: root.controllerIp.length > 0
            ? "This computer is being controlled remotely · " + root.controllerIp
            : "This computer is being controlled remotely"
          color: Color.popups.text
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          font.bold: true
        }
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.SizeAllCursor
        drag.target: bannerCard
        drag.threshold: 4
        drag.minimumX: 0
        drag.maximumX: Math.max(0, observeBanner.width - bannerCard.width)
        drag.minimumY: 0
        drag.maximumY: Math.max(0, observeBanner.height - bannerCard.height)
        onPressed: root.bannerDragging = true
        onReleased: {
          root.saveBannerPos()
          root.bannerDragging = false
        }
        onDoubleClicked: root.resetBannerPos()
      }
    }
  }
}
