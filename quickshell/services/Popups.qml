pragma Singleton
import QtQuick
import Quickshell

// Which bar popup is open, on which screen, and how far from the right edge it hangs.
Singleton {
    property string current: ""          // "" | "net" | "sound"
    property string screenName: ""
    property real offset: 0              // px from the screen's right edge to the button's right edge

    function toggle(name, screen, rightOffset) {
        if (current === name && screenName === screen.name) { current = ""; return; }
        Drawer.close();
        Session.close();
        current = name; screenName = screen.name; offset = Math.max(0, rightOffset);
        if (name === "net") Network.refresh(true);
    }
    function close() { current = "" }
}
