FROM nixos/nix:latest
LABEL maintainer="ariel@piensa.co"

# download base system to accelerate further builds
# when default.nix changes
RUN nix-shell -p caddy

WORKDIR /usr/src/
ADD default.nix /usr/src/

RUN nix-shell

RUN nix-shell --run build-tiles

ENTRYPOINT ["nix-shell"]

EXPOSE 2015/tcp

CMD ["--run", "caddy"]
