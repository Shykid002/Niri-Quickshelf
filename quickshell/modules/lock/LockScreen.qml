import QtQuick
import qs
import qs.components
import qs.services

// One lock surface per screen. Nothing of the shell shows while locked.
// Red block left (same in both themes), clock and underline field right.
// Layout measured from the reference frame: units u = screenHeight / 900.
Rectangle {
    id: root
    color: Theme.paper
    focus: true
    readonly property real u: height / 900

    Keys.onPressed: event => {
        if (Lock.busy) { event.accepted = true; return; }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) Lock.submit();
        else if (event.key === Qt.Key_Backspace) { Lock.failed = false; Lock.buffer = Lock.buffer.slice(0, -1); }
        else if (event.key === Qt.Key_Escape) { Lock.failed = false; Lock.buffer = ""; }
        else if (event.text.length > 0 && event.text.charCodeAt(0) >= 32
                 && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier))) {
            Lock.failed = false; Lock.buffer += event.text;
        }
        event.accepted = true;
    }
    Component.onCompleted: forceActiveFocus()

    // ── left block ──
    Rectangle {
        width: 459 * root.u; height: parent.height
        color: Theme.cover

        Txt {   // reads top to bottom
            visible: Prefs.verse
            text: "The quiet hours"
            color: Theme.paper; font.pixelSize: 40 * root.u
            rotation: 90; transformOrigin: Item.TopLeft
            x: 61 * root.u + implicitHeight; y: 68 * root.u
        }
        Txt {
            text: "Locked"; color: Theme.paper; font.pixelSize: 17 * root.u
            x: 62 * root.u; y: parent.height - 62 * root.u - implicitHeight
        }
    }

    // ── clock ──
    Row {
        x: 596 * root.u; y: 428 * root.u - 180 * root.u * 0.74
        spacing: 0
        Txt { text: Almanac.timeText.slice(0, 2); font.pixelSize: 180 * root.u }
        Txt { text: ":"; font.pixelSize: 180 * root.u
              color: Qt.tint(Theme.paper, Qt.rgba(Theme.cover.r, Theme.cover.g, Theme.cover.b, 0.45)) }   // dim colon
        Txt { text: Almanac.timeText.slice(3, 5); font.pixelSize: 180 * root.u }
    }
    Txt {
        x: 592 * root.u; y: 514 * root.u - implicitHeight * 0.75
        text: Almanac.weekday + ", " + Almanac.day + " " + Almanac.monthName
        font.pixelSize: 30 * root.u
    }

    // ── password field: sits between the date and the line (the cursor square in the frame was at y=580) ──
    Row {
        id: field
        x: 592 * root.u; y: 580 * root.u - height / 2
        height: 26
        spacing: 8
        Repeater {
            model: Math.min(Lock.buffer.length, 28)
            delegate: Item {
                width: 10; height: 26
                Rectangle { anchors.centerIn: parent; width: 10; height: 10; color: Theme.ink }
            }
        }
        Rectangle { width: 2; height: 26; color: Theme.cover }      // caret
    }
    Txt {   // hint while empty
        visible: Lock.buffer.length === 0 && !Lock.busy
        x: 592 * root.u + 16; y: 580 * root.u - implicitHeight / 2
        text: "Password"; color: Theme.muted; font.pixelSize: 22 * root.u
    }
    Rectangle {
        x: 592 * root.u; y: 623 * root.u
        width: 318 * root.u; height: 1
        color: Lock.failed ? Theme.red : Theme.ink
    }
    Txt {
        x: 592 * root.u; y: 623 * root.u + 10 * root.u
        visible: Lock.failed || Lock.busy
        text: Lock.busy ? "…" : "Not recognised"
        color: Lock.failed ? Theme.red : Theme.muted; font.pixelSize: 14 * root.u
    }

    Txt {
        anchors { right: parent.right; rightMargin: 60 * root.u; bottom: parent.bottom; bottomMargin: 62 * root.u }
        text: "basic · niri"; color: Theme.muted; font.pixelSize: 14 * root.u
    }
}
