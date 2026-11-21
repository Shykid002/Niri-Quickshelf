import QtQuick
import qs
import qs.components
import qs.services

// Five colour tabs filling the height. The tab under the pointer (or the keyboard cursor)
// grows to 1.7x the others; the rest share what is left. Labels are rotated and sit at the
// bottom of their tab. Destructive actions need a second click ("Power off?").
FocusScope {
    id: root
    focus: true

    readonly property var actions: Leaves.items.slice(1)         // Lock, Suspend, Log out, Restart, Power off
    readonly property var colors: [Theme.ink, Theme.indigo, Theme.ochre, Theme.pine, Theme.red]
    readonly property real grow: 1.7
    property int cur: 0                                          // frame at 0:50 opens with the first tab grown
    property int armed: -1

    onCurChanged: armed = -1
    Timer { id: disarm; interval: 3000; onTriggered: root.armed = -1 }

    function run(i) {
        const a = root.actions[i];
        if (!a) return;
        if (Prefs.confirmPower && i >= 2 && root.armed !== i) { root.armed = i; disarm.restart(); return; }   // confirm for Log out / Restart / Power off
        Session.close();
        a.run();
    }

    Keys.onUpPressed:     root.cur = Math.max(0, root.cur - 1)
    Keys.onDownPressed:   root.cur = Math.min(root.actions.length - 1, root.cur + 1)
    Keys.onReturnPressed: root.run(root.cur)
    Keys.onEnterPressed:  root.run(root.cur)
    Keys.onEscapePressed: Session.close()

    Column {
        anchors.fill: parent
        Repeater {
            model: root.actions
            delegate: Rectangle {
                id: tab
                required property var modelData
                required property int index
                width: parent.width
                height: root.height * (root.cur === index ? root.grow : 1) / (root.actions.length - 1 + root.grow)
                color: root.colors[index]
                Behavior on height { NumberAnimation { duration: 140 * Prefs.speed; easing.type: Easing.OutCubic } }

                Txt {
                    text: root.armed === tab.index ? tab.modelData.label + "?" : tab.modelData.label
                    color: Theme.paper; font.pixelSize: 17
                    rotation: -90; transformOrigin: Item.TopLeft      // reads bottom to top
                    x: 20; y: tab.height - 14
                }
                Item {
                    anchors { fill: parent; margins: 8 }
                    Bracket { active: root.cur === tab.index; color: Theme.paper }
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: root.cur = tab.index
                    onClicked: root.run(tab.index)
                }
            }
        }
    }
}
