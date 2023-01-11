{ config, lib, pkgs, ... }:

{

  programs.chromium.extensions = [
    "ghbmnnjooekpmoecnnnilnnbdlolhkhi" # offlinedocs
    "ioalpmibngobedobkmbhgmadaphocjdn" # onelogin
    "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
  ];

}
