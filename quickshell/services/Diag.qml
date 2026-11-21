pragma Singleton
import QtQuick
import Quickshell

// Problems the shell found while starting (an optional piece that could not load, and why).
// Shown in red at the top of the Day tab, and appended to ~/.config/rice/errors.log.
Singleton {
    property var errors: []
    function report(msg) {
        errors = errors.concat([msg]);
        console.warn("rice: " + msg);
        Quickshell.execDetached(["sh", "-c", 'mkdir -p "$HOME/.config/rice" && printf "%s  %s\\n" "$(date +%F\\ %T)" "$1" >> "$HOME/.config/rice/errors.log"', "sh", msg]);
    }
}
