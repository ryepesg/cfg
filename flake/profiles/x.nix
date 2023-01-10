{ config, pkgs, ... }:

{

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/xdg/desktop";
    download = "$HOME/xdg/downloads";
    documents = "$HOME/xdg/documents";
    music = "$HOME/xdg/music";
    pictures = "$HOME/xdg/pictures";
    videos = "$HOME/xdg/videos";
    templates = "$HOME/xdg/templates";
    publicShare = "$HOME/xdg/share";
  };

}
