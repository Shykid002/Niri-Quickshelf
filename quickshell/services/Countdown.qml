pragma Singleton
import QtQuick
import Quickshell
import qs.services

// The timer in the Day tab. When it runs out it beeps (4 rounds, every 4.5 s) until you press Silence.
// The alarm ignores Quiet: a timer you set should still ring.
Singleton {
    id: root
    property int total: 0
    property int remaining: 0
    property bool running: false
    property bool ringing: false
    property double endAt: 0
    property int rounds: 0

    function fmt(s) { const m = Math.floor(s / 60), r = s % 60; return (m < 10 ? "0" : "") + m + ":" + (r < 10 ? "0" : "") + r }
    function start(minutes) {
        stop();
        total = minutes * 60; remaining = total; endAt = Date.now() + total * 1000;
        running = true; tick.start();
    }
    function stop() { running = false; ringing = false; tick.stop(); ring.stop(); rounds = 0 }
    function finish() {
        tick.stop(); running = false; ringing = true; rounds = 1;
        Sounds.play("alarm", true); ring.restart();
    }

    Timer {
        id: tick; interval: 250; repeat: true
        onTriggered: { root.remaining = Math.max(0, Math.ceil((root.endAt - Date.now()) / 1000)); if (root.remaining <= 0) root.finish() }
    }
    Timer {
        id: ring; interval: 4500; repeat: true
        onTriggered: { if (root.rounds >= 4) { ring.stop(); return; } root.rounds++; Sounds.play("alarm", true) }
    }
}
