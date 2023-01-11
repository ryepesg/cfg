{ config, pkgs ... }:

let
  user = "ricardoyepes";
in
{

  # X11 windowing system + i3 + xfce
  services.xserver = {

    enable = true;
    windowManager = { i3.enable = true; };

    xautolock.time = 600;

    desktopManager = {
    # default = "xfce";
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    displayManager = {
      lightdm.enable = true;
      defaultSession = "xfce+i3";
      # defaultSession = "none+i3";
      # Log in automatically
      autoLogin.user = "${user}";
    };

  };

}
