#
#  Specific system configuration settings for MacBook
#
#  flake.nix
#   └─ ./darwin
#       ├─ ./default.nix
#       └─ ./configuration.nix *
#

{ config, pkgs, user, ... }:

{

  imports = [
    ./system-defaults.nix # Shared macOS system.defaults (also imported by downstream flakes via the cfg flake input)
  ];

  users.users."${user}" = {
    # macOS user
    home = "/Users/${user}";
    shell = pkgs.zsh; # Default shell
  };

  networking = {
    computerName = "MacBook"; # Host name
    hostName = "MacBook";
  };


  environment = {
    shells = with pkgs; [ zsh ]; # Default shell
    variables = {
      # System variables
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    systemPackages = with pkgs; [
      # Installed Nix packages
      # Terminal
      git
      ranger

      fd
      ripgrep
    ];
  };

  programs = {
    # Shell needs to be enabled
    zsh.enable = true;
  };

  fonts.packages = with pkgs; [
    source-code-pro
    font-awesome
    nerd-fonts.fira-code
  ];

  homebrew = {
    # Declare Homebrew using Nix-Darwin
    enable = true;
    onActivation = {
      autoUpdate = false; # Auto update packages
      upgrade = false;
      cleanup = "zap"; # Uninstall not listed packages and casks
    };
    brews = [
      #"wireguard-tools"
      "iproute2mac" # ip addr, ip link...
      "iputils" # tracepath, arping
    ];
    casks = [
      "google-chrome"
      "firefox"
      "logseq"
      "iterm2"
      "rectangle"
      "alfred"
      "keepassxc"
      "google-drive"
      #"anki"
      #"powershell"
      #"vmware-fusion" Requires Mac update
      #"plex-media-player"
      #"burp-suite-professional"
    ];
  };



  nix = {
    package = pkgs.nix;
    gc = {
      # Garbage collection
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };

  system = {
    primaryUser = "${user}"; # Required: user-specific system.defaults apply to this user
    # system.defaults is factored into ./system-defaults.nix (shared via the cfg flake input)
    activationScripts.postActivation.text = ''sudo chsh -s ${pkgs.zsh}/bin/zsh''; # Since it's not possible to declare default shell, run this command after build
    stateVersion = 4;
  };

  nixpkgs.config.allowUnfree = true;

}
