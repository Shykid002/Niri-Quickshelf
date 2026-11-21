import QtQuick
import qs
import qs.components
import qs.services

// Album art, title, spectrum, progress, controls, and a scrolling "recently played" list.
// Keys: Space play/pause, Left/Right previous/next, P the list, Esc closes.
FocusScope {
    id: root
    focus: true
    width: 760
    readonly property real cardTop: 352
    property real listH: Music.showList ? 280 : 0
    Behavior on listH { NumberAnimation { duration: 200 * Prefs.speed; easing.type: Easing.OutCubic } }
    height: cardTop + listH

    readonly property var p: Music.player
    readonly property real frac: p && p.length > 0 ? Math.max(0, Math.min(1, p.position / p.length)) : 0
    function fmt(s) { s = Math.max(0, Math.floor(s || 0)); const m = Math.floor(s / 60), r = s % 60; return m + ":" + (r < 10 ? "0" : "") + r }
    function seek(x, w) { if (p && p.canSeek && p.length > 0) p.position = Math.max(0, Math.min(1, x / w)) * p.length }

    Keys.onEscapePressed: Music.close()
    Keys.onSpacePressed: Music.playPause()
    Keys.onLeftPressed: Music.prev()
    Keys.onRightPressed: Music.next()
    Keys.onPressed: event => { if (event.key === Qt.Key_P) { Music.showList = !Music.showList; event.accepted = true } }

    Timer {   // the player only tells us the position when asked
        interval: 500; repeat: true; running: Music.playing && Music.open
        onTriggered: { if (root.p) root.p.positionChanged() }
    }

    // one square control
    component Btn: Item {
        id: btn
        property string kind: "play"
        property bool on: false
        property real box: 44
        signal clicked()
        width: box; height: box
        Rectangle { anchors.fill: parent; color: btn.on ? Theme.ink : "transparent" }
        Glyph { anchors.centerIn: parent; kind: btn.kind; px: btn.box * 0.46; tone: btn.on ? Theme.paper : Theme.ink }
        Bracket { active: area.containsMouse && !btn.on }
        MouseArea { id: area; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: btn.clicked() }
    }

    Rectangle { anchors.fill: parent; color: Theme.paper; border { width: 1; color: Theme.ink } }

    // ── album art ──
    Rectangle {
        x: 28; y: 28; width: 296; height: 296
        color: Theme.block; border { width: 1; color: Theme.rule }
        Image {
            id: img
            anchors { fill: parent; margins: 1 }
            source: root.p ? String(root.p.trackArtUrl || "") : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: status === Image.Ready
        }
        Glyph { visible: img.status !== Image.Ready; anchors.centerIn: parent; kind: "music"; px: 96; tone: Theme.muted }
    }

    // ── right column ──
    Item {
        x: 356; y: 0; width: root.width - 356 - 28; height: root.cardTop

        Txt { y: 26; text: root.p ? (root.p.identity || "Player") : "Music"; color: Theme.muted; font.pixelSize: 12 }
        Txt { y: 46; width: parent.width; elide: Text.ElideRight; font.pixelSize: 30
              text: root.p ? (root.p.trackTitle || "Nothing playing") : "Nothing playing" }
        Txt { y: 90; width: parent.width; elide: Text.ElideRight; font.pixelSize: 17; color: Theme.muted
              text: root.p ? (root.p.trackArtist || "") : "Open Spotify and play something" }
        Txt { y: 116; width: parent.width; elide: Text.ElideRight; font.pixelSize: 13; color: Theme.muted
              text: root.p ? (root.p.trackAlbum || "") : "" }

        // spectrum: 40 solid bars, four palette colours like book spines, with slow-falling peaks
        Item {
            id: viz
            y: 148; width: parent.width; height: 84
            readonly property real bw: (width - 3 * (Viz.count - 1)) / Viz.count
            Repeater {
                model: Viz.count
                delegate: Item {
                    id: bar
                    required property int index
                    x: index * (viz.bw + 3); width: viz.bw; height: viz.height
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: Math.max(2, (Viz.bars[bar.index] || 0) / 100 * viz.height)
                        color: [Theme.cover, Theme.ochre, Theme.pine, Theme.indigo][Math.floor(bar.index / 10)]
                        Behavior on height { NumberAnimation { duration: 60 } }
                    }
                    Rectangle {   // peak cap
                        width: parent.width; height: 2; color: Theme.ink
                        y: viz.height - Math.max(2, (Viz.peaks[bar.index] || 0) / 100 * viz.height) - 4
                        visible: (Viz.peaks[bar.index] || 0) > 3
                    }
                }
            }
            Rectangle { y: parent.height + 1; width: parent.width; height: 1; color: Theme.ink }
        }
        Txt { visible: !Viz.hasCava && Music.playing; y: 236; font.pixelSize: 11; color: Theme.muted
              text: "simulated spectrum, install cava for the real one" }

        // progress
        Item {
            y: 250; width: parent.width; height: 20
            Rectangle { y: 7; width: parent.width; height: 6; color: Theme.rule }
            Rectangle { y: 7; height: 6; color: Theme.ink; width: parent.width * root.frac }
            MouseArea {
                anchors { fill: parent; topMargin: -6; bottomMargin: -6 }
                cursorShape: Qt.PointingHandCursor
                onPressed: mouse => root.seek(mouse.x, width)
                onPositionChanged: mouse => { if (pressed) root.seek(mouse.x, width) }
            }
        }
        Mono { y: 272; text: root.fmt(root.p ? root.p.position : 0); color: Theme.muted; font.pixelSize: 11 }
        Mono { y: 272; anchors.right: parent.right; text: root.fmt(root.p ? root.p.length : 0); color: Theme.muted; font.pixelSize: 11 }

        // controls
        Row {
            y: 292; spacing: 14
            Btn { kind: "prev"; onClicked: Music.prev() }
            Btn { kind: Music.playing ? "pause" : "play"; box: 52; on: true; onClicked: Music.playPause() }
            Btn { kind: "next"; onClicked: Music.next() }
        }
        Btn { anchors.right: parent.right; y: 292; kind: "list"; on: Music.showList; onClicked: Music.showList = !Music.showList }
    }

    // ── recently played (scrolls) ──
    Item {
	    y: root.cardTop; width: root.width; height: root.listH
        clip: true
        visible: root.listH > 1

        Rectangle { x: 28; width: parent.width - 56; height: 1; color: Theme.rule }
        Txt { x: 28; y: 14; text: "Recently played"; color: Theme.muted; font.pixelSize: 12 }
        Txt {
            anchors { right: parent.right; rightMargin: 28 } y: 14
            visible: Music.history.length > 0
            text: "Clear"; color: Theme.muted; font.pixelSize: 12
            MouseArea { anchors { fill: parent; margins: -6 } cursorShape: Qt.PointingHandCursor; onClicked: Music.clearHistory() }
        }
        Txt {
            visible: Music.history.length === 0
            x: 28; y: 54; width: parent.width - 56; wrapMode: Text.WordWrap; color: Theme.muted; font.pixelSize: 14
            text: "Tracks you play will appear here. Spotify does not share its playlists with other programs, so this is the list of what has played."
        }
        ListView {
            id: list
            x: 28; y: 38; width: parent.width - 56; height: root.listH - 38 - 12
            model: Music.history
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            delegate: Item {
                id: row
                required property var modelData
                required property int index
                readonly property bool current: !!root.p && root.p.trackTitle === modelData.title && (root.p.trackArtist || "") === modelData.artist
                width: ListView.view.width - 10; height: 48

                Mono { x: 0; anchors.verticalCenter: parent.verticalCenter; width: 26; text: row.index + 1; color: Theme.muted; font.pixelSize: 11 }
                Rectangle {
                    x: 32; y: 6; width: 36; height: 36; color: Theme.block
                    Image { anchors.fill: parent; source: row.modelData.art || ""; fillMode: Image.PreserveAspectCrop; asynchronous: true }
                }
                Txt { x: 80; y: 6; width: parent.width - 80 - 70; text: row.modelData.title; font.pixelSize: 15; elide: Text.ElideRight
                      color: row.current ? Theme.cover : Theme.ink }
                Txt { x: 80; y: 26; width: parent.width - 80 - 70; text: row.modelData.artist; font.pixelSize: 12; color: Theme.muted; elide: Text.ElideRight }
                Mono { anchors { right: parent.right; rightMargin: 4 } anchors.verticalCenter: parent.verticalCenter
                       text: row.current ? "playing" : root.fmt(row.modelData.length); color: Theme.muted; font.pixelSize: 11 }
                Bracket { active: rowArea.containsMouse && row.modelData.uri !== "" }
                MouseArea {
                    id: rowArea; anchors.fill: parent; hoverEnabled: true
                    cursorShape: row.modelData.uri !== "" ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: Music.playUri(row.modelData.uri)
                }
            }
        }
        Rectangle {   // scrollbar, only when something is hidden
            visible: list.contentHeight > list.height + 1
            x: parent.width - 28 - 3; width: 3
            y: list.y + list.visibleArea.yPosition * list.height
            height: Math.max(16, list.visibleArea.heightRatio * list.height)
            color: Theme.ink
        }
    }
}
