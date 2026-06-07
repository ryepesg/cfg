#
#  Shared macOS base system layer — portable, non-secret system-level config
#  wanted identically on every laptop. Consumed by machine flakes via
#  `inputs.cfg.darwinModules.base`. Keep this free of host-specific / secret
#  settings (hostname, casks, users, hardware stay in the private machine layer).
#

{ pkgs, ... }:

{
  # git at the SYSTEM level: `nix`/darwin-rebuild flake operations need git on
  # PATH during evaluation/activation, independent of any per-user home profile.
  # (The user shell also gets git via the home baseline's programs.git.)
  environment.systemPackages = with pkgs; [ git ];

  programs.zsh.enable = true; # System-wide zsh (sets up /etc/zshrc, completion, …)

  system.keyboard = {
    enableKeyMapping = true; # Required for the remap below to take effect
    remapCapsLockToEscape = true; # Caps Lock → Escape (nvim/vi ergonomics)
  };
}
