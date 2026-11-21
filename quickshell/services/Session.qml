pragma Singleton
import QtQuick
import Quickshell

// State of the session panel (Lock / Suspend / Log out / Restart / Power off).
Singleton {
    property bool open: false
    property string screenName: ""

    function toggle(screen) {
        if (open && screenName === screen.name) { open = false; return; }
        Drawer.close();
        Popups.close();
        screenName = screen.name; open = true;
    }
    function close() { open = false }
}
