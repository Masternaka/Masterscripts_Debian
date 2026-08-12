# 🧈 Masterscripts

Une collection modulaire, minimale et pratique de scripts d'installation, de configuration, de thématisation et d'optimisation pour Debian et ses dérivées.

---

## 📋 Présentation

**Masterscripts** rassemble des scripts d'installation et de configuration automatisés pour rationaliser la mise en place d'un environnement Linux minimaliste et réactif (particulièrement adapté aux gestionnaires de fenêtres / Window Managers). 

Chaque dossier regroupe des scripts thématiques pour installer des logiciels, configurer des terminaux, appliquer des thèmes GTK/icônes ou ajuster le système.

---

## 🚀 Prise en main rapide

Vous pouvez lancer l'installateur interactif principal qui fournit un menu TUI simple par catégorie :

```bash
git clone (Mettre à jour adresse du dépôt GitHub ici)
cd Masterscriptscripts
chmod +x installer.sh
./installer.sh
```

---

## 📂 Structure du dépôt

### ` installer.sh`
* **Menu interactif (TUI)** : Découvre et exécute automatiquement les scripts classés par catégorie dans le dépôt.

---

### 🌐 `/browsers`
*Documentation : [browsers/README.md](browsers/README.md)*

* **`install_browsers.sh`** : Script interactif permettant d'installer divers navigateurs web sur Debian Stable :
  * **Helium Browser** *(via ButterRepo)*
  * **Firefox Latest** *(dépôt officiel Mozilla APT)*
  * **LibreWolf** *(via extrepo)*
  * **Brave Browser** *(dépôt officiel Brave)*
  * **Floorp** *(dépôt PPA)*
  * **Zen Browser** *(via ButterRepo)*
  * **Chromium** *(dépôts Debian)*

---

### 💬 `/discord`
*Documentation : [discord/README.md](discord/README.md)*

* **`discord`** : Télécharge, installe et met à jour automatiquement la dernière version binaire de Discord dans `/opt/Discord` avec intégration du raccourci dans `~/.local/bin` et le menu d'applications.

---

### 👻 `/ghostty`

* **`install_ghostty.sh`** : Installe l'émulateur de terminal Ghostty à partir du dépôt ButterRepo (terminal par défaut pour les configurations WM).
* **`config`** : Fichier de configuration optimisé pour Ghostty (thème GitHub Dark, gestion des onglets, divisions et raccourcis).
* **`style.css`** : Style GTK CSS personnalisé pour la barre d'onglets de Ghostty.

---

### 🐱 `/kitty`
*Documentation : [kitty/README.md](kitty/README.md)*

* **`install_kitty.sh`** : Installe l'émulateur de terminal Kitty depuis les dépôts officiels Debian.
* **`kitty.conf`** : Configuration optimisée (thème GitHub Dark, raccourcis Alt, disposition des fenêtres).
* **`current-theme.conf`** : Thème par défaut, modifiable avec la commande `kitty +kitten themes`.
* **`themes/trapped-in-amber.conf`** : Thème personnalisé « Trapped in Amber » pour les sélecteurs de thèmes WM.

---

### 📝 `/neovim`
*Documentation : [neovim/README.md](neovim/README.md)*

* **`neovim.sh`** : Installe Neovim ainsi que la configuration JustAGuyLinux (`nvim` avec raccourcis Vim, ou `butter-nvim` avec raccourcis GUI).
* **`build-neovim.sh`** : Compile et installe Neovim directement depuis le code source.

---

### ⚙️ `/setup`

* **`check_xlibre.sh`** : Vérifie si le serveur X XLibre est présent sur le système.
* **`install_caligula.sh`** : Installe l'outil TUI de création d'images disque Caligula.
* **`install_geany.sh`** : Installe l'éditeur de texte Geany (choix entre APT et ButterRepo).
* **`install_mise.sh`** : Installe `mise` (gestionnaire de versions d'outils de développement) et active son intégration dans le shell.
* **`install_picom.sh`** : Installe le compositeur d'affichage Picom.
* **`optional_tools.sh`** : Installateur interactif d'outils de développement optionnels (notamment [ButterBash](https://justaguy.dev/drew/butterbash) ⭐).
* **`wm-chooser.sh`** : Installateur multi-sélection pour gestionnaires de fenêtres (*Awesome, BSPWM, DWM, i3, Openbox, Qtile, Sway, SwayFX*).

---

### 🖥️ `/st`
*Documentation : [st/ST_PATCH_RECOMMENDATIONS.md](st/ST_PATCH_RECOMMENDATIONS.md)*

* **`install_st.sh`** : Installe et configure le terminal minimaliste `st` (Simple Terminal).

---

### 🛠️ `/system`

* **`install_bluetooth.sh`** : Installe et configure le support Bluetooth (`bluez`, `blueman`, etc.).
* **`install_lightdm.sh`** : Installe et configure le gestionnaire de connexion LightDM.
* **`install_printer_support.sh`** : Configure le support d'impression (CUPS et pilotes).
* **`lightdm-greeter.css`** : Style CSS personnalisé pour l'écran de connexion LightDM.

---

### 🎨 `/theming`
*Documentation : [theming/README.md](theming/README.md)*

* **`install_nerdfonts.sh`** : Installe une sélection de polices Nerd Fonts populaires (*JetBrains Mono, Fira Code*, etc.).
* **`install_theme.sh`** : Installe le thème GTK et le thème d'icônes sombre Dracula.
* **`install_minimal_theme.sh`** : Installe une configuration de thème GTK et d'icônes minimaliste.
* **`ytsubs.sh`** : Script bash pour récupérer le nombre d'abonnés d'une chaîne YouTube via l'API Data v3 (utile pour les barres de statut).

---

### ⚡ `/wezterm`
*Documentation : [wezterm/README.md](wezterm/README.md)*

* **`install_wezterm.sh`** : Installe l'émulateur de terminal WezTerm depuis le dépôt nightly officiel.
* **`wezterm.lua`** : Configuration Lua personnalisée pour WezTerm.
* **`wezterm-minimal-iterm.lua`** : Variante minimaliste de la configuration WezTerm.

---

## 🧈 Conçu pour

* **Debian Linux** (et autres distributions basées sur Debian Stable)
* Les configurations basées sur des gestionnaires de fenêtres (*BSPWM, Openbox, i3, Sway, etc.*)
* Les utilisateurs recherchant un système rapide, modulaire et léger

---
