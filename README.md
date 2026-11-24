# Paper & Ink: Installation guide

Everything you need installed so the Quickshell desktop works completely: bar, drawer, popups, lock screen,
notifications, music window, sounds, wallpapers, and the matching themes for GTK, Qt, Firefox, kitty, Neovim and more.

Written for **CachyOS / Arch Linux** with **niri**. Commands use `pacman`; for AUR packages use `paru` or `yay`.
Package names can change, so if one is "not found", check with `pacman -Ss name` or `paru -Ss name`.

---

## 1. How the pieces fit

| Part | What it needs |
|---|---|
| Whole shell | `niri` + `quickshell` (a recent release) |
| Sound, volume popup, sounds | PipeWire + WirePlumber |
| Battery and power profiles | UPower + power-profiles-daemon |
| Wi-Fi popup | NetworkManager (`nmcli`) |
| Bluetooth | BlueZ (`bluetoothctl`) |
| Screen and keyboard light | `brightnessctl` |
| Notifications | nothing else, **but no other notification daemon may be running** |
| Music window | a media player (Spotify, Firefox...), `cava` for the real spectrum |
| Fonts | EB Garamond, Monaspace Xenon, Courier Prime |
| Theme switch | `glib2` + `dconf` (gsettings), `adw-gtk-theme`, `qt6ct`, `papirus-icon-theme` |

---

## 2. Required packages (install these first)

### 2.1 Session and shell

```bash
sudo pacman -S --needed niri quickshell \
  qt6-base qt6-declarative qt6-wayland qt6-svg \
  xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk \
  polkit polkit-gnome xwayland-satellite \
  glib2 dconf git python
```

- `quickshell`: in the CachyOS repos. On plain Arch use the AUR (`quickshell` or `quickshell-git`).
- It must be recent. The rice uses the Quickshell modules for **Pipewire, UPower power profiles, Mpris, Notifications,
  Bluetooth, SystemTray, PAM, session lock and idle monitor**. Check with `qs --version`, and update if the shell reports
  a missing module.
- `xdg-desktop-portal-*`: lets Firefox and GTK apps follow paper / ink and enables screen sharing.
- `polkit-gnome`: a password prompt for apps that need admin rights. Add it to niri's startup if you want it:
  `spawn-at-startup "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"`.
- `xwayland-satellite`: runs X11-only apps on niri.

### 2.2 Audio (volume, sound popup, beeps, music)

```bash
sudo pacman -S --needed pipewire pipewire-pulse pipewire-alsa wireplumber libpulse
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

`pw-play` (from `pipewire`) plays the notification, charger, volume and timer sounds. `paplay` (from `libpulse`) is the fallback.

### 2.3 Network, Bluetooth, battery, power

```bash
sudo pacman -S --needed networkmanager bluez bluez-utils upower power-profiles-daemon util-linux
sudo systemctl enable --now NetworkManager bluetooth upower power-profiles-daemon
```

- `nmcli` (NetworkManager) powers the Wi-Fi list.
- `bluetoothctl` and `rfkill` are the fallback for the Bluetooth switch.
- `power-profiles-daemon` is needed for the battery card's profiles. Do not run `tlp` or `auto-cpufreq` together with it.

### 2.4 Light (screen and keyboard)

```bash
sudo pacman -S --needed brightnessctl
```

- Reading uses `brightnessctl`. Setting goes through your login session (systemd-logind), so no extra permissions are
  normally needed. If a "not permitted" message shows in the Day tab, also run
  `sudo usermod -aG video $USER` and log out and in.
- Keyboard backlight (MacBook): the `applesmc` kernel module must be loaded. Check `brightnessctl -l --class=leds`
  and look for `smc::kbd_backlight`.

### 2.3 Fonts

The shell uses **EB Garamond** (interface), **Monaspace Xenon** (literal text such as network names) and **Courier Prime** (terminal).

Try the packages first (names vary, search if needed):

```bash
paru -S ttf-eb-garamond ttf-monaspace ttf-courier-prime
```

The reliable way, if a package is missing: download the `.ttf` / `.otf` files from Google Fonts (EB Garamond), GitHub
Next (Monaspace) and Quote-Unquote Apps (Courier Prime), put them in `~/.local/share/fonts/` and run:

```bash
fc-cache -f
fc-list | grep -i -E "EB Garamond|Monaspace Xenon|Courier Prime"     # all three must appear
```

---

## 3. Recommended apps (the themes are built for these)

```bash
sudo pacman -S --needed kitty fish firefox neovim zathura zathura-pdf-mupdf \
  yazi eza bat fastfetch starship papirus-icon-theme adw-gtk-theme qt6ct qt5ct \
  cava libnotify wl-clipboard blanket meld
```

| Package | Used for |
|---|---|
| `kitty` | the terminal with paper / ink colors (git details in the prompt need `git`) |
| `fish` | the prompt and terminal title (make it your shell: `chsh -s /usr/bin/fish`) |
| `firefox` | themed with `userChrome.css`; restart once after install |
| `papirus-icon-theme` | folder icons that follow the cover color |
| `adw-gtk-theme` | GTK3 and GTK4 apps in paper / ink |
| `qt6ct`, `qt5ct` | Qt app palette (Qt6 apps are themed; Qt5 apps may not be) |
| `cava` | the real music spectrum (without it the spectrum is simulated) |
| `libnotify` | `notify-send` for testing notifications |
| `wl-clipboard` | clipboard in Neovim and terminals on Wayland |
| `yazi`, `eza`, `bat`, `fastfetch`, `zathura` | terminal tools and PDF viewer with matching colors |
| `starship` | optional: the prompt theme `starship/starship.toml` |

Optional extras for yazi previews: `ffmpegthumbnailer unarchiver jq poppler imagemagick zoxide`.

---

## 4. Neovim (paper & ink config)

Needs **Neovim 0.11 or newer**:

```bash
sudo pacman -S --needed neovim git gcc make tree-sitter-cli fzf ripgrep fd unzip curl wl-clipboard
nvim --version | head -1
```

- First start downloads the plugins by itself (needs internet).
- Language servers: run `:Mason` inside Neovim. For some servers you also need `nodejs npm` or `python-pip`.

---

## 5. Install the rice

```bash
cd ~/Templates/rice          # or wherever you unpacked it
./install.sh                 # backs up and replaces your niri config; ./install.sh --no-niri to skip
```

It will:
- link the shell to `~/.config/quickshell/rice` and the cursors, keybinds, themes and helper scripts
- install the rice's niri `config.kdl` (your old one is backed up and put back if niri rejects the new one)
- warn about missing packages and about programs that conflict

Then **log out and back in** (or reload niri). niri starts the shell with `qs -c rice`.

Always start the shell as `qs -c rice`, never `qs -p path`: the keybinds talk to it by that name.

---

## 6. Things that must NOT be running

Only one program can own notifications, the tray and the bar. Stop and disable these if you have them:

| Program | Why it conflicts |
|---|---|
| `noctalia` (CachyOS niri default) | owns notifications and the tray; a second bar |
| `waybar` | a second bar |
| `mako`, `dunst`, `swaync` | take the notification service |
| `swaybg`, `hyprpaper`, `wpaperd` | cover the generated wallpaper |

```bash
pkill -x noctalia; pkill -x waybar; pkill -x mako; pkill -x dunst; pkill -x swaync
systemctl --user list-units --all | grep -i -E "noctalia|waybar|mako|dunst|swaync"   # then: systemctl --user disable --now <unit>
grep -rIl noctalia ~/.config/niri ~/.config/systemd ~/.config/autostart 2>/dev/null   # what starts it at login
```

---

## 7. Check that everything works

```bash
rice-doctor                          # which folder is installed, which commands the shell offers, recorded problems
for c in niri qs pw-play nmcli bluetoothctl brightnessctl cava fish kitty nvim fzf rg fd; do
  command -v $c >/dev/null && echo "ok      $c" || echo "MISSING $c"; done
systemctl is-active NetworkManager bluetooth upower power-profiles-daemon
systemctl --user is-active pipewire wireplumber
```

Quick tests:

| Test | Expected |
|---|---|
| `notify-send "Test" "Hello"` | a bell, the message in the bar item and in the drawer's Notes |
| Click the clock | the Day drawer; the sliders change the real volume and light |
| `Super+Space` | the launcher |
| `Super+P` | the music window drops from the top |
| `Super+/` | the list of all keybindings |
| Bar theme button | everything flips between paper and ink |

If anything failed to start, the **Day tab** shows the problem in red at the top and it is saved in
`~/.config/rice/errors.log`.

---

## 8. Troubleshooting

| Symptom | Likely cause and fix |
|---|---|
| Blank screen, only the cursor | the shell did not start: open kitty (`Super+T`) and run `qs -c rice 2>&1 | head -40` |
| Bar missing after login | niri still uses its default config: run `./install.sh` (without `--no-niri`), log out and in |
| Keybinds do nothing | the shell was not started as `qs -c rice`, or the install links point at an old folder: run `rice-doctor` |
| Notifications never appear | another daemon owns them: the notification card says which; stop it (section 6) |
| Light slider shows an error | install `brightnessctl`; see section 2.4 |
| Volume / sound popup empty | PipeWire not running: `systemctl --user enable --now pipewire wireplumber` |
| Wi-Fi list empty | `systemctl enable --now NetworkManager`; `nmcli dev wifi` should list networks |
| Battery card has no profiles | `power-profiles-daemon` not running |
| Spectrum is simulated | install `cava` |
| Music window shows no playlist | Spotify does not share playlists; the list shows what has played |
| Album art missing | needs an internet connection |
| Letters missing or wrong font | the three fonts are not installed (section 2.3) |
| Firefox not themed | restart it once, then Settings > Extensions & Themes > "System theme - auto" |
| GTK apps unthemed | install `adw-gtk-theme`; for Flatpak apps: `flatpak override --user --filesystem=xdg-config/gtk-4.0:ro` |
| Folder icons not recolored | install `papirus-icon-theme`, then change the cover color once |

---

## 9. Not needed

- No display manager is required, but one that starts a niri session (`greetd`, `sddm`, `ly`) is convenient.
- No separate lock program (`swaylock`, `hyprlock`) is needed; the shell has its own lock screen.
- No wallpaper tool or image files: the wallpapers are drawn by the shell.
