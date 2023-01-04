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

  # https://github.com/rxhanson/Rectangle#import--export-json-config
  # Rectangle is able to create the plist from "~/Library/Application Support/Rectangle/RectangleConfig.json"
  # Using both JSON and plist to detect when a non intended change happens
  home.file."Library/Preferences/com.knollsoft.Rectangle.plist" = {
    source = ./preferences/com.knollsoft.Rectangle.plist;
  };

  # Using the JSON instead of the plist because it is easier to track the changes
  # Upon launch, Rectangle will load a config file at ~/Library/Application Support/Rectangle/RectangleConfig.json
  # if it is present and will rename that file with a time/date stamp so that it isn't read on subsequent launches.
  home.file."Library/Application Support/Rectangle/RectangleConfig2023-01-04_10-00-08-5070.json" = {
    source = ./preferences/RectangleConfig.json;
  };

  # Indirect restoring as indicated in https://gitlab.com/gnachman/iterm2/-/issues/8029
  # The benefit is I can track XML instead on binary
  # ~/Library/Preferences/com.googlecode.iterm2.plist
  home.file."preferences/com.googlecode.iterm2.plist" = {
    source = ./preferences/com.googlecode.iterm2.plist;
  };

}
