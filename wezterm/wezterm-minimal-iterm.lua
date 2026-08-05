-- Minimal WezTerm configuration using iTerm2 color schemes
local wezterm = require "wezterm"
local act = wezterm.action
local config = wezterm.config_builder()

-- Use built-in iTerm2 color scheme (WezTerm ships with 700+ schemes)
-- Popular options: "Dracula", "Kanagawa (Gogh)", "Gruvbox Dark (Gogh)",
--                  "GruvboxDark", "nord", "Tokyo Night", "Catppuccin Mocha"
-- See full list: https://wezterm.org/colorschemes/
config.color_scheme = "Tokyo Night"

-- Font (adjust to your preference)
config.font = wezterm.font_with_fallback({
  {family='SauceCodePro Nerd Font Mono', weight='Regular'},
  {family='Lilex Nerd Font Mono', weight='Regular'}
})
config.font_size = 16

-- Performance
config.max_fps = 120
config.window_background_opacity = 1.0
config.front_end = "OpenGL"

-- Keybindings - ALT-based for panes and tabs
config.keys = {}

-- Pane management
for _, v in ipairs({
  {"Enter", act.SplitHorizontal{domain='CurrentPaneDomain'}},
  {"w", act.CloseCurrentPane{confirm=true}},
  {"LeftArrow", act.ActivatePaneDirection'Left'},
  {"RightArrow", act.ActivatePaneDirection'Right'},
  {"UpArrow", act.ActivatePaneDirection'Up'},
  {"DownArrow", act.ActivatePaneDirection'Down'},
}) do
  table.insert(config.keys, {mods="ALT", key=v[1], action=v[2]})
end

-- Vertical split
table.insert(config.keys, {mods="ALT|SHIFT", key="Enter",
  action=act.SplitVertical{domain='CurrentPaneDomain'}})

-- Tab management
table.insert(config.keys, {mods="ALT", key="t", action=act.SpawnTab'CurrentPaneDomain'})
table.insert(config.keys, {mods="ALT", key="q", action=act.CloseCurrentTab{confirm=true}})

-- Tab navigation (ALT+1-8)
for i = 0, 7 do
  table.insert(config.keys, {mods="ALT", key=tostring(i+1), action=act.ActivateTab(i)})
end

-- Other
table.insert(config.keys, {mods="ALT", key="c", action=act.CopyTo'ClipboardAndPrimarySelection'})
table.insert(config.keys, {mods="ALT", key="v", action=act.PasteFrom'Clipboard'})
table.insert(config.keys, {mods="ALT", key="=", action=act.IncreaseFontSize})
table.insert(config.keys, {mods="ALT", key="-", action=act.DecreaseFontSize})
table.insert(config.keys, {mods="ALT", key="0", action=act.ResetFontSize})

-- Auto-detect Wayland
local is_wayland = os.getenv("WAYLAND_DISPLAY") ~= nil or
                   os.getenv("XDG_SESSION_TYPE") == "wayland"
config.enable_wayland = is_wayland

-- Hide tab bar if only one tab
config.hide_tab_bar_if_only_one_tab = true

return config
