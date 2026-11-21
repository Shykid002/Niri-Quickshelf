import QtQuick
import qs
import qs.components
import qs.services

// The drawer itself: red tab + ink spine with the rotated date, tab strip, content.
Item {
    id: root
    readonly property real spineW: 32
    readonly property real tabH: 33

    Rectangle { x: root.spineW; width: parent.width - root.spineW; height: parent.height; color: Theme.paper }

    Rectangle {   // spine
        width: root.spineW; height: parent.height; color: Theme.ink
        Rectangle { width: parent.width; height: root.tabH; color: Theme.cover }
        Txt {
            text: Almanac.weekday + " " + Almanac.day + " " + Almanac.monthName
            color: Theme.paper; font.pixelSize: 13
            rotation: 90; transformOrigin: Item.TopLeft
            x: (root.spineW + implicitHeight) / 2; y: 50
        }
    }

    Row {   // tabs
        x: root.spineW; height: root.tabH
        Repeater {
            model: [{ id: "index", label: "Index" }, { id: "day", label: "Day" }]
            delegate: Rectangle {
                id: tab
                required property var modelData
                readonly property bool active: Drawer.tab === modelData.id
                width: (root.width - root.spineW) / 2; height: root.tabH
                color: active ? Theme.ink : "transparent"
                Txt { x: 20; anchors.verticalCenter: parent.verticalCenter; text: tab.modelData.label; font.pixelSize: 15
                      color: tab.active ? Theme.paper : Theme.muted }
                Txt { visible: tab.modelData.id === "index"
                      anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                      text: (Sessions.count > 1 ? Sessions.count : "I") + " working"; font.pixelSize: 12
                      color: tab.active ? Theme.paper : Theme.muted }
                Bracket { active: tabArea.containsMouse && !tab.active; color: Theme.ink }
                MouseArea { id: tabArea; anchors.fill: parent; hoverEnabled: true; onClicked: Drawer.tab = tab.modelData.id }
            }
        }
    }
    Rectangle { x: root.spineW; y: root.tabH; width: parent.width - root.spineW; height: 1; color: Theme.rule }

    Loader {
        x: root.spineW; y: root.tabH + 1
        width: parent.width - root.spineW; height: parent.height - root.tabH - 1
        sourceComponent: Drawer.tab === "index" ? indexTab : dayTab
    }
    Component { id: indexTab; IndexTab {} }
    Component { id: dayTab;   DayTab {} }

    Item {   // Esc closes from the Day tab too
        focus: Drawer.tab === "day"
        Keys.onEscapePressed: Drawer.close()
    }
}
