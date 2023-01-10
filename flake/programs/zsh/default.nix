{ config, lib, pkgs, ... }:

{


 # zsh = {
 # Extra plugins for zsh
 #   oh-my-zsh = {
 #     enable = true;
 #     theme = "agnoster";
 #     plugins = [
 #      "git"
 #      "pip"
 #     ];
 #     custom = "$HOME/.config/zsh_nix/custom";
 #   };
 # };

  # Post installation script is run in configuration.nix to make it default shell
  programs.zsh = {

    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;

    ## Not working in Mac
    # dotDir = ".config/zsh";

    history = {
      expireDuplicatesFirst = true;
      # path = ".config/zsh/.zsh_history";
      ignoreDups = true;
      share = true;
      size = 1000000;
    };

    # Commands that should be added to top of .zshrc
    initExtraFirst = ''
      source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
    '';
    # source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

    # Extra commands that should be added to .zshrc
    initExtra = ''
      echo sops -d conf/sops.yml > /dev/null 2>&1
      bindkey '^R' history-incremental-search-backward
      eval "$(zoxide init zsh)"
      # eval "$(direnv hook zsh)"
      # Spaceship
      # source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
      # autoload -U promptinit; promptinit
      pfetch
    '';

    shellAliases = {
      mv = "mv -i";
      cp = "cp -i";
      rm = "rm -i";
      ls = "exa";
      cat = "bat";
      less = "bat";
      more = "bat";
      rg = "rg --color=always";
      jq = "jq -C";
      prune = ''
        restic-s3 forget --prune \
                         --keep-last 1 \
                         --keep-within 24h \
                         --keep-daily 7 \
                         --keep-weekly 12 \
                         --keep-monthly 36 \
                         --keep-yearly 15'';
      backup = ''
        restic-s3 backup ~ \
                         --exclude=.cache \
                         --one-file-system \
                         --verbose'';

      # shutdown and reboot are already alias to systemctl
      # shutdown = "echo Use: systemctl poweroff";
      # reboot = "echo Use: systemctl reboot";

      # TODO: overlays for MacOS vs Linux
      pbcopy = "if [ -f /usr/bin/pbcopy ]; then pbcopy; else xclip -selection c; fi";
      pbpaste = "if [ -f /usr/bin/pbpaste ]; then pbpaste; else xclip -selection clipboard -o; fi";

    };

  };

  programs.command-not-found.enable = false;

  programs.fzf.enableZshIntegration = true;

}
