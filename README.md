# fp-matsuri.org

関数型まつりのサイト。

## 開発環境 (Nix を推奨)

[Nix flake](https://nixos.wiki/wiki/Flakes) が Node・pnpm・Chromium・フォントまで固定し、リポジトリが要求するものだけを与える。

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
| `update-snapshots-vrt` | 意図的な変更後にベースラインを更新する |

## 構成

```
index.html            ページ本体 (唯一の Tailwind ソース)
src/input.css         source(none) + @source で走査対象を固定
assets/css/app.css    Tailwindでビルドされた CSS 成果物
assets/images/        ロゴ・サムネイル・favicon
tests/                Playwright VRT の仕様とベースライン
nix/vrt.nix           VRT の描画環境 (Chromium とフォントの固定)
flake.nix             開発環境とコマンドの宣言
```

## CSS

Tailwind v4 + DaisyUI 5 を Tailwind CLI でビルドし、成果物をコミットする (CDN/browser ビルドは使わない)。
`src/input.css` は自動検出を切り、`index.html` だけを走査する — さもなければコミット済み CSS がリポジトリ内容の関数になる。

**CSS を変えたら、必ず `nix run .#build` の結果を一緒にコミットする。**
CI が再生成ビルドとコミット済み CSS のバイト一致を検査する (byte fence、`.github/workflows/build.yml`)。

## VRT

Playwright + Chromium (単一プロジェクト、1440×900、fullPage)。
ブラウザはnixpkgs の playwright-driver、フォントは `FONTCONFIG_FILE` で ipafont ほかを名指しし、マシン依存を切る。基準は Linux のレンダリングで、CI では差分 0 ピクセル、ローカルでは `tests/screenshot.css` のグレースケール アンチエイリアスで小幅の許容。
ベースラインはプラットフォーム名のない 1 枚きりで、描画環境は名前でなくフォント固定が担う。
意図した変更で差分が出たら、ブランチに `Update VRT Snapshots` を dispatch して
Linux ランナーで打ち直す (bot が同じブランチへ push する)。

## CI

GitHub Actions (`.github/workflows/build.yml`) が PR と任意ブランチのpush で走る:
依存の脆弱性監査 (`pnpm audit`、high のみ失敗) → CSS 再生成 → byte fence

ブランチ名は絞らない (tags は除く)。
静的ファイルの集まりで失敗のコストは低く、byte fence の故障はどのブランチでも早く知りたいから。
ジョブの権限は `contents: read`、要求するのはチェックアウトだけ。
