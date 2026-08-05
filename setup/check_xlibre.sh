#!/usr/bin/env bash
# DESC: Exit 1 if XLibre Xserver is installed, else 0
# Usage: wget -qO- "https://justaguy.dev/drew/butterscripts/raw/branch/main/setup/check_xlibre.sh" | bash

dpkg-query -W -f='${Status}\n' 'xlibre*' 2>/dev/null | grep -q 'install ok installed' && exit 1
command -v Xorg >/dev/null 2>&1 && Xorg -version 2>&1 | grep -qi xlibre && exit 1
exit 0
