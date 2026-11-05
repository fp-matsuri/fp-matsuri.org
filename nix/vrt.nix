# VRT のスクリーンショットが何で描画されるかを定める場所。
# スクリーンショットに関わるコマンドは flake.nix ではなくここにある。
# y047aka/elm-motorsport-analysis の nix/vrt.nix からの移植。
{ pkgs }:

let
  playwrightModules = "${pkgs.playwright-test}/lib/node_modules";

in
rec {
  # フォントはホスト任せにせず名指しする。マシンにあるフォントでの
  # 描画は、そのマシンでしか再現できないベースラインになる。
  # ipafont が日本語、freefont と wqy が latin / CJK フォールバック。
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

  # python3 は webServer が作業コピーを配信する静的サーバ。
  mkApp = name: cmd:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = [ pkgs.nodejs_26 pkgs.pnpm pkgs.playwright-test pkgs.python3 ];
      text = ''
        export FONTCONFIG_FILE=${env.FONTCONFIG_FILE}
        export PLAYWRIGHT_BROWSERS_PATH=${env.PLAYWRIGHT_BROWSERS_PATH}
        export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=${env.PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD}
        export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=${env.PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS}

        # ESM 解決のため @playwright/test を node_modules へ symlink する
        mkdir -p node_modules/@playwright
        ln -sfn ${playwrightModules}/@playwright/test node_modules/@playwright/test

        ${cmd}
      '';
    };
}
