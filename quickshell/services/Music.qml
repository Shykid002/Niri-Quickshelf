pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.services

// The drop-down music window: state, the player it shows, and the list of tracks that have played.
//
// Spotify does not share its playlists or queue with other programs (MPRIS only gives the current track),
// so the list is "recently played": every track this window has seen, newest first, kept in
// ~/.config/rice/played.json. Clicking one plays it again through Spotify (OpenUri over D-Bus).
Singleton {
    id: root
    property bool open: false
    property string screenName: ""
    property bool showList: false

    readonly property var player: Player.spotify || Player.active
    readonly property bool playing: !!player && player.isPlaying
    readonly property string trackKey: player ? (player.trackTitle + "|" + player.trackArtist) : ""
    property var history: []                                  // [{ title, artist, album, uri, art, length }]
    property bool loaded: false

    function toggleDefault() { openOn(Niri.focusedOutput || (Quickshell.screens.length ? Quickshell.screens[0].name : "")) }
    function openOn(name) {
        if (open && screenName === name) { open = false; return; }
        Drawer.close(); Session.close(); Popups.close();
        screenName = name; open = true;
    }
    function close() { open = false }
    function playPause() { if (player) player.togglePlaying() }
    function next()      { if (player) player.next() }
    function prev()      { if (player) player.previous() }
    function clearHistory() { history = [] }

    function uriOf(p) {
        const m = p && p.metadata ? p.metadata : null;
        const id = m ? String(m["mpris:trackid"] || "") : "";
        const sp = id.match(/\/com\/spotify\/track\/(\w+)/);
        return sp ? "spotify:track:" + sp[1] : "";
    }
    function playUri(uri) {
        if (!uri) return;
        Quickshell.execDetached(["busctl", "--user", "call", (player && player.dbusName) || "org.mpris.MediaPlayer2.spotify",
                                 "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", "OpenUri", "s", uri]);
    }
    function capture() {
        const p = player;
        if (!p || !p.trackTitle) return;
        const item = { title: p.trackTitle, artist: p.trackArtist || "", album: p.trackAlbum || "", uri: uriOf(p),
                       art: String(p.trackArtUrl || ""), length: p.length || 0 };
        const h = history.slice();
        if (h.length > 0 && h[0].title === item.title && h[0].artist === item.artist) h[0] = item; else h.unshift(item);
        history = h.slice(0, 100);
    }
    onTrackKeyChanged: { capture(); late.restart() }
    Timer { id: late; interval: 1200; onTriggered: root.capture() }          // art and length often arrive a moment later

    // saved as plain JSON in ~/.config/rice/played.json
    Process {
        command: ["sh", "-c", 'cat "$HOME/.config/rice/played.json" 2>/dev/null']
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { const a = JSON.parse(text); if (Array.isArray(a) && root.history.length === 0) root.history = a } catch (e) {}
                root.loaded = true;
            }
        }
    }
    onHistoryChanged: { if (loaded) save.restart() }
    Timer {
        id: save; interval: 800
        onTriggered: Quickshell.execDetached(["sh", "-c", 'mkdir -p "$HOME/.config/rice" && printf "%s" "$1" > "$HOME/.config/rice/played.json"',
                                              "sh", JSON.stringify(root.history)])
    }
}
