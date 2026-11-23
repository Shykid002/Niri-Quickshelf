import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Commands for keybinds:  qs -c rice ipc call brightness up   /   volume up|down|mute
Scope {
    id: root

    function activeScreen() {
        const focused = Niri.focusedOutput || "";
        return Quickshell.screens.find(s => s.name === focused) || Quickshell.screens;
    }

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
    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            const scr = root.activeScreen();
            if (scr) Popups.toggle("wall", scr, 12);
        }
        function open(): void {
            if (Popups.current !== "wall") toggle();
        }
        function close(): void {
            if (Popups.current === "wall") Popups.close();
        }
    }
    IpcHandler {
        target: "network"
        function toggle(): void {
            const scr = root.activeScreen();
            if (scr) Popups.toggle("net", scr, 12);
        }
        function open(): void {
            if (Popups.current !== "net") toggle();
        }
        function close(): void {
            if (Popups.current === "net") Popups.close();
        }
    }
}

