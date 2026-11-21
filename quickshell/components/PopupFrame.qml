import QtQuick
import qs

// Bordered, square-cornered card for bar popups. Children stack vertically.
Rectangle {
    default property alias content: col.data
    color: Theme.paper
    border { width: 1; color: Theme.ink }
    implicitWidth: 356
    implicitHeight: col.implicitHeight + 2

    Column { id: col; x: 1; y: 1; width: parent.width - 2 }
}
