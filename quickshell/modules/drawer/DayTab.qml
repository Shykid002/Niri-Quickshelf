import QtQuick
import Quickshell.Bluetooth
import qs
import qs.components
import qs.services

// Day overview: week strip, quick tiles, Sound and Light sliders, notes.
Item {
    id: root
    readonly property real w: width - 40
    readonly property var adapter: Bluetooth.defaultAdapter

    readonly property var week: {
        const n = Almanac.now;
        const dow = (n.getDay() + 6) % 7;                  // Monday = 0
        const out = [];
        for (let i = 0; i < 7; i++) {
            const d = new Date(n.getFullYear(), n.getMonth(), n.getDate() - dow + i);
            out.push({ name: Almanac.weekdays[d.getDay()].slice(0, 3), day: d.getDate(), today: i === dow });
        }
        return out;
    }

    Column {
        id: notesCol
        x: 20; y: 16; width: root.w; spacing: 12

        Row {   // week strip
            width: parent.width
            Repeater {
                model: root.week
                delegate: Rectangle {
                    id: cell
                    required property var modelData
                    width: parent.width / 7; height: 43
                    color: modelData.today ? Theme.ink : "transparent"
                    Column {
                        anchors.centerIn: parent
                        Txt { anchors.horizontalCenter: parent.horizontalCenter; text: cell.modelData.name; font.pixelSize: 11
                              color: cell.modelData.today ? Theme.paper : Theme.muted }
                        Txt { anchors.horizontalCenter: parent.horizontalCenter; text: cell.modelData.day; font.pixelSize: 16
                              color: cell.modelData.today ? Theme.paper : Theme.ink }
                    }
                }
            }
        }
        Rectangle { width: parent.width; height: 1; color: Theme.rule }

        Column {   // tiles
            width: parent.width; spacing: 2
            Row {
                spacing: 2
                Tile { width: (root.w - 2) * 2 / 3; title: "Wi-Fi"; detail: Network.connected ? Network.ssid : ""
                       on: Network.enabled; accent: Theme.pine; onClicked: Network.setEnabled(!Network.enabled) }
                Tile { width: (root.w - 2) / 3; title: "Bluetooth"
                       on: Bt.on; accent: Theme.indigo
                       onClicked: Bt.toggle() }
            }
            Row {
                spacing: 2
                Tile { width: (root.w - 2) / 3; title: Theme.dark ? "Paper" : "Ink"; on: Theme.dark; accent: Theme.ink
                       onClicked: Theme.toggle() }
                Tile { width: (root.w - 2) * 2 / 3; title: "Quiet"; detail: Prefs.quiet ? "no sounds" : ""; on: Prefs.quiet; accent: Theme.ink
                       onClicked: Prefs.quiet = !Prefs.quiet }
            }
            Row {
                spacing: 2
                Tile { width: (root.w - 2) * 2 / 3; title: "Screenshot"; detail: "region, screen or window"
                       onClicked: { Drawer.close(); Niri.screenshotSoon() } }
                Tile { width: (root.w - 2) / 3; title: "Layout"; detail: Niri.layoutName
                       on: Niri.layouts.length > 1; accent: Theme.ochre
                       onClicked: Niri.switchLayout() }
            }
            Txt { text: "Window"; color: Theme.muted; font.pixelSize: 12; topPadding: 4 }
            Row {   // how the focused window is laid out
                spacing: 2
                Repeater {
                    model: [["scroll", "Scroll"], ["tabbed", "Tabbed"], ["float", "Float"], ["full", "Full"], ["max", "Max"]]
                    delegate: Tile {
                        required property var modelData
                        width: (root.w - 8) / 5; titleSize: 13
                        title: modelData[1]
                        on: Niri.activeMode === modelData[0]
                        accent: Theme.indigo
                        onClicked: { Niri.windowMode(modelData[0]); Drawer.close() }
                    }
                }
            }
        }

        Column {   // sliders
            width: parent.width; spacing: 2
            BlockSlider { width: parent.width; label: "Sound"; value: Audio.volume * 100; onMoved: v => Audio.setVolume(v) }
            BlockSlider { width: parent.width; label: "Light"; value: Brightness.percent; onMoved: v => Brightness.set(v) }
            BlockSlider { visible: KeyLight.available; width: parent.width; label: "Keys"
                          value: KeyLight.percent; onMoved: v => KeyLight.set(v) }
            Txt { visible: !Brightness.available || Brightness.error !== ""
                  width: parent.width; wrapMode: Text.WordWrap; topPadding: 4
                  text: Brightness.error !== "" ? Brightness.error : "Light needs brightnessctl and the video group."
                  color: Theme.red; font.pixelSize: 12 }
        }
        Rectangle { width: parent.width; height: 1; color: Theme.rule }

        Item {   // Timer
            width: parent.width; height: 18
            Txt { text: "Timer"; color: Theme.muted; font.pixelSize: 12 }
            Mono { anchors.right: parent.right; font.pixelSize: 12
                   visible: Countdown.running || Countdown.ringing
                   text: Countdown.ringing ? "time is off" : Countdown.fmt(Countdown.remaining)
                   color: Countdown.ringing ? Theme.red : Theme.ink }
        }
        Row {
            spacing: 2
            Repeater {
                model: [5, 10, 25]
                delegate: Tile {
                    required property int modelData
                    width: (root.w - 6) / 4; titleSize: 13
                    title: modelData + " min"
                    on: Countdown.running && Countdown.total === modelData * 60
                    accent: Theme.ochre
                    onClicked: Countdown.start(modelData)
                }
            }
            Tile { width: (root.w - 6) / 4; titleSize: 13; title: Countdown.ringing ? "Silence" : "Stop"
                   on: Countdown.ringing; accent: Theme.red; onClicked: Countdown.stop() }
        }

        Txt { text: "Playing"; color: Theme.muted; font.pixelSize: 12; topPadding: 4 }
        Column {
            width: parent.width
            Txt { width: parent.width; elide: Text.ElideRight; font.pixelSize: 15
                  text: Player.active ? (Player.title || "Unknown track") : "Nothing playing"
                  color: Player.active ? Theme.ink : Theme.muted }
            Txt { visible: Player.active && Player.artist !== ""; width: parent.width; elide: Text.ElideRight
                  text: Player.artist; color: Theme.muted; font.pixelSize: 12 }
        }
        Row {
            spacing: 2
            Tile { width: (root.w - 4) / 3; titleSize: 13; title: "Previous"; onClicked: Player.previous() }
            Tile { width: (root.w - 4) / 3; titleSize: 13; title: Player.playing ? "Pause" : "Play"
                   on: Player.playing; accent: Theme.pine; onClicked: Player.toggle() }
            Tile { width: (root.w - 4) / 3; titleSize: 13; title: "Next"; onClicked: Player.next() }
        }
        Rectangle { width: parent.width; height: 1; color: Theme.rule }

        Item {   // Notes
            width: parent.width; height: 18
            Txt { text: "Notes"; color: Theme.muted; font.pixelSize: 12 }
            Txt {
                visible: Notifs.count > 0
                anchors.right: parent.right
                text: "Clear"; color: Theme.muted; font.pixelSize: 12
                MouseArea { cursorShape: Qt.PointingHandCursor; anchors { fill: parent; margins: -6 } onClicked: Notifs.clearAll() }
            }
        }
        Txt { visible: Notifs.count === 0; width: parent.width; horizontalAlignment: Text.AlignHCenter; topPadding: 6
              wrapMode: Text.WordWrap; font.pixelSize: Notifs.conflict ? 12 : 15
              text: Notifs.conflict ? "Notifications are being handled by " + Notifs.owner + ". Stop it to receive them here." : "Nothing waiting"
              color: Notifs.conflict ? Theme.red : Theme.muted }
        Item {   // every notification, newest first; scrolls when they do not all fit
            id: notesBox
            width: parent.width
            visible: Notifs.count > 0
            height: visible ? Math.max(0, Math.min(notesList.contentHeight, 150, root.height - (notesCol.y + y) - 16)) : 0
            ListView {
                id: notesList
                anchors.fill: parent
                model: Notifs.newest
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                delegate: NoteRow { required property var modelData; note: modelData; pad: 0; width: ListView.view.width }
            }
            Rectangle {   // scrollbar, only when something is hidden
                visible: notesList.contentHeight > notesList.height + 1
                x: parent.width - 3; width: 3
                y: notesList.visibleArea.yPosition * notesList.height
                height: Math.max(16, notesList.visibleArea.heightRatio * notesList.height)
                color: Theme.ink
            }
        }
    }
}
