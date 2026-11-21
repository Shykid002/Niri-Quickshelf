#!/usr/bin/env bash
# Links the rice into place. Safe to re-run. Never overwrites a config you already have.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
link() { mkdir -p "$(dirname "$2")"; ln -sfn "$1" "$2"; echo "linked  $2"; }

# shell
link "$here/quickshell" "$HOME/.config/quickshell/rice"

# cursors (regenerate if missing)
[ -d "$here/cursors/rice-paper-red" ] || python3 "$here/bin/gen-cursors.py" "$here/cursors"
rm -f "$HOME/.local/share/icons/rice-ink-dark" "$HOME/.local/share/icons/rice-ink-light"   # old names
for d in "$here"/cursors/rice-*; do link "$d" "$HOME/.local/share/icons/$(basename "$d")"; done

# theme hook, called by the shell on every theme change
link "$here/bin/rice-theme" "$HOME/.local/bin/rice-theme"
"$here/bin/rice-theme" "$(gsettings get org.gnome.desktop.interface color-scheme | grep -q dark && echo dark || echo light)"

# settings: helper, launcher entry, and EMPTY fragments so the include lines below never point at nothing
link "$here/bin/rice-apply" "$HOME/.local/bin/rice-apply"
link "$here/bin/rice-keys"  "$HOME/.local/bin/rice-keys"
link "$here/bin/rice-git"   "$HOME/.local/bin/rice-git"
link "$here/bin/rice-doctor" "$HOME/.local/bin/rice-doctor"
link "$here/applications/rice-settings.desktop" "$HOME/.local/share/applications/rice-settings.desktop"
mkdir -p "$HOME/.config/niri" "$HOME/.config/ghostty"
# first run: write the fragments (touchpad: tap + natural scroll, as in the shipped niri config)
[ -e "$HOME/.config/niri/rice-input.kdl" ] || "$here/bin/rice-apply" - - 1 1 -
[ -e "$HOME/.config/ghostty/rice.conf" ]    || echo "# rice: set in Settings > Terminal" > "$HOME/.config/ghostty/rice.conf"

link "$here/niri/keybinds.kdl" "$HOME/.config/niri/keybinds.kdl"

# ghostty: themes always, config only if you have none
for f in "$here"/ghostty/themes/*; do link "$f" "$HOME/.config/ghostty/themes/$(basename "$f")"; done
[ -e "$HOME/.config/ghostty/config" ] || link "$here/ghostty/config" "$HOME/.config/ghostty/config"

# kitty, yazi, zathura (existing configs are never overwritten; the theme hook fills kitty/theme.conf and zathura/theme)
[ -e "$HOME/.config/kitty/kitty.conf" ]     || link "$here/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
[ -e "$HOME/.config/yazi/theme.toml" ]      || link "$here/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
[ -e "$HOME/.config/zathura/zathurarc" ]    || link "$here/zathura/zathurarc" "$HOME/.config/zathura/zathurarc"

# GTK / Qt / Firefox
[ -d /usr/share/themes/adw-gtk3 ] || echo "WARNING: adw-gtk-theme is not installed:  sudo pacman -S adw-gtk-theme"
[ -d /usr/share/icons/Papirus ] || [ -d "$HOME/.local/share/icons/Papirus" ] || echo "NOTE: papirus-icon-theme is not installed, so folder icons will not follow the cover colour:  sudo pacman -S papirus-icon-theme"
command -v qt6ct >/dev/null || echo "WARNING: qt6ct is not installed:  sudo pacman -S qt6ct   (and qt5ct for Qt5 apps)"
for q in qt6ct qt5ct; do
  mkdir -p "$HOME/.config/$q"
  [ -e "$HOME/.config/$q/$q.conf" ] || sed -e "s|__HOME__|$HOME|" -e "s|__QT__|$q|" "$here/qt/qt6ct.conf.in" > "$HOME/.config/$q/$q.conf"
done
link "$here/bin/rice-firefox" "$HOME/.local/bin/rice-firefox"
"$here/bin/rice-firefox" install

# terminal tools
for f in "$here"/fish/functions/*.fish; do link "$f" "$HOME/.config/fish/functions/$(basename "$f")"; done
[ -e "$HOME/.config/bat/config" ] || link "$here/bat/config" "$HOME/.config/bat/config"

NIRI_OK=0
if [ "${1:-}" != "--no-niri" ]; then
  n="$HOME/.config/niri/config.kdl"
  [ -f "$n" ] && cp "$n" "$n.bak.$(date +%s)" && echo "backed up $n"
  cp "$here/niri/config.kdl" "$n"
  if command -v niri >/dev/null && ! niri validate >/dev/null 2>&1; then
    echo "niri says the new config is INVALID, restoring your old one:"; niri validate 2>&1 | head -20 || true
    latest="$(ls -t "$n".bak.* 2>/dev/null | head -1)"; [ -n "$latest" ] && cp "$latest" "$n"
  else
    echo "installed niri/config.kdl"; NIRI_OK=1
  fi
fi

echo
for f in "EB Garamond" "Monaspace Xenon" "Courier Prime"; do
  fc-list | grep -qi "$f" && echo "font ok: $f" || echo "font MISSING: $f (put it in fonts/)"
done
echo
if [ "$NIRI_OK" = 1 ]; then echo "niri: your config was replaced by the rice one (backup: ~/.config/niri/config.kdl.bak.*). Log out and back in."
elif [ "${1:-}" = "--no-niri" ]; then echo "niri: config left alone (--no-niri)"
else echo "niri: the rice config was NOT installed (niri rejected it, your old one is back). Send me the error above."; fi
echo "gtk / qt / firefox: install  adw-gtk-theme qt6ct  then restart Firefox once and pick Add-ons > Themes > \"System theme - auto\""
echo "ghostty: add to your config:  config-file = ?rice.conf   |  kitty: include theme.conf"
for p in noctalia waybar mako dunst swaync; do
  pgrep -x "$p" >/dev/null && echo "WARNING: $p is running. It can fight the rice (bars, notifications). Stop it:  pkill -x $p"
done
[ "$(pgrep -xc qs)" -gt 1 ] && echo "WARNING: $(pgrep -xc qs) quickshell instances are running (check: pgrep -a qs)"
command -v cava >/dev/null || echo "NOTE: cava is not installed, so the music window shows a simulated spectrum:  sudo pacman -S cava"
command -v qs >/dev/null || echo "WARNING: quickshell (qs) is not installed"
command -v starship >/dev/null && echo "NOTE: starship is installed. If your prompt is starship's, it replaces the rice prompt; git details then come from starship (git_status module)."
echo "start the shell by hand with:  qs -c rice      (do NOT put RICE_*_TEST=1 in front: that opens the test windows)"
