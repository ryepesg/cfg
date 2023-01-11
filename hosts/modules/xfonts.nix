{ config, pkgs, ... }:

{

  fonts = {

    fontDir.enable = true;
    fonts = with pkgs; [
      source-code-pro
      font-awesome
      (nerdfonts.override {
        fonts = [
          "Hack"
          "Iosevka"
          "Terminus"
          "Overpass"
          "JetBrainsMono"
          "FiraCode"
        ];
      })
    ];

    fontconfig = {
      enable = true;
      hinting.enable = true;
      antialias = true;
      defaultFonts = {
        monospace = [ "Hack" ];
        sansSerif = [ "Iosevka" ];
        serif = [ "Iosevka" ];
      };
    };

  };

  environment.systemPackages = with pkgs; [
    font-manager
    powerline-fonts
  ];

  # list installed fonts
  # $ fc-list | cut -f2 -d: | sort -u  | grep Nerd

}
