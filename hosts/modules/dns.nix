{ config, lib, pkgs, ... }:

{

  networking = {

    nameservers = [ "1.1.1.1" ];
    
    # if using dhcp disable dns change
    dhcpcd.extraConfig = "nohook resolv.conf";

  };

  # systemd resolved
  services.resolved.enable = true;

}
