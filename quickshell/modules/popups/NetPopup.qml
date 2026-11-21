import QtQuick
import Quickshell.Bluetooth
import qs
import qs.components
import qs.services

// Wi-Fi + Bluetooth card, opened from the Wi-Fi item.
PopupFrame {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter

    // ── Wi-Fi header ──
    Item {
        width: parent.width; height: 45
        Txt { x: 22; anchors.verticalCenter: parent.verticalCenter; text: "Wi-Fi"; font.pixelSize: 17 }
        SquareToggle {
            anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
            selfToggle: false
            checked: Network.enabled
            onToggled: v => Network.setEnabled(v)
        }
    }

    // ── current network ──
    Rectangle {
        visible: Network.connected
        width: parent.width; height: visible ? 62 : 0
        color: Theme.block
        Item {
            x: 22; anchors.verticalCenter: parent.verticalCenter; width: 28; height: 28
            Glyph { kind: "signal"; level: Network.signal / 100; scale: 1.75; transformOrigin: Item.TopLeft }
        }
        Column {
            x: 66; anchors.verticalCenter: parent.verticalCenter; spacing: 1
            Mono { text: Network.ssid; font.pixelSize: 14; font.bold: true }
            Txt  { text: Network.detail; color: Theme.muted; font.pixelSize: 12 }
        }
    }

    // ── other networks ──
    Repeater {
        model: Network.networks.slice(0, 6)
        delegate: ListRow {
            id: net
            required property var modelData
            onClicked: Network.connect(modelData.ssid)
            Glyph { x: 22; anchors.verticalCenter: parent.verticalCenter; kind: "signal"; level: net.modelData.signal / 100 }
            Mono  { x: 50; anchors.verticalCenter: parent.verticalCenter; text: net.modelData.ssid; font.pixelSize: 13
                    elide: Text.ElideRight; width: parent.width - 130 }
            Txt   { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
                    visible: !net.modelData.secure; text: "open"; color: Theme.muted; font.pixelSize: 12 }
        }
    }
    Item { width: parent.width; height: 6 }

    Rectangle { width: parent.width; height: 1; color: Theme.rule }

    // ── Bluetooth header ──
    Item {
        width: parent.width; height: 45
        Txt { x: 22; anchors.verticalCenter: parent.verticalCenter; text: "Bluetooth"; font.pixelSize: 17 }
        Txt {
            id: scan
            visible: root.adapter !== null && root.adapter.enabled
            anchors { right: tog.left; rightMargin: 14; verticalCenter: parent.verticalCenter }
            text: root.adapter && root.adapter.discovering ? "searching" : "search"
            color: Theme.muted; font.pixelSize: 12
            MouseArea { anchors.fill: parent; anchors.margins: -6
                        onClicked: root.adapter.discovering = !root.adapter.discovering }
        }
        SquareToggle {
            id: tog
            visible: root.adapter !== null
            anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
            selfToggle: false
            checked: Bt.on
            onToggled: v => Bt.set(v)
        }
    }

    Txt { visible: root.adapter === null; x: 22; text: "No Bluetooth adapter"; color: Theme.muted; font.pixelSize: 13
          height: visible ? 30 : 0 }

    Repeater {
        model: root.adapter ? root.adapter.devices : null
        delegate: ListRow {
            id: dev
            required property var modelData
            visible: modelData.connected || modelData.paired || (root.adapter && root.adapter.discovering)
            onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
            Square { x: 22; anchors.verticalCenter: parent.verticalCenter; filled: dev.modelData.connected }
            Txt { x: 50; anchors.verticalCenter: parent.verticalCenter; text: dev.modelData.name || dev.modelData.address
                  elide: Text.ElideRight; width: parent.width - 150; font.pixelSize: 14 }
            Txt { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
                  text: dev.modelData.connected ? "connected" : dev.modelData.paired ? "paired" : ""
                  color: Theme.muted; font.pixelSize: 12 }
        }
    }
    Item { width: parent.width; height: 8 }
}
