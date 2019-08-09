let 
    pkgs = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/release-19.03.tar.gz) {};
    piensa = import (builtins.fetchTarball https://github.com/piensa/nur-packages/archive/dce6ae5.tar.gz) {};
in let
    countries = pkgs.fetchzip { 
                   url = https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_admin_0_countries.zip;
                   sha256 = "17xzdnbd083x1gzw4xmmdhpar004hln080dxhsfpf2wiic9siy1y";
                   stripRoot = false;
                };
    

in pkgs.stdenv.mkDerivation rec {
  name = "mileto";
  buildInputs = [
    piensa.tippecanoe
    pkgs.caddy
    pkgs.bash
    countries
  ];

  shellHooks = ''
  '';
}

# tiles di mileto
