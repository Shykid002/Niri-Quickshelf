import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Mod+/ opens the keybinding list:  qs -c rice ipc call keys toggle
Scope {
    IpcHandler {
        target: "keys"
        function toggle(): void { Binds.toggle() }
        function open(): void   { if (!Binds.open) Binds.toggle() }
        function close(): void  { Binds.close() }
    }
    LazyLoader { active: Binds.open; BindsWindow {} }
}
