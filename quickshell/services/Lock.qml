pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pam

// Lock state + password check through PAM (pam/password.conf).
Singleton {
    id: root
    property bool locked: false
    readonly property int idleMinutes: Prefs.lockMinutes   // 0 = never (Settings > Session)
    property string buffer: ""        // what has been typed
    property bool busy: false         // PAM is checking
    property bool failed: false       // last attempt was wrong

    function lock() {
        Drawer.close(); Session.close(); Popups.close();
        buffer = ""; failed = false; busy = false;
        locked = true;
    }
    function submit() {
        if (!locked || busy || buffer === "") return;
        busy = true; failed = false;
        pam.start();
    }

    PamContext {
        id: pam
        configDirectory: Quickshell.shellDir + "/pam"
        config: "password.conf"
        onPamMessage: { if (pam.responseRequired) pam.respond(root.buffer) }
        onCompleted: result => {
            root.busy = false;
            root.buffer = "";
            if (result === PamResult.Success) root.locked = false;
            else root.failed = true;
        }
    }
}
