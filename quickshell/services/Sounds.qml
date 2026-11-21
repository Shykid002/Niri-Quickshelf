pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.services

// Small feedback sounds (generated WAV files in assets/sounds, played with pw-play or paplay):
//   charger plugged in / out, a tick when the volume changes, and the timer alarm.
// Quiet (Day tab) mutes everything here except the timer alarm.
Singleton {
    id: root
    function start() {}
    property bool ready: false
    readonly property string dir: Quickshell.shellDir + "/assets/sounds/"

    function play(name, always) {
        if (Prefs.quiet && !always) return;
        Quickshell.execDetached(["sh", "-c", 'pw-play "$1" 2>/dev/null || paplay "$1" 2>/dev/null', "sh", dir + name + ".wav"]);
    }

    Timer { interval: 2500; running: true; onTriggered: root.ready = true }      // no sounds for the start-up values

    Connections {
        target: UPower
        function onOnBatteryChanged() { if (root.ready) root.play(UPower.onBattery ? "unplug" : "plug") }
    }
    Connections {
        target: Audio
        function onVolumeChanged() { if (root.ready && !gate.running) { root.play("tick"); gate.start() } }
    }
    Timer { id: gate; interval: 140 }                                            // at most one tick per 140 ms
}
