{ config, lib, pkgs, ... }:

{

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    ## Linux specific

    pciutils
    lshw
    inxi
    psmisc
    evtest
    acpi
    lsof
    beep

    ## No support for darwin

    firefox
    logseq
    
    # https://wiki.linuxfoundation.org/networking/iputils
    iputils # tracepath, arping

    # Useful without command-not-found?
    # nix-index

    # Default already?
    # which
    # cfdisk

  ];

  programs = {
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
      '';
    };
  };

}
