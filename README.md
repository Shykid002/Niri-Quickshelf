# Niri Quickshelf

A paper-and-ink Niri/Quickshell rice for Arch Linux.

This repository contains the desktop configuration, themes, cursors, fonts, and helper scripts for the complete rice.

## 1. Install required packages

Install the desktop, audio, network, power, Bluetooth, notification, and general dependencies:

```bash
sudo pacman -S --needed \
  niri quickshell easyeffects swaync \
  pipewire pipewire-pulse wireplumber \
  networkmanager power-profiles-daemon bluez bluez-utils \
  brightnessctl dbus polkit glib2 python \
  fontconfig git
```

`quickshell` may not be available in every Arch Linux repository or mirror. If `pacman` cannot find it, install `quickshell-git` with an AUR helper:

```bash
paru -S quickshell-git
# or
yay -S quickshell-git
```

## 2. Enable system services

```bash
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now power-profiles-daemon
sudo systemctl enable --now bluetooth

systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

Log in with Niri from your display manager, or start it from a working TTY:

```bash
niri
```

## 3. Install the recommended applications and themes

These packages enable the additional themed applications and complete more of the desktop experience:

```bash
sudo pacman -S --needed \
  ghostty kitty \
  adw-gtk-theme qt5ct qt6ct \
  papirus-icon-theme \
  cava fastfetch btop neovim yazi \
  zathura zathura-pdf-mupdf \
  fish starship firefox blueman
```

The rice also works if you omit optional applications. For example:

- If **Cava** is missing, the music window uses a simulated spectrum.
- If **adw-gtk-theme** or **Papirus** is missing, GTK colours or coloured folder icons will be unavailable.
- If **qt5ct** or **qt6ct** is missing, Qt applications will not use the complete rice palette.
- If **Easyeffects** is missing, remove or adjust the startup entry in `niri/config.kdl`.
- If **SwayNotificationCenter** is missing, notification display and notification controls will be unavailable.
- If **BlueZ** or **Blueman** is missing, Bluetooth hardware and management controls will be unavailable.

## 4. Clone the repository

```bash
git clone https://github.com/Shykid002/Niri-Quickshelf.git
cd Niri-Quickshelf
```

## 5. Install the configuration

Review the repository before changing your system configuration:

```bash
./install.sh --no-niri
```

This mode installs the theme, helper commands, terminal configurations, fonts, cursors, and links, but leaves `~/.config/niri/config.kdl` unchanged.

When ready to use the included Niri configuration:

```bash
./install.sh
```

The installer:

- Links Quickshell configuration to `~/.config/quickshell/rice`
- Installs its bundled fonts into `~/.local/share/fonts/rice`
- Installs bundled cursor themes into `~/.local/share/icons`
- Installs helper commands into `~/.local/bin`
- Creates theme fragments for Niri
- Configures Ghostty, Kitty, Yazi, Zathura, and btop
- Applies GTK, Qt, and Firefox theme hooks
- Replaces `~/.config/niri/config.kdl`

Before replacing Niri's configuration, the installer creates a timestamped backup such as:

```text
~/.config/niri/config.kdl.bak.<timestamp>
```

The bundled fonts do not need separate Arch packages:

- EB Garamond
- Monaspace Xenon
- Courier Prime

## 6. Run Quickshell

Start the shell manually to test it:

```bash
qs -c rice
```

Or log out and back in. The included Niri configuration starts it automatically with:

```kdl
spawn-at-startup "qs" "-c" "rice"
```

## 7. Finish application configuration

### Ghostty

Add this to `~/.config/ghostty/config` if it is not already present:

```text
config-file = ?rice.conf
```

The installer also writes the theme fragments and will leave an existing `ghostty/config` untouched.

### Kitty

Add this to `~/.config/kitty/kitty.conf` if it is not already present:

```text
include theme.conf
```

The installer does not replace an existing Kitty configuration.

### Firefox

After restarting Firefox, open:

```text
Add-ons > Themes
```

Select **System theme - auto** if it is available.

## 8. Verify the installation

Check that the Niri configuration is valid:

```bash
niri validate
```

Check the rice installation and running shell:

```bash
rice-doctor
```

Check the Quickshell IPC commands:

```bash
qs -c rice ipc show
```

Useful diagnostics are also written to:

```text
~/.config/rice/errors.log
```

## 9. Default keybindings

The default Super key bindings include:

| Key | Action |
|---|---|
| `Super+Space` or `Super+D` | Open the launcher |
| `Super+Shift+Space` | Open the day drawer |
| `Super+Alt+L` | Lock the screen |
| `Super+Shift+T` | Switch between paper and ink themes |
| `Super+P` | Open the music player |
| `Super+W` | Open the wallpaper picker |
| `Super+N` | Open the network popup |
| `Super+S` | Open settings |
| `Super+/` | Show keybindings |
| `Super+T` or `Super+Return` | Open Kitty |

You can view the installed keybindings through the Settings or Keybindings window.

## Troubleshooting

### Quickshell does not start

Confirm that the executable is available:

```bash
command -v qs
qs -c rice
```

If one optional module is failing, it can be skipped temporarily:

```bash
RICE_SKIP=transition,lock qs -c rice
```

Available skip names include `popups`, `drawer`, `session`, `lock`, `transition`, and `music`.

### Niri rejects the configuration

Restore the newest backup:

```bash
cp "$(ls -t ~/.config/niri/config.kdl.bak.* | head -1)" ~/.config/niri/config.kdl
niri validate
```

### Conflicting desktop shells

The installer warns about running bars or notification daemons that may conflict with the rice, including Noctalia, Waybar, Mako, Dunst, and SwayNotificationCenter:

```bash
pkill -x waybar
pkill -x mako
pkill -x dunst
pkill -x swaync
pkill -x noctalia
```

Stop only the components that are installed on your system.

### Check missing commands

Run:

```bash
for command in qs niri nmcli brightnessctl networkctl cava easyeffects swaync bluetoothctl; do
  command -v "$command" >/dev/null || echo "Missing: $command"
done
```

The exact command set can vary depending on whether the matching feature is enabled.
