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
    # defaultKeymap = "emacs";
    dotDir = ".config/zsh";

    history = {
      expireDuplicatesFirst = true;
      path = ".config/zsh/.zsh_history";
      ignoreDups = true;
      share = true;
      size = 1000000;
    };

    initExtra = ''
      echo sops -d conf/sops.yml > /dev/null 2>&1
      bindkey '^R' history-incremental-search-backward
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      source "${pkgs.grml-zsh-config}/etc/zsh/zshrc"
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
        restic-b2 forget --prune \
                         --keep-last 1 \
                         --keep-within 24h \
                         --keep-daily 7 \
                         --keep-weekly 12 \
                         --keep-monthly 36 \
                         --keep-yearly 15'';
      backup = ''
        restic-b2 backup ~ \
                         --exclude=.cache \
                         --one-file-system \
                         --verbose'';

      # shutdown and reboot are already alias to systemctl
      # shutdown = "echo Use: systemctl poweroff";
      # reboot = "echo Use: systemctl reboot";

    };

  };

  programs.command-not-found.enable = false;

  programs.fzf.enableZshIntegration = true;

  # home.file.".config/zsh/.zshrc".source = ./zshrc;

}