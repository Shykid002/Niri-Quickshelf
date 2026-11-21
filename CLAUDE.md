# rice: paper & ink niri desktop

Rules for every file in this repo:
- Square corners. Solid colour blocks. Serif type. No shadows, no gradients, no blur.
- Colours come only from `quickshell/Theme.qml`. Never hardcode a hex in a component.
- UI text uses `components/Txt.qml` (EB Garamond). `components/Mono.qml` (Monaspace Xenon) is for literal strings only.
- Hover and selection are marked with corner brackets (22px tall, 4px arms), not fills.
- Cursor themes: `rice-ink-dark` on paper, `rice-ink-light` on ink.
- Terminal tools use ANSI colours only, so they follow the Ghostty palette.

Roadmap (all phases done + extras: sounds, OSD, timer, player, wallpapers): 0 scaffold, 1 theme, 2 wallpaper, 3 primitives, 4 bar, 5 popups, 6 drawer,
7 session panel, 8 lock, 9 theme transition, 10 cursor+terminal, 11 settings, 12 notifications.
