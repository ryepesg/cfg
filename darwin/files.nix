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

  # Rectangle is able to create the plist from "~/Library/Application Support/Rectangle/RectangleConfig.json"
  # Using the JSON instead of the plist because it is easier to track the changes
  home.file."Library/Preferences/com.knollsoft.Rectangle.plist" = {
    source = ./preferences/com.knollsoft.Rectangle.plist;
  };

  home.file."Library/Application Support/Rectangle/RectangleConfig.json" = {
    source = ./preferences/RectangleConfig.json;
  };

}
