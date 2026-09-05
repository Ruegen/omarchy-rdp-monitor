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
  readonly property string tooltipText: panelLoader.item ? panelLoader.item.tooltipText : "RDP"
  readonly property bool connected: panelLoader.item ? panelLoader.item.connected : false
  readonly property string controllerIp: {
    if (!root.connected || !panelLoader.item) return ""
    var ip = String(panelLoader.item.label || "")
    return ip === "RDP" ? "" : ip
  }

  property real bannerX: -1
  property real bannerY: -1

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
  }

  function defaultBannerX() {
    return Math.round((observeBanner.width - bannerCard.width) / 2)
  }

  function defaultBannerY() {
    return Style.bar.sizeHorizontal + Style.gapsOut
  }

  function clampBanner() {
    var maxX = Math.max(0, observeBanner.width - bannerCard.width)
    var maxY = Math.max(0, observeBanner.height - bannerCard.height)
    bannerCard.x = Math.round(Math.min(maxX, Math.max(0, bannerCard.x)))
    bannerCard.y = Math.round(Math.min(maxY, Math.max(0, bannerCard.y)))
  }

  function applyBannerPos() {
    if (!observeBanner.visible || observeBanner.width <= 0 || bannerCard.width <= 0)
      return
    if (root.bannerX < 0 || root.bannerY < 0) {
      bannerCard.x = root.defaultBannerX()
      bannerCard.y = root.defaultBannerY()
    } else {
      bannerCard.x = root.bannerX
      bannerCard.y = root.bannerY
      root.clampBanner()
    }
  }

  function saveBannerPos() {
    root.clampBanner()
    root.bannerX = bannerCard.x
    root.bannerY = bannerCard.y
    posFile.setText(JSON.stringify({ x: root.bannerX, y: root.bannerY }) + "\n")
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    // nf-md-remote-desktop — color comes from the theme (bar.active / urgent when connected)
    text: "󰢹"
    tooltipText: root.tooltipText
    active: root.connected
    useActiveColor: true
    dimmed: !root.connected
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

  FileView {
    id: posFile
    path: Quickshell.env("HOME") + "/.local/state/omarchy/rdp-banner.json"
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: {
      try {
        var data = JSON.parse(String(text() || "{}"))
        if (isFinite(data.x) && isFinite(data.y)) {
          root.bannerX = Number(data.x)
          root.bannerY = Number(data.y)
        }
      } catch (e) {}
      Qt.callLater(root.applyBannerPos)
    }
    onLoadFailed: Qt.callLater(root.applyBannerPos)
  }

  // Persistent notice while a remote desktop session is in control.
  // Wording is original — not Apple's "Your screen is being observed."
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
    onWidthChanged: if (visible) root.clampBanner()
    onHeightChanged: if (visible) root.clampBanner()

    BorderSurface {
      id: bannerCard
      x: 0
      y: 0
      color: Color.popups.background
      borderSpec: Border.surfaceSpec("popups", "border", Color.urgent, Math.max(1, Style.space(2)))
      radius: Style.cornerRadius
      implicitWidth: bannerRow.implicitWidth + Style.space(28)
      implicitHeight: bannerRow.implicitHeight + Style.space(16)

      Row {
        id: bannerRow
        anchors.centerIn: parent
        spacing: Style.space(10)

        Text {
          text: "󰢹"
          color: Color.urgent
          font.family: Style.font.family
          font.pixelSize: Style.font.icon
        }

        Text {
          text: root.controllerIp.length > 0
            ? "This computer is being controlled remotely · " + root.controllerIp
            : "This computer is being controlled remotely"
          color: Color.popups.text
          font.family: Style.font.family
          font.pixelSize: Style.font.body
          font.bold: true
        }
      }

      DragHandler {
        target: bannerCard
        cursorShape: Qt.SizeAllCursor
        onActiveChanged: {
          if (!active)
            root.saveBannerPos()
        }
      }
    }
  }
}
