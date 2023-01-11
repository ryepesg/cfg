# Similar to configuration.nix
# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’)

# Using Core system configurations in one file
# to group semantically instead of default modules alphabetical ordering in editor

{ config, pkgs, ... }:

let
  user = "ricardoyepes";
in
{
  imports = [ 

    # Linux specific
    ./hardware.nix 
    ./packages.nix
    ./xserver.nix
    # ./sound.nix

    # Common modules
    ../modules/nix.nix
    ../modules/direnv.nix
    ../modules/locale.nix
    ../modules/xfonts.nix
    ../modules/security.nix
    ../modules/network.nix
    ../modules/dns.nix
    ../modules/home.nix

    # TODO: power.nix for hibernation

  ];


  ## Specific configurations for Linux in VM
  services.openssh.enable = true;
  virtualisation.vmware.guest.enable = true;


  ## Autologin ##

  # Avoid third passphrase asked
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "ricardoyepes";
  };


  ## Console ##

  # Try use maximum resolution in systemd-boot
  console.earlySetup = true;


  ## Boot ##

  boot = {
    tmpOnTmpfs = true;
    cleanTmpDir = true;
  };

  # Use the systemd-boot EFI boot loader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # boot.initrd.luks.devices = {
  #   root = {
  #     preLVM = true;
  #     keyFile = "/keyfile.bin"; # using second slot, avoiding passphrase again
  #     fallbackToPassword = true;
  #     device = "/dev/nvme0n1p1";
  #   };
  # };

  # boot.initrd.secrets = {
  #   "/keyfile.bin" = "/etc/secrets/initrd/keyfile.bin";
  # };

  boot.initrd.supportedFilesystems = ["zfs"]; # boot from zfs
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "714afa97"; # $ head -c 8 /etc/machine-id

 
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

  documentation.info.enable = false;

}
