{ config, pkgs, user, homedir, ... }:

{

  # home.packages = with pkgs; [

  # ];

  # home.file.".logseq/" = {
  #   source = ./logseq;
  #   recursive = true;
  # };

  #home.file."/${homedir}/${user}/.os.sh" = {
  home.file."./.os.sh" = {
    source = ./os.sh;
  };

}
