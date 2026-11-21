import QtQuick
import qs
import qs.components
import qs.services

// Launcher: type to filter applications and session actions. Up/Down, Enter, Esc.
// With an empty search it also lists the running sessions ("1 working").
FocusScope {
    id: root
    readonly property string q: input.text.trim().toLowerCase()
    property int sel: 0

    function selectable(r) { return !!r && (r.kind === "app" || r.kind === "leaf") }

    readonly property var rows: {
        const out = [];
        if (!q && Sessions.count > 0) {
            out.push({ kind: "head", text: "Sessions" });
            for (const s of Sessions.items) out.push({ kind: "session", name: s.title, sub: s.path, minutes: s.minutes });
        }
        const apps = Apps.search(q);
        if (apps.length) {
            out.push({ kind: "head", text: "Applications" });
            for (const a of apps) out.push({ kind: "app", name: a.name, entry: a });
        }
        const leaves = Leaves.items.filter(l => !q || l.label.toLowerCase().indexOf(q) >= 0);
        if (leaves.length) {
            out.push({ kind: "head", text: "Leaves" });
            for (const l of leaves) out.push({ kind: "leaf", name: l.label, leaf: l });
        }
        return out;
    }
    onRowsChanged: { sel = 0; while (sel < rows.length && !selectable(rows[sel])) sel++; }

    function move(d) {
        let i = sel + d;
        while (i >= 0 && i < rows.length && !selectable(rows[i])) i += d;
        if (i >= 0 && i < rows.length) sel = i;
    }
    function activate() {
        const r = rows[sel];
        if (!selectable(r)) return;
        Drawer.close();
        if (r.kind === "app") r.entry.execute(); else r.leaf.run();
    }

    TextInput {
        id: input
        x: 20; y: 16; width: parent.width - 40; height: 44
        focus: true
        font.family: Theme.serif; font.pixelSize: 30
        color: Theme.ink
        verticalAlignment: TextInput.AlignVCenter
        cursorDelegate: Rectangle { width: 2; color: Theme.cover }
        Keys.onUpPressed: root.move(-1)
        Keys.onDownPressed: root.move(1)
        Keys.onEscapePressed: Drawer.close()
        onAccepted: root.activate()
        Component.onCompleted: forceActiveFocus()
    }
    Connections {   // never show what was typed last time
        target: Drawer
        function onOpenChanged() { input.text = ""; if (Drawer.open) input.forceActiveFocus() }
    }
    Rectangle { x: 20; y: 66; width: parent.width - 40; height: 1; color: Theme.ink }

    ListView {
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom; topMargin: 76 }
        model: root.rows
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        delegate: Item {
            id: row
            required property var modelData
            required property int index
            readonly property bool head: modelData.kind === "head"
            readonly property bool sess: modelData.kind === "session"
            readonly property bool pick: !head && !sess
            width: ListView.view.width
            height: head ? 28 : sess ? 46 : 29

            Txt { visible: row.head; x: 20; anchors.bottom: parent.bottom; bottomPadding: 3
                  text: row.modelData.text || ""; color: Theme.muted; font.pixelSize: 12 }

            // running session: ochre square, name, minutes, folder
            Square { visible: row.sess; x: 22; y: 12; tone: Theme.ochre; filled: true }
            Txt { visible: row.sess; x: 52; y: 3; text: row.sess ? row.modelData.name : ""; font.pixelSize: 17
                  elide: Text.ElideRight; width: parent.width - 52 - 80 }
            Txt { visible: row.sess; anchors { right: parent.right; rightMargin: 24 } y: 7
                  text: row.sess ? row.modelData.minutes + " min" : ""; color: Theme.muted; font.pixelSize: 12 }
            Txt { visible: row.sess; x: 52; y: 25; text: row.sess ? row.modelData.sub : ""; color: Theme.muted; font.pixelSize: 12
                  elide: Text.ElideMiddle; width: parent.width - 52 - 24 }

            Txt { visible: row.pick; x: 52; anchors.verticalCenter: parent.verticalCenter
                  textFormat: Text.StyledText; font.pixelSize: 17
                  text: row.pick ? Apps.highlight(row.modelData.name, root.q) : "" }
            Item {
                visible: row.pick
                anchors { fill: parent; leftMargin: 20; rightMargin: 20; topMargin: 1; bottomMargin: 1 }
                Bracket { active: root.sel === row.index }
            }
            MouseArea { cursorShape: Qt.PointingHandCursor;
                anchors.fill: parent; enabled: row.pick; hoverEnabled: true
                onEntered: root.sel = row.index
                onClicked: { root.sel = row.index; root.activate() }
            }
        }
    }
}
