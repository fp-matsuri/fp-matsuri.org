{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # A runner carrying the Node and pnpm toolchain, in the style of
        # y047aka/elm-motorsport-analysis. This site is a single npm project
        # at the repository root, so the commands need no `cd` and simply
        # dispatch to the pnpm scripts.
        mkNodeApp = name: cmd:
          pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [ pkgs.nodejs_26 pkgs.pnpm ];
            text = cmd;
          };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ nodejs_26 pnpm ];
        };

        apps = {
          install = { type = "app"; program = "${mkNodeApp "install" "pnpm install --frozen-lockfile"}/bin/install"; meta.description = "Install dependencies from pnpm-lock.yaml"; };
          build   = { type = "app"; program = "${mkNodeApp "build" "pnpm run build"}/bin/build"; meta.description = "Build Tailwind CSS to assets/css/app.css"; };
          watch   = { type = "app"; program = "${mkNodeApp "watch" "pnpm run watch"}/bin/watch"; meta.description = "Rebuild Tailwind CSS on change"; };
        };
      });
}
