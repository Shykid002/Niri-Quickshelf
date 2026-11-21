import QtQuick
import Quickshell
import qs
import qs.components
import qs.services

// Every keybinding, grouped, with what it does. Type to filter. Esc closes. Mouse wheel scrolls.
FloatingWindow {
    id: win
    title: "Keybindings"
    implicitWidth: 880; implicitHeight: 640
    color: Theme.paper
    onVisibleChanged: if (!visible) Binds.close()

    readonly property string q: input.text.trim().toLowerCase()
    readonly property var rows: {
        const out = [];
        for (const g of Binds.groups) {
            const items = g.items.filter(it => !q || (it.key + " " + it.desc + " " + g.name).toLowerCase().indexOf(q) >= 0);
            if (items.length === 0) continue;
            out.push({ head: g.name, n: items.length });
            for (const it of items) out.push({ key: it.key, desc: it.desc });
        }
        return out;
    }
    function scrollBy(d) { list.contentY = Math.max(0, Math.min(Math.max(0, list.contentHeight - list.height), list.contentY + d)) }

    Item {
        anchors.fill: parent
        focus: true

        Rectangle { width: 33; height: 33; color: Theme.cover }
        Txt { x: 53; y: 18; text: "Keybindings"; font.pixelSize: 26 }
        Txt { anchors { right: parent.right; rightMargin: 40; top: parent.top; topMargin: 26 }
              text: Binds.count + " keys"; color: Theme.muted; font.pixelSize: 13; font.features: ({ "onum": 1 }) }
        Rectangle { x: 53; y: 68; width: parent.width - 106; height: 1; color: Theme.ink }

        TextInput {
            id: input
            x: 53; y: 78; width: parent.width - 106; height: 36
            focus: true
            font.family: Theme.serif; font.pixelSize: 22
            color: Theme.ink
            verticalAlignment: TextInput.AlignVCenter
            cursorDelegate: Rectangle { width: 2; color: Theme.cover }
            Keys.onEscapePressed: Binds.close()
            Keys.onDownPressed: win.scrollBy(60)
            Keys.onUpPressed: win.scrollBy(-60)
            Keys.onPressed: event => {
                if (event.key === Qt.Key_PageDown) { win.scrollBy(list.height - 40); event.accepted = true }
                else if (event.key === Qt.Key_PageUp) { win.scrollBy(-(list.height - 40)); event.accepted = true }
            }
            Component.onCompleted: forceActiveFocus()
            Txt { visible: input.text === ""; text: "type to filter, for example: workspace, screenshot, Shift"
                  color: Theme.muted; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
        }
        Rectangle { x: 53; y: 116; width: parent.width - 106; height: 1; color: Theme.rule }

        ListView {
            id: list
            x: 53; y: 124; width: parent.width - 106; height: parent.height - 124 - 44
            model: win.rows
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            delegate: Item {
                id: row
                required property var modelData
                readonly property bool head: modelData.head !== undefined
                width: list.width
                height: head ? 40 : 28

                Txt { visible: row.head; anchors.bottom: parent.bottom; bottomPadding: 4
                      text: row.head ? row.modelData.head : ""; color: Theme.muted; font.pixelSize: 13 }
                Mono { visible: !row.head; anchors.verticalCenter: parent.verticalCenter; width: 300; font.pixelSize: 13
                       text: row.head ? "" : row.modelData.key; elide: Text.ElideRight }
                Txt { visible: !row.head; x: 320; anchors.verticalCenter: parent.verticalCenter; width: parent.width - 320
                      text: row.head ? "" : row.modelData.desc; font.pixelSize: 16; elide: Text.ElideRight }
            }
        }

        Txt {
            x: 53; anchors { bottom: parent.bottom; bottomMargin: 14 }
            text: Binds.error !== "" ? Binds.error
                : win.rows.length === 0 ? "No key matches that."
                : "Read from " + Binds.files.join(", ") + ".  Esc closes."
            color: Binds.error !== "" ? Theme.red : Theme.muted; font.pixelSize: 12
        }
    }
}
