import QtQuick

// Shows wallpaper design number `index` (0 to 4). Used by the wallpaper window and the picker's thumbnails.
Loader {
    property int index: 0
    sourceComponent: [c0, c1, c2, c3, c4][Math.max(0, Math.min(4, index))]
    Component { id: c0; WpCover {} }
    Component { id: c1; WpSpines {} }
    Component { id: c2; WpQuiet {} }
    Component { id: c3; WpGrid {} }
    Component { id: c4; WpVerse {} }
}
