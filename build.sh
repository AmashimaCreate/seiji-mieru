#!/usr/bin/env bash
# seiji-mieru.com の集約ビルド：ハブ(root) ＋ /houan(立法タイムライン) ＋ /zairyu(外国人マップ) ＋ /tools(くらしと制度) ＋ /tottori(地方議会見える化) ＋ /boeki(貿易見える化) ＋ /words(国会ワードカウント)。
# Cloudflare Pages 設定 →  Build command: bash build.sh   /   Build output directory: dist
#
# ※ APIキー・生成スクリプトは取り込まない。clone するのは公開リポジトリのみ（トークン不要）。
set -euo pipefail

OUT="dist"
rm -rf "$OUT"; mkdir -p "$OUT"

# --- ハブ（ルート） ---
cp index.html favicon.svg og-image.jpg apple-touch-icon.png "$OUT"/
[ -f _redirects ] && cp _redirects "$OUT"/_redirects

# --- /houan = 立法タイムライン（静的・全パス相対なのでそのまま配置） ---
git clone --depth 1 https://github.com/AmashimaCreate/legislative_timeline.git "$OUT/houan"
rm -rf "$OUT/houan/.git" "$OUT/houan/README.md" "$OUT/houan/.gitignore"

# --- /zairyu = 外国人マップ（Vite を base=/zairyu/ でビルド） ---
#   ↓ 実際のビルド手順は foreign-resident-map の package.json / vite.config を確認して確定する（②）。
git clone --depth 1 https://github.com/AmashimaCreate/foreign-resident-map.git zairyu-src
( cd zairyu-src && npm ci && npx vite build --base=/zairyu/ )
cp -r zairyu-src/dist "$OUT/zairyu"
rm -f "$OUT/zairyu/CNAME"   # GitHub Pages 用の名残（Cloudflareでは不要）
rm -rf zairyu-src

# --- /tools = くらしと制度のツール（手取り・年収の壁。Vite マルチページ、base は vite.config 側で /tools/ 指定済み） ---
git clone --depth 1 https://github.com/AmashimaCreate/seiji-tools.git tools-src
( cd tools-src && npm ci && npm run build )
cp -r tools-src/dist "$OUT/tools"
rm -rf tools-src

# --- /tottori = 地方議会見える化（docs 配信構成。公開物は docs/ のみ） ---
git clone --depth 1 https://github.com/AmashimaCreate/tottori-mieru.git tottori-src
mkdir -p "$OUT/tottori"
cp -R tottori-src/docs/. "$OUT/tottori"
rm -rf tottori-src

# --- /boeki = 貿易見える化（Vite を base=/boeki/ でビルド＋国別静的ページSSG） ---
#   公開リポジトリ未作成の間はスキップ（clone失敗を許容）。作成後は自動で有効化される。
if git clone --depth 1 https://github.com/AmashimaCreate/trade-map.git boeki-src; then
  ( cd boeki-src && npm ci && npx vite build --base=/boeki/ && node scripts/gen_static.mjs )
  cp -r boeki-src/dist "$OUT/boeki"
  rm -rf boeki-src
else
  echo "⚠ trade-map 公開リポジトリ未作成 → /boeki はスキップ（リポジトリ作成後に有効化）"
fi

# --- /words = 国会ワードカウント（静的・全パス相対なのでそのまま配置） ---
#   公開リポジトリ未作成の間はスキップ（clone失敗を許容）。作成後は自動で有効化される。
if git clone --depth 1 https://github.com/AmashimaCreate/kokkai-words.git words-src; then
  mkdir -p "$OUT/words"
  cp words-src/index.html words-src/style.css words-src/app.js words-src/favicon.svg words-src/data.json "$OUT/words"/
  [ -f words-src/og-image.png ] && cp words-src/og-image.png "$OUT/words"/
  rm -rf words-src
else
  echo "⚠ kokkai-words 公開リポジトリ未作成 → /words はスキップ（リポジトリ作成後に有効化）"
fi

echo "✓ built: $OUT  ( / , /houan , /zairyu , /tools , /tottori , /boeki , /words )"
