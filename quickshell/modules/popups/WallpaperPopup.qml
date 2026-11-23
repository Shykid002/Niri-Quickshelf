import QtQuick
import qs
import qs.components
import qs.services
import qs.modules.wallpaper

// Opened from the bar's wallpaper button: all designs, with live scrollable thumbnails.
// The pick is remembered separately for the paper theme and for the ink theme.
PopupFrame {
    id: root
    readonly property int current: Theme.dark ? Prefs.wallpaperInk : Prefs.wallpaperPaper
    function pick(i) {
        Prefs.wallpaperPaper = i;
        Prefs.wallpaperInk = i;
    }

    Item {
        width: parent.width; height: 45
        Txt { x: 22; anchors.verticalCenter: parent.verticalCenter; text: "Wallpaper"; font.pixelSize: 17 }
        Mono { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
               text: Theme.dark ? "for ink" : "for paper"; color: Theme.muted; font.pixelSize: 12 }
    }
    Rectangle { width: parent.width; height: 1; color: Theme.rule }

    Flickable {
        id: listView
        width: parent.width
        height: Math.min(listCol.implicitHeight, 560)
        contentWidth: width
        contentHeight: listCol.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: listCol
            width: listView.width

            Repeater {
                model: ["Cover", "Spines", "Quiet", "Grid", "Verse", "Index", "Colophon", "Spread", "Monolith", "Bauhaus", "Swiss"]
                delegate: ListRow {
                    id: row
                    required property int index
                    required property string modelData
                    rowHeight: 106
                    onClicked: root.pick(index)

                    Item {
                        x: 22; y: 8; width: 144; height: 90; clip: true
                        WpDesign { anchors.fill: parent; index: row.index }
                        Rectangle { anchors.fill: parent; color: "transparent"; border { width: 1; color: Theme.rule } }
                    }
                    Square { x: 184; y: 30; filled: root.current === row.index }
                    Txt { x: 204; y: 22; text: row.modelData; font.pixelSize: 17 }
                    Txt { x: 204; y: 50; text: root.current === row.index ? "active" : "No. " + (row.index + 1)
                          color: Theme.muted; font.pixelSize: 12 }
                }
            }
        }

        // Minimal editorial scrollbar thumb
        Rectangle {
            visible: listView.contentHeight > listView.height
            anchors.right: parent.right
            anchors.rightMargin: 5
            width: 3
            y: listView.visibleArea.yPosition * listView.height
            height: Math.max(24, listView.visibleArea.heightRatio * listView.height)
            color: Theme.muted
            opacity: listView.moving ? 0.9 : 0.45
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    Item { width: parent.width; height: 8 }
}

