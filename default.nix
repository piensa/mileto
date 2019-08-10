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
in let
    build-tiles = pkgs.writeShellScriptBin "build-tiles" ''
       mkdir -p data
       ogr2ogr -f GeoJSON data/ne_10m_admin_0_countries.geojson ${admin0}/ne_10m_admin_0_countries.shp;
       ogr2ogr -f GeoJSON data/ne_10m_admin_1_states_provinces.geojson ${admin1}/ne_10m_admin_1_states_provinces.shp;
       tippecanoe -z3 -o data/countries-z3.mbtiles --coalesce-densest-as-needed data/ne_10m_admin_0_countries.geojson
       tippecanoe -zg -Z4 -o data/states-Z4.mbtiles --coalesce-densest-as-needed --extend-zooms-if-still-dropping data/ne_10m_admin_1_states_provinces.geojson
       tile-join --output-to-directory=tiles data/countries-z3.mbtiles data/states-Z4.mbtiles
    '';
in pkgs.stdenv.mkDerivation rec {
  name = "mileto";
  src = [ admin0 admin1];
  buildInputs = [
    piensa.tippecanoe
    pkgs.caddy
    pkgs.bash
    pkgs.gdal
    admin0
    admin1
    build-tiles
  ];

  buildPhase = ''
  '';

  shellHooks = ''
 '';
}

# tiles di mileto
