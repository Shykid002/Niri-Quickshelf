pragma Singleton
import QtQuick
import Quickshell

// State of the right-hand drawer (Index = launcher, Day = overview).
Singleton {
    property bool open: false
    property string tab: "day"            // "index" | "day"
    property string screenName: ""

    function openOn(tabName, name) {
        if (open && tab === tabName && screenName === name) { open = false; return; }
        Popups.close();
        Session.close();
        tab = tabName; screenName = name; open = true;
    }
    function toggle(tabName, screen) { openOn(tabName, screen.name) }
    function toggleDefault(tabName) {   // for IPC / keybinds: use niri's focused output
        openOn(tabName, Niri.focusedOutput || (Quickshell.screens.length ? Quickshell.screens[0].name : ""));
    }
    function close() { open = false }
}
