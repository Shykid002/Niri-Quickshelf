import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Opens the Settings window:  qs -c rice ipc call settings open   (the launcher's "Settings" entry does this)
Scope {
    IpcHandler {
        target: "settings"
        function open(): void   { SettingsApp.open = true }
        function close(): void  { SettingsApp.open = false }
        function toggle(): void { SettingsApp.open = !SettingsApp.open }
    }
    LazyLoader { active: SettingsApp.open; SettingsWindow {} }
}
