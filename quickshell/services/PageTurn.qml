pragma Singleton
import QtQuick
import Quickshell
import qs

// Theme-change transition. A flat page of the NEW theme's paper colour covers the screen,
// the theme flips while it is fully covered, then the page leaves. No fades, no gradients.
//   held : page sweeps in from the right, rests, sweeps out to the left
//   leaf : the same sweep, quick, no rest
//   ink  : a square grows from the toggle button until it covers the screen, rests, shrinks back
//   none : instant
Singleton {
    id: root

    property bool running: false
    property real phase: 0                 // 0 -> 1 covering, 1 -> 2 revealing
    property string mode: "held"
    property color pageColor: "#000000"
    property bool target: false            // theme the flip will switch to
    property real originX: -1
    property real originY: -1
    property string originScreen: ""

    property int dIn: 260
    property int dHold: 220
    property int dOut: 260

    function start(toDark, ox, oy, screenName) {
        if (running) return;
        mode = Prefs.themeChange;
        if (mode === "none") { Theme.apply(toDark); return; }

        target = toDark;
        pageColor = toDark ? Theme.darkP.paper : Theme.light.paper;
        originX = ox === undefined ? -1 : ox;
        originY = oy === undefined ? -1 : oy;
        originScreen = screenName || "";

        const sp = Prefs.speed;
        if (mode === "leaf")      { dIn = 150 * sp; dHold = 0;                          dOut = 170 * sp; }
        else if (mode === "ink")  { dIn = 340 * sp; dHold = Theme.transitionHold * sp;  dOut = 300 * sp; }
        else                      { dIn = 260 * sp; dHold = Theme.transitionHold * sp;  dOut = 280 * sp; }   // held

        phase = 0;
        running = true;
        failsafe.interval = dIn + dHold + dOut + 1500;
        failsafe.restart();
        anim.restart();
    }

    SequentialAnimation {
        id: anim
        NumberAnimation { target: root; property: "phase"; from: 0; to: 1; duration: root.dIn; easing.type: Easing.InOutCubic }
        ScriptAction { script: Theme.apply(root.target) }
        PauseAnimation { duration: root.dHold }
        NumberAnimation { target: root; property: "phase"; from: 1; to: 2; duration: root.dOut; easing.type: Easing.InOutCubic }
        ScriptAction { script: { failsafe.stop(); root.running = false } }
    }

    // If anything goes wrong, never leave the overlay up.
    Timer {
        id: failsafe
        onTriggered: { anim.stop(); Theme.apply(root.target); root.running = false }
    }
}
