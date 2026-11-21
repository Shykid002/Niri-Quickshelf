import QtQuick
import qs

// Monospace, for literal strings only: SSIDs, device names, status values.
Text {
    color: Theme.ink
    font.family: Theme.mono
    font.pixelSize: Theme.size - 2
    renderType: Text.QtRendering
    verticalAlignment: Text.AlignVCenter
}
