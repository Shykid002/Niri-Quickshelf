pragma Singleton
import QtQuick
import Quickshell
import qs

// Session actions shown in the launcher. The label for the theme switch names the other theme.
Singleton {
    readonly property var items: [
        { label: Theme.dark ? "Turn to paper" : "Turn to ink", run: () => Theme.toggle() },
        { label: "Lock",      run: () => Lock.lock() },
        { label: "Suspend",   run: () => Quickshell.execDetached(["systemctl", "suspend"]) },
        { label: "Log out",   run: () => Quickshell.execDetached(["niri", "msg", "action", "quit", "--skip-confirmation"]) },
        { label: "Restart",   run: () => Quickshell.execDetached(["systemctl", "reboot"]) },
        { label: "Power off", run: () => Quickshell.execDetached(["systemctl", "poweroff"]) }
    ]
}
