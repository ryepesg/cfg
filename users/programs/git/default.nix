{ config, lib, pkgs, ... }:

{

  home.file.".gitconfig".source = ./gitconfig;

  programs.git.enable = true;

}
