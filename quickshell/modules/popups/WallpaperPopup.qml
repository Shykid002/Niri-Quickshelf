import QtQuick
import qs
import qs.components
import qs.services
import qs.modules.wallpaper

// Opened from the bar's wallpaper button: the five designs, with live thumbnails.
// The pick is remembered separately for the paper theme and for the ink theme.
PopupFrame {
    id: root
    readonly property int current: Theme.dark ? Prefs.wallpaperInk : Prefs.wallpaperPaper
    function pick(i) { if (Theme.dark) Prefs.wallpaperInk = i; else Prefs.wallpaperPaper = i }

    Item {
        width: parent.width; height: 45
        Txt { x: 22; anchors.verticalCenter: parent.verticalCenter; text: "Wallpaper"; font.pixelSize: 17 }
        Mono { anchors { right: parent.right; rightMargin: 22; verticalCenter: parent.verticalCenter }
               text: Theme.dark ? "for ink" : "for paper"; color: Theme.muted; font.pixelSize: 12 }
    }
    Rectangle { width: parent.width; height: 1; color: Theme.rule }

    Repeater {
        model: ["Cover", "Spines", "Quiet", "Grid", "Verse"]
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
    Item { width: parent.width; height: 8 }
}
