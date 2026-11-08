{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        mkNodeApp = name: cmd:
          pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [ pkgs.nodejs_26 pkgs.pnpm ];
            text = cmd;
          };

        vrt = import ./nix/vrt.nix { inherit pkgs; };
      in {
        devShells.default = pkgs.mkShell (vrt.env // {
          buildInputs = with pkgs; [ nodejs_26 pnpm playwright-test ];
        });

        apps = {
          install = { type = "app"; program = "${mkNodeApp "install" "pnpm install --frozen-lockfile"}/bin/install"; meta.description = "Install dependencies from pnpm-lock.yaml"; };
          build   = { type = "app"; program = "${mkNodeApp "build" "pnpm run build"}/bin/build"; meta.description = "Build Tailwind CSS to assets/css/app.css"; };
          watch   = { type = "app"; program = "${mkNodeApp "watch" "pnpm run watch"}/bin/watch"; meta.description = "Rebuild Tailwind CSS on change"; };

          test-vrt             = { type = "app"; program = "${vrt.mkApp "test-vrt" "playwright test \"$@\""}/bin/test-vrt"; meta.description = "Run Playwright VRT tests against the committed baselines"; };
          update-snapshots-vrt = { type = "app"; program = "${vrt.mkApp "update-snapshots-vrt" "playwright test --update-snapshots \"$@\""}/bin/update-snapshots-vrt"; meta.description = "Refresh the VRT baselines on this machine's rasteriser"; };
        };
      });
}
