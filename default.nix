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
       mkdir -p build
       ${gdal}/bin/ogr2ogr -f GeoJSON build/ne_10m_admin_0_countries.geojson ${admin0}/ne_10m_admin_0_countries.shp;
       ${gdal}/bin/ogr2ogr -f GeoJSON build/ne_10m_admin_1_states_provinces.geojson ${admin1}/ne_10m_admin_1_states_provinces.shp;
       ${tippecanoe}/bin/tippecanoe -z3 -o build/countries-z3.mbtiles --no-progress-indicator --coalesce-densest-as-needed build/ne_10m_admin_0_countries.geojson
       ${tippecanoe}/bin/tippecanoe -zg -Z4 -o build/states-z4.mbtiles --no-progress-indicator --coalesce-densest-as-needed --extend-zooms-if-still-dropping build/ne_10m_admin_1_states_provinces.geojson
       ${tippecanoe}/bin/tile-join --name=admin --output-to-directory=admin build/countries-z3.mbtiles build/states-z4.mbtiles
    '';
    
   caddy-conf = pkgs.writeText "caddy-conf" ''
     localhost {
       tls off
       bind 127.0.0.1
       request_id 
       mime .pbf application/x-protobuf

       cors /admin https://fresco.gospatial.org

       header /  Caddy-Request-Id {request_id}
 
       header /admin/ {
         Content-Encoding "gzip"
         Access-Control-Allow-Origin *
       }
 
       header /admin/metadata.json {
         -Content-Encoding
       }
     }
   '';
   server.go = pkgs.writeText "server.go" ''
     package main
     import (
       "github.com/caddyserver/caddy/caddy/caddymain"
       _ "github.com/captncraig/cors/caddy"
     )

     func main() {
       caddymain.EnableTelemetry = false
       caddymain.Run()
     }
   '';
   mileto-serve = pkgs.writeShellScriptBin "mileto-serve" ''
      go run ${server.go} -conf ${caddy-conf}
   '';
   mileto-delete = pkgs.writeShellScriptBin "mileto-delete" ''
      rm -rf admin
      rm -rf build
   '';
in pkgs.stdenv.mkDerivation rec {
  name = "mileto";
  src = [ admin0 admin1];
  buildInputs = [
    pkgs.bash
    pkgs.caddy
    pkgs.nodejs
    pkgs.go_1_12
    mileto-generate
    mileto-serve
    mileto-delete
  ];

  buildPhase = ''
  '';

  shellHooks = ''
   export GOPATH="/tmp/go"
   export GO111MODULE=on
 '';
}

# tiles di mileto
