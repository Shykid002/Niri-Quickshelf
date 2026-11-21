pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth power. Uses the adapter when there is one; if it is missing or refuses (rfkill soft
// block, or no adapter object yet), falls back to rfkill + bluetoothctl.
Singleton {
    id: root
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: !!adapter && adapter.enabled
    property bool want: false

    function toggle() { set(!on) }
    function set(v) {
        want = v;
        if (adapter) adapter.enabled = v; else fallback(v);
        verify.restart();
    }
    function fallback(v) {
        Quickshell.execDetached(["sh", "-c", v ? "rfkill unblock bluetooth; sleep 0.5; bluetoothctl power on"
                                                : "bluetoothctl power off"]);
    }
    // if the adapter did not follow after 1.5 s, push it with the command line tools
    Timer { id: verify; interval: 1500; onTriggered: { if (!root.adapter || root.adapter.enabled !== root.want) root.fallback(root.want) } }
}
