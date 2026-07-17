# mdplain — flatten markdown into plain linear prose.
#
# The logic lives in mdplain.py, kept as a plain readable file; nix only
# packages it. writePython3Bin pins the interpreter into the shebang and
# runs flake8 at build time; the outer wrapper pins pandoc onto PATH.

{ writers, writeShellApplication, pandoc }:

let
  script = writers.writePython3Bin "mdplain-py" {
    flakeIgnore = [ "E501" ];
  } (builtins.readFile ./mdplain.py);
in
writeShellApplication {
  name = "mdplain";
  runtimeInputs = [ pandoc ];
  text = ''
    exec ${script}/bin/mdplain-py "$@"
  '';
}
