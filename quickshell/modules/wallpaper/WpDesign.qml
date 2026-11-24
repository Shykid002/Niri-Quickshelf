import QtQuick

// Shows wallpaper design number `index` (0 to 14). Used by the wallpaper window and the picker's thumbnails.
Loader {
    property int index: 0
    sourceComponent: [c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14][Math.max(0, Math.min(14, index))]
    Component { id: c0;  WpCover {} }
    Component { id: c1;  WpSpines {} }
    Component { id: c2;  WpQuiet {} }
    Component { id: c3;  WpGrid {} }
    Component { id: c4;  WpVerse {} }
    Component { id: c5;  WpIndex {} }
    Component { id: c6;  WpColophon {} }
    Component { id: c7;  WpSpread {} }
    Component { id: c8;  WpMonolith {} }
    Component { id: c9;  WpBauhaus {} }
    Component { id: c10; WpSwiss {} }
    Component { id: c11; WpConstruct {} }
    Component { id: c12; WpBrockmann {} }
    Component { id: c13; WpHarmonic {} }
    Component { id: c14; WpConcentric {} }
}

