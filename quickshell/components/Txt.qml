import QtQuick
import qs

// Serif text with sensible typographic defaults.
Text {
    property bool tabular: true
    color: Theme.ink
    font.family: Theme.serif
    font.pixelSize: Theme.size
    font.features: ({ "lnum": 1, "tnum": tabular ? 1 : 0 })
    renderType: Text.QtRendering
    verticalAlignment: Text.AlignVCenter
}
