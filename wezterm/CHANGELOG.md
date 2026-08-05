# WezTerm Configuration Changelog

All notable changes to the WezTerm configuration will be documented in this file.

## [Unreleased]

## [2026-05-27]
### Changed
- Simplified font config to Lilex Nerd Font Mono (primary) with a single SauceCodePro Nerd Font Mono fallback; dropped the redundant IosevkaTerm/FiraCode/Symbols entries (each Nerd Font already carries the full glyph set, and WezTerm auto-appends its built-in symbol/emoji fallback)
- Window frame font switched to Lilex Nerd Font Mono Italic to match the primary

### Added
- Installer now installs the required Nerd Fonts (Lilex + SauceCodePro), skipping any already present
- Installer checks for and installs its dependencies (curl, wget, gnupg, unzip) up front
- Config files are now (re)installed even when WezTerm is already present

## [2025-05-23]
### Changed
- Increased font size from 11 to 16 for better readability
- Updated keybindings:
  - Changed ALT+` to ALT+- (split pane right, 30% width)
  - Changed ALT+Tab to ALT+= (split pane down, 30% height)

## [Previous Changes]
### Changed
- Streamlined configuration maintaining all functionality
- Implemented GitHub Dark color scheme
- Configured performance optimizations (120fps, OpenGL, EGL)
- Set up comprehensive keybindings for pane and tab management
- Added font fallback chain (SauceCodePro, FiraCode, Symbols Nerd Fonts)
- Switched to nightly version of WezTerm