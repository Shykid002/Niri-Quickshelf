pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Power profiles through power-profiles-daemon (the standard on CachyOS).
// ppd only has three profiles. "Ultra-Saver" is power-saver plus a dimmed screen (20%);
// choosing any other profile gives you your old brightness back.
Singleton {
    id: root

    readonly property var profiles: [
        { id: "ultra",       label: "Ultra-Saver", note: "dim screen, slowest" },
        { id: "saver",       label: "Power-Saver", note: "quiet, long battery" },
        { id: "balanced",    label: "Balanced",    note: "everyday" },
        { id: "performance", label: "Performance", note: "fastest, runs warm" }
    ]
    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile
    readonly property string active: Prefs.ultraSaver ? "ultra"
        : PowerProfiles.profile === PowerProfile.PowerSaver ? "saver"
        : PowerProfiles.profile === PowerProfile.Performance ? "performance" : "balanced"

    function choose(id) {
        if (id === "performance" && !hasPerformance) return;
        if (id === "ultra") {
            if (!Prefs.ultraSaver) Prefs.ultraRestore = Math.round(Brightness.percent);
            PowerProfiles.profile = PowerProfile.PowerSaver;
            Prefs.ultraSaver = true;
            Brightness.set(20);
            return;
        }
        if (Prefs.ultraSaver) { Prefs.ultraSaver = false; Brightness.set(Prefs.ultraRestore); }
        PowerProfiles.profile = id === "saver" ? PowerProfile.PowerSaver
                              : id === "performance" ? PowerProfile.Performance : PowerProfile.Balanced;
    }
}
