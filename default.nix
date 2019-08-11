let 
    pkgs = import (builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/release-19.03.tar.gz) {};
    piensa = import (builtins.fetchTarball https://github.com/piensa/nur-packages/archive/dce6ae5.tar.gz) {};
    ne = https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/;
in let
    admin0 = pkgs.fetchzip { 
                   url = ne + "ne_10m_admin_0_countries.zip";
                   sha256 = "17xzdnbd083x1gzw4xmmdhpar004hln080dxhsfpf2wiic9siy1y";
                   stripRoot = false;
                };
    admin1 = pkgs.fetchzip { 
                   url = ne + "ne_10m_admin_1_states_provinces.zip";
                   sha256 = "0hzdqx1lzckflqizacs7s8mhsszdyivp1a2cmkaj0b380mhw7xlj";
                   stripRoot = false;
                };
    gdal = pkgs.gdal;
    tippecanoe = piensa.tippecanoe;
    caddy = pkgs.caddy;
in let
    mileto-generate = pkgs.writeShellScriptBin "mileto-generate" ''
       mkdir -p data
       ${gdal}/bin/ogr2ogr -f GeoJSON data/ne_10m_admin_0_countries.geojson ${admin0}/ne_10m_admin_0_countries.shp;
       ${gdal}/bin/ogr2ogr -f GeoJSON data/ne_10m_admin_1_states_provinces.geojson ${admin1}/ne_10m_admin_1_states_provinces.shp;
       ${tippecanoe}/bin/tippecanoe -z3 -o data/countries-z3.mbtiles --no-progress-indicator --coalesce-densest-as-needed data/ne_10m_admin_0_countries.geojson
       ${tippecanoe}/bin/tippecanoe -zg -Z4 -o data/states-Z4.mbtiles --no-progress-indicator --coalesce-densest-as-needed --extend-zooms-if-still-dropping data/ne_10m_admin_1_states_provinces.geojson
       ${tippecanoe}/bin/tile-join --output-to-directory=tiles data/countries-z3.mbtiles data/states-Z4.mbtiles
    '';
    
   caddy-conf = pkgs.writeShellScriptBin "caddy-conf" ''

   '';
   mileto-serve = pkgs.writeShellScriptBin "mileto-serve" ''
      caddy -conf ${caddy-conf}
   '';
   mileto-delete = pkgs.writeShellScriptBin "mileto-delete" ''
      rm -rf tiles
      rm -rf data
   '';
in pkgs.stdenv.mkDerivation rec {
  name = "mileto";
  src = [ admin0 admin1];
  buildInputs = [
    pkgs.bash
    pkgs.caddy
    mileto-generate
    mileto-serve
    mileto-delete
  ];

  buildPhase = ''
  '';

  shellHooks = ''
 '';
}

# tiles di mileto
