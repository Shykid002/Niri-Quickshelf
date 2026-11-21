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
import qs.modules.music    // registers the folder; the window itself is created in optional() below, so a mistake in it cannot stop the shell
import qs.services
import qs.modules.dev

// Troubleshooting: leave layers out by name, e.g.
//   RICE_SKIP=transition,lock qs -c rice
// names: popups drawer session lock transition music
ShellRoot {
    id: root
    readonly property var skip: (Quickshell.env("RICE_SKIP") || "").split(",")
    function on(name) { return skip.indexOf(name) < 0 }

    // Optional pieces are created on the fly. If one has a mistake in it, the problem is printed
    // ("rice: could not load ...") and everything else still starts, instead of a blank screen.
    function optional(path) {
        const c = Qt.createComponent(Qt.resolvedUrl(path));
        const finish = () => {
            if (c.status === Component.Ready) c.createObject(root);
            else if (c.status === Component.Error) Diag.report("could not load " + path + ": " + c.errorString());
        };
        if (c.status === Component.Loading) c.statusChanged.connect(finish); else finish();
    }

    Component.onCompleted: {
        Apply.start(); Notifs.start(); Sounds.start(); Osd.start();
        if (root.on("music")) optional("modules/music/MusicLayer.qml");
    }

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
