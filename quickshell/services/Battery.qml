pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs

Singleton {
    readonly property var dev: UPower.displayDevice
    readonly property bool present: !!dev && dev.isPresent
    readonly property real level: {
        const p = dev ? dev.percentage : 0;
        return p > 1 ? p / 100 : p;          // tolerate 0..1 or 0..100
    }
    readonly property bool charging: !!dev && dev.state === UPowerDeviceState.Charging
    readonly property bool full: !!dev && dev.state === UPowerDeviceState.FullyCharged
    readonly property int percent: Math.round(level * 100)

    function fmt(sec) {
        if (!sec || sec <= 0) return "";
        const m = Math.round(sec / 60);
        return m >= 60 ? Math.floor(m / 60) + " h " + (m % 60) + " min" : m + " min";
    }
    readonly property string status: {
        if (full) return "full";
        const t = fmt(charging ? (dev ? dev.timeToFull : 0) : (dev ? dev.timeToEmpty : 0));
        return (charging ? "charging" : "on battery") + (t ? ", " + t + (charging ? " to full" : " left") : "");
    }

    // Colour by state. All from Theme, so each flips correctly between paper and ink.
    //   charging -> indigo   0-30 % -> red   31-50 % -> ochre   51-75 % -> ink   76-100 % -> pine
    readonly property color tone: {
        if (charging)      return Theme.indigo;
        const pct = level * 100;
        if (pct <= 30)     return Theme.red;
        if (pct <= 50)     return Theme.ochre;
        if (pct <= 75)     return Theme.ink;
        return Theme.pine;
    }
}
