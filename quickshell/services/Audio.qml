pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var sinks:   Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)   // output devices
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isSink && n.isStream)    // apps playing
    readonly property var tracked: sinks.concat(streams, sink ? [sink] : [])
    PwObjectTracker { objects: root.tracked }

    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0   // 0..1
    readonly property bool muted:  sink && sink.audio ? sink.audio.muted : false
    readonly property string sinkName: sink ? label(sink) : "No output"

    function label(n) { return n.description || n.nickname || n.name }
    function appName(n) {
        const p = n.properties;
        return (p && p["application.name"]) || n.nickname || n.description || n.name;
    }
    function setVolume(percent) { if (sink && sink.audio) sink.audio.volume = Math.max(0, Math.min(1, percent / 100)) }
    function setMuted(m)        { if (sink && sink.audio) sink.audio.muted = m }
    function setDefault(node)   { Pipewire.preferredDefaultAudioSink = node }
}
