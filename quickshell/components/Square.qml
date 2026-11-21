import QtQuick
import qs

// Marker: hollow = unselected / off, filled = selected / on.
Rectangle {
    property bool filled: false
    property color tone: Theme.ink
    width: 8; height: 8
    color: filled ? tone : "transparent"
    border { width: 1; color: tone }
}
