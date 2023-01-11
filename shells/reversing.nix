with import <nixpkgs> {};
mkShell {
  name = "Reversing";
  buildInputs = with pkgs; [
    ltrace
    patchelf
    binutils
    gdb
    quemu
  ];

  shellHook = ''
    echo "done"
  '';
}
