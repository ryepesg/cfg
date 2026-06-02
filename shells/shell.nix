{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;

mkShell {

  buildInputs = [
    git
    just
    nixfmt # RFC 166-style formatter (nixfmt-rfc-style); replaces nixpkgs-fmt
    #nix-linter
    manix
    nix-tree
    tokei
  ];

  shellHook = ''
    echo
    echo -e "Nix Shell for NixOS development."
    echo
  '';
}
