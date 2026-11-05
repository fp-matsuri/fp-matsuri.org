# VRT のスクリーンショットが何で描画されるかと、ベースラインを
# 何が更新するかを定める場所。y047aka/elm-motorsport-analysis の
# nix/vrt.nix からの移植で、スクリーンショットに関わるコマンドは
# flake.nix ではなくここにある、という原則はそのまま。
# 参照元の Elm ツールチェーンと CI のベースライン更新ランナーは
# 本サイトに相当物がないため移植していない。
{ pkgs }:

let
  playwrightModules = "${pkgs.playwright-test}/lib/node_modules";

in
rec {
  # フォントはホスト任せにせず名指しする。そのマシンにあるフォント
  # で描画されたベースラインは、そのマシンでしか再現できないものになる。
  # ipafont がページ中の日本語を、freefont と wqy が latin と
  # CJK のフォールバックを担う。
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

  # python3 は config の webServer が作業コピーを配信する静的サーバ。
  # サイトとそのファイルの間にバウンダーは介在しない。
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
