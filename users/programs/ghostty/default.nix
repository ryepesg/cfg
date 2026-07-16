# users/programs/ghostty/default.nix
#
# Ghostty terminal config as a home-manager module (native Nix, not a raw
# dotfile). Shared, portable, non-secret -> lives in public `cfg` and is pulled
# into both laptops via homeManagerModules.default. Home-manager writes the
# settings to ~/.config/ghostty/config (it uses the XDG path on macOS too).

{ config, ... }:

{
  programs.ghostty = {
    enable = true;

    # Ghostty itself is installed as a Homebrew cask, not from nixpkgs (the
    # nixpkgs build is unsupported / marked broken on darwin). null = generate
    # the config file only, install no package and skip the validate hook.
    package = null;

    settings = {
      font-family = "BlexMono Nerd Font Mono";
      font-size = 15;

      # Exit a windowless Ghostty process instead of leaving it resident.
      # AeroSpace spawns each terminal as its own Ghostty instance via
      # `open -na Ghostty` (the alt-enter binding); there is no "merge into the
      # existing process" action that way. With Ghostty's default (false),
      # closing a window with Ctrl-D leaves a windowless process resident, each
      # keeping its own Dock icon — over a session these pile up into dozens of
      # ghost Dock icons. true makes the process quit on last-window-close, so
      # the Dock icon count tracks the number of open terminals.
      quit-after-last-window-closed = true;

      # First window of a freshly launched process opens here. Built from the
      # per-machine home dir so the username difference between the laptops
      # (ryepes vs the work account) resolves itself — consolidated on ~/workspace
      # as the common root on both machines.
      working-directory = "${config.home.homeDirectory}/workspace";

      # New tabs/splits/windows created from within Ghostty inherit the focused
      # surface's cwd instead of resetting to working-directory above (default,
      # set explicitly).
      window-inherit-working-directory = true;

      # Scrollback buffer cap. Ghostty has no true-unlimited option; this is a
      # large finite ceiling (bytes — 100 MB, vs the 10 MB default).
      scrollback-limit = 100000000;

      # Left Option acts as Alt so Opt+←/→ and Opt+Backspace do word nav/delete;
      # right Option stays as-is for composing special characters.
      macos-option-as-alt = "left";

      # Copy selected text straight to the clipboard. `clipboard` (not the default
      # `true`) is the load-bearing value on macOS: macOS has no PRIMARY/selection
      # clipboard, so `true` fills only Ghostty's internal selection buffer and
      # Cmd+V sees nothing — `clipboard` targets the system pasteboard so a plain
      # drag-select lands in Cmd+V. Matches the Linux select-to-copy habit.
      copy-on-select = "clipboard";
    };
  };
}
