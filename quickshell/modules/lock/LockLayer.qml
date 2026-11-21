import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.services

// Wayland session lock (ext-session-lock). The compositor itself hides everything else.
// Keybind: see niri/keybinds.kdl  (Mod+L)
Scope {
    IpcHandler {
        target: "lock"
        function lock(): void { Lock.lock() }
    }

    // Lock after Lock.idleMinutes of no input. Playing video etc. holds it off (idle inhibitors).
    IdleMonitor {
        enabled: Lock.idleMinutes > 0 && !Lock.locked
        timeout: Lock.idleMinutes * 60
        respectInhibitors: true
        onIsIdleChanged: { if (isIdle) Lock.lock() }
    }

    WlSessionLock {
        locked: Lock.locked
        WlSessionLockSurface {
            color: Theme.paper                      // the surface itself defaults to white
            LockScreen { anchors.fill: parent }     // without a size it collapsed into the top-left corner
        }
    }
}
