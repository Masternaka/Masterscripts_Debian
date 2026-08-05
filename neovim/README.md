# Butter Neovim

Simple Neovim installation scripts for Linux.

## Included Scripts

1. **neovim.sh**: Installs Neovim (latest, via ButterRepo) and one of the JustAGuyLinux configs
2. **build-neovim.sh**: Builds the latest stable Neovim from source

## neovim.sh

Installs Neovim from [ButterRepo](https://justaguy.dev/drew/butterrepo) (current stable), then sets up the config you choose:

- **nvim** — standard config, **vim motions** — [repo](https://justaguy.dev/drew/nvim)
- **butter-nvim** — **GUI keybinds** (Ctrl+S/Z/C/V), no vim motions, no LSP — [repo](https://justaguy.dev/drew/butter-nvim)
- **none** — just install Neovim, no config

```bash
git clone https://justaguy.dev/drew/butterscripts.git
cd butterscripts/neovim

./neovim.sh                 # prompts for which config
./neovim.sh nvim            # standard config (vim motions)
./neovim.sh butter-nvim     # GUI keybinds, no vim motions
./neovim.sh none            # just Neovim, no config
```

It adds ButterRepo, installs `neovim`, backs up any existing `~/.config/nvim`, then clones the chosen config into `~/.config/nvim` (keeping `.git`, so `git pull` updates it). Plugins install on first launch.

## build-neovim.sh

- Builds the latest stable Neovim from source into a `.deb`
- Outputs to the current directory; does not auto-install

## Which config?

- **nvim** — if you want (or want to learn) standard vim motions.
- **butter-nvim** — if you want Neovim to behave like a normal GUI editor (Ctrl+S to save, tabbed buffers) without learning vim motions.
- **none** — if you just want current Neovim and will bring your own config.

---

## Author

**JustAGuy Linux**
[YouTube](https://youtube.com/@JustAGuyLinux)

---

Made with butter by JustAGuyLinux
