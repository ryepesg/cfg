# Private per-machine macOS flake — imports the shared `cfg` library.
#
# Scaffolded from `nix flake init -t github:ryepesg/cfg`. A machine's OWN private
# flake (it never lives in this public repo). It follows cfg's pinned inputs so
# every machine locks to the SAME versions, and imports cfg's module outputs so
# the shared baseline (CLI tools + zsh/git/neovim) is identical everywhere. Only
# the per-machine delta (user, hostname, Homebrew casks, machine-only packages)
# lives here.
#
# Fill in the two CHANGE_ME values, add casks, then `darwin-rebuild switch
# --flake .#<hostname>`. Bump shared versions in ~/cfg, then `nix flake update
# cfg` here + rebuild.

{
  description = "Private macOS machine flake importing cfg";

  inputs = {
    cfg.url = "github:ryepesg/cfg";
    nixpkgs.follows = "cfg/nixpkgs";
    home-manager.follows = "cfg/home-manager";
    darwin.follows = "cfg/darwin";
  };

  outputs = { self, nixpkgs, home-manager, darwin, cfg, ... }@inputs:
    let
      user = "CHANGE_ME"; # ← this machine's macOS username (`whoami`)
      hostname = "CHANGE_ME"; # ← `scutil --get LocalHostName`
      system = "aarch64-darwin";
    in
    {
      darwinConfigurations.${hostname} = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit user inputs; };
        modules = [
          # Shared macOS system defaults from cfg.
          inputs.cfg.darwinModules.systemDefaults

          ({ ... }: {
            system.primaryUser = user;
            networking.hostName = hostname;
            nixpkgs.config.allowUnfree = true;
            system.stateVersion = 5;

            # GUI apps for THIS machine. cleanup = "zap" UNINSTALLS any cask not
            # listed here, so keep the list complete before the first rebuild.
            # homebrew = {
            #   enable = true;
            #   onActivation.cleanup = "zap";
            #   casks = [ "ghostty" "brave-browser" "logseq" /* … */ ];
            # };
          })

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit user inputs; };
            home-manager.users.${user} = { config, ... }: {
              # The shared baseline (CLI tools + zsh/git/neovim) — "install once
              # → every machine". Everything below it is this machine's delta.
              imports = [ inputs.cfg.homeManagerModules.default ];

              home.username = user;
              home.stateVersion = "22.11";
              programs.home-manager.enable = true;

              # Machine-only packages / aliases go here, e.g.:
              # home.packages = with import inputs.nixpkgs { inherit system; }; [ ];

              # Live-edited shared dotfiles (no rebuild to change). Requires
              # `git clone git@github.com:ryepesg/cfg.git ~/cfg` at the same home
              # path used on every machine.
              home.file.".config/aerospace/aerospace.toml".source =
                config.lib.file.mkOutOfStoreSymlink
                  "${config.home.homeDirectory}/cfg/users/programs/aerospace/aerospace.toml";
              home.file.".claude/skills/wrap-up/SKILL.md".source =
                config.lib.file.mkOutOfStoreSymlink
                  "${config.home.homeDirectory}/cfg/users/programs/claude/skills/wrap-up/SKILL.md";
            };
          }
        ];
      };
    };
}
