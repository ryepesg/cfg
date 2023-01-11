{ config, lib, pkgs, stdenv, homeDir, ... }:
let
  cmd = "restic-s3";
  store = "${homeDir}/data-vault/k.yaml";
  sops = "${pkgs.sops}/bin/sops";
  secret = (v: ''export ${v}=$(${sops} -d --extract '["${v}"]' ${store})'');
  wrapper = pkgs.writeShellScriptBin cmd ''
    export PATH=${lib.makeBinPath [ sops pkgs.age ]}
    # echo the store is ${store} # check with vim $(which restic-s3)
    export SOPS_AGE_KEY=$(${pkgs.age}/bin/age -d ~/k.age)
    ${secret "AWS_ACCESS_KEY_ID"}
    ${secret "AWS_SECRET_ACCESS_KEY"}
    ${secret "RESTIC_PASSWORD"}
    ${secret "RESTIC_REPOSITORY"}
    ${pkgs.restic}/bin/restic "$@"
  '';
in
stdenv.mkDerivation {
  name = cmd;
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin
    install ${wrapper}/bin/* $out/bin
  '';
}
