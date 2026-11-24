pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool open: false
    property string screenName: ""
    property string layout: "US"     // "US" or "ARA"
    property bool symbols: false     // false = letters, true = ?123 special characters
    property bool shifted: false
    property bool caps: false

    function toggle(scr) {
        if (open && (!scr || screenName === scr.name)) {
            open = false;
        } else {
            if (scr) screenName = scr.name;
            open = true;
        }
    }

    function toggleLayout() {
        layout = (layout === "US") ? "ARA" : "US";
        symbols = false;
        shifted = false;
        Quickshell.execDetached(["niri", "msg", "action", "switch-layout", "next"]);
    }

    function toggleSymbols() {
        symbols = !symbols;
        shifted = false;
    }

    function sendText(ch) {
        Quickshell.execDetached(["wtype", "--", ch]);
        if (shifted && !caps) shifted = false;
    }

    function sendKey(keyName) {
        Quickshell.execDetached(["wtype", "-k", keyName]);
    }
}
