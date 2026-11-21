import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Commands for keybinds:  qs -c rice ipc call brightness up   /   volume up|down|mute
Scope {
    IpcHandler {
        target: "brightness"
        function up(): void   { Brightness.set(Brightness.percent + 5) }
        function down(): void { Brightness.set(Brightness.percent - 5) }
        function set(percent: int): void { Brightness.set(percent) }
    }
    IpcHandler {
        target: "volume"
        function up(): void   { Audio.setVolume(Audio.volume * 100 + 5) }
        function down(): void { Audio.setVolume(Audio.volume * 100 - 5) }
        function mute(): void { Audio.setMuted(!Audio.muted) }
    }
    IpcHandler {
        target: "keyboard"
        function up(): void   { KeyLight.set(KeyLight.percent + 10) }
        function down(): void { KeyLight.set(KeyLight.percent - 10) }
        function set(percent: int): void { KeyLight.set(percent) }
    }
    IpcHandler {
        target: "player"
        function toggle(): void   { Player.toggle() }
        function next(): void     { Player.next() }
        function previous(): void { Player.previous() }
    }
}
