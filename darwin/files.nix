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

}
