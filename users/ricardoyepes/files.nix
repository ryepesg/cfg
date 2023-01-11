{ config, pkgs, ... }:

{

  # home.packages = with pkgs; [

  # ];

  # home.file.".logseq/" = {
  #   source = ./logseq;
  #   recursive = true;
  # };

  home.file."./.os.sh" = {
    source = ./os.sh;
  };

}
