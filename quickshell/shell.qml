//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.modules.wallpaper
import qs.modules.bar
import qs.modules.popups
import qs.modules.drawer
import qs.modules.session
import qs.modules.lock
import qs.modules.transition
import qs.modules.settings
import qs.modules.ipc
import qs.modules.binds
import qs.modules.osd
import qs.services
import qs.modules.dev

// Troubleshooting: leave layers out by name, e.g.
//   RICE_SKIP=transition,lock qs -c rice
// names: popups drawer session lock transition
ShellRoot {
    id: root
    readonly property var skip: (Quickshell.env("RICE_SKIP") || "").split(",")
    function on(name) { return skip.indexOf(name) < 0 }

    Component.onCompleted: { Apply.start(); Notifs.start(); Sounds.start(); Osd.start() }

    Wallpaper {}
    Bar {}

    LazyLoader { active: root.on("popups");     PopupLayer {} }
    LazyLoader { active: root.on("drawer");     DrawerLayer {} }
    LazyLoader { active: root.on("session");    SessionLayer {} }
    LazyLoader { active: root.on("lock");       LockLayer {} }
    LazyLoader { active: root.on("transition"); TransitionLayer {} }
    SettingsLayer {}
    IpcLayer {}
    BindsLayer {}
    OsdLayer {}

    // Dev windows:  RICE_THEME_TEST=1 qs -c rice   /   RICE_PRIMITIVES_TEST=1 qs -c rice
    LazyLoader { active: !!Quickshell.env("RICE_THEME_TEST");      ThemeTest {} }
    LazyLoader { active: !!Quickshell.env("RICE_PRIMITIVES_TEST"); PrimitivesTest {} }
}
