# fp-matsuri.org

関数型まつりのサイト。ビルド不要で読める静的ファイルの集まりで、
GitHub Pages がコミット済みのファイルをそのまま配る。

## 開発環境 (Nix を推奨)

[Nix flake](https://nixos.wiki/wiki/Flakes) が Node・pnpm・Chromium・
フォントまで固定し、リポジトリが要求するものだけを与える。

```console
$ nix develop          # nodejs と pnpm のシェル
$ nix run .#install    # 依存のインストール (pnpm-lock.yaml 準拠)
```

Nix を使わない場合も `packageManager` に合った pnpm があれば動く。

```console
$ pnpm install
```

## コマンド

すべて `nix run .#<名前>` (シェル内なら単体コマンド) で呼ぶ。

| コマンド | 役割 |
|---|---|
| `install` | `pnpm install --frozen-lockfile` |
| `build` | Tailwind CSS をビルドして `assets/css/app.css` を書く |
| `watch` | 同上の監視ビルド |
| `test-vrt` | VRT: ページを撮り、コミット済みベースラインと突き合わせる |
| `update-snapshots-vrt` | 意図的な変更後にベースラインを打ち直す |

## 構成

```
index.html            ページ本体 (唯一の Tailwind ソース)
src/input.css         Tailwind の入口。source(none) + @source で走査対象を固定
assets/css/app.css    ビルド済み CSS。コミットされ、Pages がこれを配る
assets/images/        ロゴ・サムネイル・favicon
tests/                Playwright VRT の仕様とベースライン
nix/vrt.nix           VRT の描画環境 (Chromium とフォントの固定)
flake.nix             開発環境とコマンドの宣言
```

## CSS の流儀

Tailwind v4 + DaisyUI 5 を Tailwind CLI でビルドし、成果物をコミットする
(CDN/browser ビルドは使わない)。`src/input.css` は自動検出を切り、
`index.html` だけを走査する — さもなければコミット済み CSS が
リポジトリ内容の関数になる。

**CSS を変えたら、必ず `nix run .#build` の結果を一緒にコミットする。**
CI が再生成ビルドとコミット済み CSS のバイト一致を検査する
(byte fence、`.github/workflows/build.yml`)。

## VRT

Playwright + Chromium (単一プロジェクト、1440×900、fullPage)。ブラウザは
nixpkgs の playwright-driver、フォントは `FONTCONFIG_FILE` で ipafont ほか
を名指しし、マシン依存を切る。基準は Linux のレンダリングで、CI では
差分 0 ピクセル、ローカルでは `tests/screenshot.css` のグレースケール
アンチエイリアスで小幅の許容。現在のベースラインは macOS で生成した
初回版なので、CI で VRT を回す段階では Linux で打ち直しになる。

## CI

GitHub Actions (`.github/workflows/build.yml`) が PR と任意ブランチの
push で走る: 依存の脆弱性監査 (`pnpm audit`、high のみ失敗) →
CSS 再生成 → byte fence。
