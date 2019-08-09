let 
    pkgs = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/release-19.03.tar.gz) {};
    piensa = import (builtins.fetchTarball https://github.com/piensa/nur-packages/archive/dce6ae5.tar.gz) {};
    ne = https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/;
in let
    admin0 = pkgs.fetchzip { 
                   url = ne + "ne_10m_admin_0_countries.zip?version=4.1.0";
                   sha256 = "17xzdnbd083x1gzw4xmmdhpar004hln080dxhsfpf2wiic9siy1y";
                   stripRoot = false;
                };
    admin1 = pkgs.fetchzip { 
                   url = ne + "ne_10m_admin_1_states_provinces.zip";
                   sha256 = "0hzdqx1lzckflqizacs7s8mhsszdyivp1a2cmkaj0b380mhw7xlj";
                   stripRoot = false;
                };
    d = derivation { name = "foo"; builder = "${pkgs.gdal}/bin/ogr2ogr"; args = [ "-f -f GeoJSON " ]; src = admin0; system = builtins.currentSystem; };

in pkgs.stdenv.mkDerivation rec {
  name = "mileto";
  buildInputs = [
    piensa.tippecanoe
    pkgs.caddy
    pkgs.bash
    pkgs.gdal
    admin0
    admin1
    d
  ];

  shellHooks = ''
    export ADMIN0=${admin0}
    export ADMIN1=${admin0}
    ogr2ogr -f GeoJSON ne_10m_admin_1_states_provinces.geojson ne_10m_admin_1_states_provinces.shp
  '';
}

# tiles di mileto
