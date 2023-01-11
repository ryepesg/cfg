#
# Terminal Emulator
#

# Hardcoded as terminal for rofi 

{ pkgs, ... }:

{
  programs = {
    alacritty = {
      enable = true;
      settings = {
        font = rec {                          # Font - Laptop has size manually changed at home.nix
          normal.family = "Source Code Pro";
          bold = { style = "Bold"; };
          #size = 8;
        };
        offset = {                            # Positioning
          x = -1;
          y = 0;
        };
      };
    };
  };
}
