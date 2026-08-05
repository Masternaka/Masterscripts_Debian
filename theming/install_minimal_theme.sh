#!/usr/bin/env bash
# DESC: Install default Orchis GTK theme + Colloid icons (for WMs without a theme switcher)

set -e

GTK_THEME="Orchis-Grey-Dark"
ICON_THEME="Colloid-Grey-Dracula-Dark"
TEMP_DIR="/tmp/theme_$$"

trap "rm -rf $TEMP_DIR" EXIT

die() { echo "ERROR: $1" >&2; exit 1; }
msg() { echo ":: $1"; }
has_gtk()  { [ -d "$HOME/.themes/$1" ]; }
has_icon() { [ -d "$HOME/.local/share/icons/$1" ] || [ -d "$HOME/.icons/$1" ]; }

# --- 1. Install theme files if missing ---
NEED_ORCHIS=false;  has_gtk  "$GTK_THEME"  || NEED_ORCHIS=true
NEED_COLLOID=false; has_icon "$ICON_THEME" || NEED_COLLOID=true

if $NEED_ORCHIS || $NEED_COLLOID; then
    echo "Installing missing GTK theme and icons..."
    mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

    if $NEED_ORCHIS; then
        msg "Cloning Orchis GTK theme..."
        git clone -q --depth 1 https://github.com/vinceliuice/Orchis-theme || die "Failed to clone Orchis"
        cd Orchis-theme
        msg "Installing $GTK_THEME..."
        yes | ./install.sh -l -c dark -t grey --tweaks black >/dev/null 2>&1 \
            || die "$GTK_THEME install failed"
        cd "$TEMP_DIR"
    fi

    if $NEED_COLLOID; then
        msg "Cloning Colloid icon theme..."
        git clone -q --depth 1 https://github.com/vinceliuice/Colloid-icon-theme || die "Failed to clone Colloid"
        cd Colloid-icon-theme
        msg "Installing Colloid Grey Dracula icons..."
        ./install.sh -t grey -s dracula >/dev/null 2>&1 || die "Colloid Grey Dracula install failed"
    fi

    has_gtk "$GTK_THEME" && has_icon "$ICON_THEME" || die "Install verification failed"
else
    echo "GTK theme and icons already present"
fi

# --- 2. Determine which theme to apply (preserve existing if valid) ---
SETTINGS_INI="$HOME/.config/gtk-3.0/settings.ini"
APPLY_GTK="$GTK_THEME"
APPLY_ICON="$ICON_THEME"
if [ -f "$SETTINGS_INI" ]; then
    cur_gtk=$(sed -n 's/^gtk-theme-name=//p' "$SETTINGS_INI")
    cur_icon=$(sed -n 's/^gtk-icon-theme-name=//p' "$SETTINGS_INI")
    if has_gtk "$cur_gtk" && has_icon "$cur_icon"; then
        echo "Preserving existing theme: $cur_gtk + $cur_icon"
        APPLY_GTK="$cur_gtk"
        APPLY_ICON="$cur_icon"
    fi
fi

# --- 3. Apply settings (always — files + gsettings stay in sync) ---
msg "Applying theme: $APPLY_GTK + $APPLY_ICON"
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=$APPLY_GTK
gtk-icon-theme-name=$APPLY_ICON
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOF

cat > ~/.gtkrc-2.0 << EOF
gtk-theme-name="$APPLY_GTK"
gtk-icon-theme-name="$APPLY_ICON"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Adwaita"
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
EOF

cat > ~/.xsettingsd << EOF
Net/ThemeName "$APPLY_GTK"
Net/IconThemeName "$APPLY_ICON"
Gtk/FontName "Sans 10"
Gtk/CursorThemeName "Adwaita"
Xft/Antialias 1
Xft/Hinting 1
Xft/HintStyle "hintfull"
EOF

# gsettings writes to dconf (~/.config/dconf/user). dbus-run-session spawns a
# throwaway bus when we're in a tty install with no user session — dconf still
# persists, so the user's WM session and tools like nwg-look see the values.
GSET="gsettings"
[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && GSET="dbus-run-session -- gsettings"
$GSET set org.gnome.desktop.interface gtk-theme    "$APPLY_GTK"  || true
$GSET set org.gnome.desktop.interface icon-theme   "$APPLY_ICON" || true
$GSET set org.gnome.desktop.interface font-name    "Sans 10"     || true
$GSET set org.gnome.desktop.interface cursor-theme "Adwaita"     || true

echo "Done"
