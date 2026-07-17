# users/programs/mdplain — the `mdplain` command: markdown to plain linear
# prose (tables become sentences, code blocks a one-line note). See
# package.nix for the chain.

{ pkgs, ... }:

{
  home.packages = [ (pkgs.callPackage ./package.nix { }) ];
}
