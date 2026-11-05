# What the visual regression tests render with, and what refreshes their
# baselines. Ported from y047aka/elm-motorsport-analysis's nix/vrt.nix: a
# command belongs here rather than in flake.nix when it is about a
# screenshot. The Elm toolchain and the CI snapshot-refresh runner of the
# reference have no analogue here and were not ported.
{ pkgs }:

let
  playwrightModules = "${pkgs.playwright-test}/lib/node_modules";

in
rec {
  # The fonts are named rather than left to the host: a baseline rendered
  # against whichever fonts a machine happens to have is one only that
  # machine can reproduce. ipafont carries the Japanese the page holds,
  # freefont and wqy the latin and CJK fallbacks.
  env = {
    FONTCONFIG_FILE = pkgs.makeFontsConf {
      fontDirectories = with pkgs; [ ipafont freefont_ttf wqy_zenhei ];
    };
    PLAYWRIGHT_BROWSERS_PATH = pkgs.playwright-driver.browsers.override {
      withFirefox = false;
      withWebkit = false;
    };
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  };

  # python3 is the static server the config's webServer runs over the
  # working copy; no bundler stands between this site and its files.
  mkApp = name: cmd:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.nodejs_26 pkgs.pnpm pkgs.playwright-test pkgs.python3 ];
      text = ''
        export FONTCONFIG_FILE=${env.FONTCONFIG_FILE}
        export PLAYWRIGHT_BROWSERS_PATH=${env.PLAYWRIGHT_BROWSERS_PATH}
        export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=${env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD}
        export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=${env.PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS}

        # Symlink @playwright/test into node_modules for ESM resolution
        mkdir -p node_modules/@playwright
        ln -sfn ${playwrightModules}/@playwright/test node_modules/@playwright/test

        ${cmd}
      '';
    };
}
