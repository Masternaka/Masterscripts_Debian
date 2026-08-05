#!/usr/bin/env bash
# DESC: Install Orchis GTK themes and Colloid icon themes for qtile theme switcher

set -e

GTK_THEME="Orchis-Grey-Dark"
ICON_THEME="Colloid-Grey-Dracula-Dark"
TEMP_DIR="/tmp/theme_$$"

trap "rm -rf $TEMP_DIR" EXIT

die() { echo "ERROR: $1" >&2; exit 1; }
msg() { echo ":: $1"; }
has_gtk()  { [ -d "$HOME/.themes/$1" ]; }
has_icon() { [ -d "$HOME/.local/share/icons/$1" ] || [ -d "$HOME/.icons/$1" ]; }

# Orchis variants used by the theme switcher (only these install — saves ~85% vs -t all).
# Each line: <sentinel-dir-name> <orchis -t color> <orchis --tweaks args>
ORCHIS_VARIANTS=(
    "Orchis-Dark                default black"
    "Orchis-Grey-Dark           grey    black"
    "Orchis-Green-Dark          green   black"
    "Orchis-Purple-Dark         purple  black"
    "Orchis-Orange-Dark         orange  black"
    "Orchis-Pink-Dark           pink    black"
    "Orchis-Dark-Nord           default black nord"
    "Orchis-Purple-Dark-Dracula purple  black dracula"
)

# --- 1. Install theme files if missing ---
NEED_ORCHIS=false
for v in "${ORCHIS_VARIANTS[@]}"; do
    set -- $v
    has_gtk "$1" || NEED_ORCHIS=true
done

NEED_CALL=true;  has_icon "Colloid-Dracula-Dark" && NEED_CALL=false
NEED_CGREY=true; has_icon "$ICON_THEME"          && NEED_CGREY=false
NEED_CORG=true;  has_icon "Colloid-Orange-Dark"  && NEED_CORG=false

if $NEED_ORCHIS || $NEED_CALL || $NEED_CGREY || $NEED_CORG; then
    echo "Installing missing GTK themes and icons..."
    mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

    if $NEED_ORCHIS; then
        msg "Cloning Orchis GTK theme..."
        git clone -q --depth 1 https://github.com/vinceliuice/Orchis-theme || die "Failed to clone Orchis"
        cd Orchis-theme
        for v in "${ORCHIS_VARIANTS[@]}"; do
            set -- $v
            sentinel=$1; color=$2; shift 2
            has_gtk "$sentinel" && continue
            msg "Installing $sentinel..."
            yes | ./install.sh -l -c dark -t "$color" --tweaks "$@" >/dev/null 2>&1 \
                || die "$sentinel install failed"
        done
        cd "$TEMP_DIR"
    fi

    if $NEED_CALL || $NEED_CGREY || $NEED_CORG; then
        msg "Cloning Colloid icon theme..."
        git clone -q --depth 1 https://github.com/vinceliuice/Colloid-icon-theme || die "Failed to clone Colloid"
        cd Colloid-icon-theme
        if $NEED_CALL; then
            msg "Installing Colloid icon variants..."
            ./install.sh -s all >/dev/null 2>&1 || die "Colloid install failed"
        fi
        if $NEED_CGREY; then
            msg "Installing Colloid Grey Dracula icons..."
            ./install.sh -t grey -s dracula >/dev/null 2>&1 || die "Colloid Grey Dracula install failed"
        fi
        if $NEED_CORG; then
            msg "Installing Colloid Orange icons..."
            ./install.sh -t orange >/dev/null 2>&1 || die "Colloid Orange install failed"
        fi
    fi

    has_gtk "$GTK_THEME" && has_icon "$ICON_THEME" || die "Install verification failed"
else
    echo "GTK themes and icons already present"
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
