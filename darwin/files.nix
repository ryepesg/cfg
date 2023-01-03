{ config, pkgs, user, homedir, ... }:

{

  # home.packages = with pkgs; [

  # ];

  # home.file.".logseq/" = {
  #   source = ./logseq;
  #   recursive = true;
  # };

  home.file."/Users/ricardoyepes/.os.sh" = {
    source = ./os.sh;
  };

  home.file."Library/Preferences/com.knollsoft.Rectangle.plist" = {
    source = ./preferences/com.knollsoft.Rectangle.plist;
  };

}
