pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Media player controls over MPRIS (Spotify, Firefox, mpv, VLC...). Picks the player that is
// playing, otherwise the first one.
Singleton {
    id: root
    readonly property var list: Mpris.players.values
    readonly property var active: {
        const p = list.find(x => x.isPlaying);
        return p || (list.length > 0 ? list[0] : null);
    }
    readonly property bool playing: !!active && active.isPlaying
    readonly property string title: active ? (active.trackTitle || "") : ""
    readonly property string artist: active ? (active.trackArtist || "") : ""

    function toggle()   { if (active) active.togglePlaying() }
    function next()     { if (active) active.next() }
    function previous() { if (active) active.previous() }
}
