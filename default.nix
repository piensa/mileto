let
#    pkgs = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/release-19.03.tar.gz) {};
    pkgs = import <nixpkgs> {};
    piensa = import (builtins.fetchTarball https://github.com/piensa/nur-packages/archive/dce6ae5.tar.gz) {};

in pkgs.stdenv.mkDerivation rec {
  name = "mileto";
  buildInputs = [
    piensa.tippecanoe
    pkgs.caddy
    pkgs.bash
  ];

  shellHooks = ''
  '';
}

# tiles di mileto
