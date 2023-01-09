{ config, pkgs, user, homedir, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "${user}";
  #home.homeDirectory = "${homedir}";
  #home.homeDirectory = "$HOME";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;


  home.packages = with pkgs; [

    # system info
    htop
    pfetch

    # development
    git
    google-cloud-sdk
    dotnet-sdk_7
    fsharp

    # shell ergonomics
    xclip
    tree
    pstree
    coreutils
    nushell
    bat
    fd
    ripgrep
    gnugrep
    fzf
    zoxide
    exa
    file
    tldr
    grml-zsh-config

    # editor
    vim
    helix

    # formats
    jq
    yq

    # networking
    wget
    nmap
    httpie
    netcat-gnu

    # secret management
    sops
    age

    # backup
    # restic-b2

    (let
      my-python-packages = python-packages: with python-packages; [
        toolz
        ipython
      ];
      python-with-my-packages = python3.withPackages my-python-packages;
    in
    python-with-my-packages)
  ];

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      vscodevim.vim
      yzhang.markdown-all-in-one
      ms-python.python
      ionide.ionide-fsharp
      thenuprojectcontributors.vscode-nushell-lang
      streetsidesoftware.code-spell-checker
      ms-vscode.hexeditor
      #ms-vscode.PowerShell
      ms-python.vscode-pylance
      kahole.magit
      jnoortheen.nix-ide
      eamodio.gitlens
      bbenoist.nix
      b4dm4n.vscode-nixpkgs-fmt
      vspacecode.whichkey
      vspacecode.vspacecode
    ];
  }; 

  programs = {

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [

        # Syntax
        vim-nix
        vim-markdown

        # Quality of life
        vim-lastplace                             # Opens document where you left it
        auto-pairs                                # Print double quotes/brackets/etc.
        vim-gitgutter                             # See uncommitted changes of file :GitGutterEnable

        # File Tree
        nerdtree                                  # File Manager - set in extraConfig to F6

        # Customization 
        wombat256-vim                             # Color scheme for lightline
        srcery-vim                                # Color scheme for text

        lightline-vim                             # Info bar at bottom
        indent-blankline-nvim                     # Indentation lines
      ];

      extraConfig = ''
        syntax enable                             " Syntax highlighting
        colorscheme srcery                        " Color scheme text

        let g:lightline = {
          \ 'colorscheme': 'wombat',
          \ }                                     " Color scheme lightline

        highlight Comment cterm=italic gui=italic " Comments become italic
        hi Normal guibg=NONE ctermbg=NONE         " Remove background, better for personal theme
        
        set number                                " Set numbers

        nmap <F6> :NERDTreeToggle<CR>             " F6 opens NERDTree
      '';
    };
  };

  programs.tmux = {
    enable = true;
    #clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      {
        plugin = tilish;
        extraConfig = ''
          set -g @tilish-default 'main-vertical'
        '';
      }
      # resurrect
      # yank
      #{
      #  plugin = dracula;
      #  extraConfig = ''
      #    set -g @dracula-show-battery false
      #    set -g @dracula-show-powerline true
      #    set -g @dracula-refresh-rate 10
      #  '';
      #}
    ];

    #extraConfig = ''
    #  set -g mouse on
    #'';

  };

  home.file.".vimrc" = {
    source = ./programs/vimrc;
  };

  home.file.".tmux.conf" = {
    source = ./programs/tmux.conf;
  };

  home.file.".logseq/" = {
    source = ./programs/logseq;
    recursive = true;
  };

  home.file."./.init.sh" = {
    source = ./init.sh;
  };

  home.file."./.ssh/config" = {
    source = ./programs/ssh-config;
  };

  # Setup tmux plugins
  # git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  home.file.".tmux/plugins/tpm" = {
    recursive = true;
    source = pkgs.fetchFromGitHub {
      owner = "tmux-plugins";
      repo = "tpm";
      rev = "v3.1.0";
      sha256 = "sha256-CeI9Wq6tHqV68woE11lIY4cLoNY8XWyXyMHTDmFKJKI=";
    };
  };

  home.sessionVariables = {
    PAGER = "less -R";
  };

  systemd.user.startServices = true;

}
