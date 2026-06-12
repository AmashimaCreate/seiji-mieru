# 政治見える化（seiji-mieru.com）

政治を、数字と一次資料で「見えるかたち」にするプロジェクトの**入口（ハブ）**です。
Cloudflare Pages がこのリポジトリをビルドし、1ドメインにサブパスで配信します。

| パス | 内容 | 取り込み元 |
|---|---|---|
| `/` | ハブ（テーマ選択の入口） | このリポジトリ |
| `/houan/` | 立法タイムライン（国会で成立した法律の見える化） | [legislative_timeline](https://github.com/AmashimaCreate/legislative_timeline)（静的） |
| `/zairyu/` | 外国人マップ（在留外国人の数を地図で） | [foreign-resident-map](https://github.com/AmashimaCreate/foreign-resident-map)（Vite, `base=/zairyu/`） |
| `/tottori/` | 地方議会見える化（鳥取県と4市の議員・議決・発言・街のデータ） | [tottori-mieru](https://github.com/AmashimaCreate/tottori-mieru)（docs 配信構成） |

## ビルド（Cloudflare Pages）
- **Build command**: `bash build.sh`
- **Build output directory**: `dist`

`build.sh` が ① 立法（静的）を `/houan` に、② 外国人マップ（Vite）を `base=/zairyu/` でビルドして `/zairyu` に、③ 地方議会見える化（docs 配信）を `/tottori` に集約します。

## 安全性
- 取り込むのは**公開リポジトリのみ**（clone にトークン不要）。
- **生成スクリプト・APIキーは一切含みません**（立法の要約生成は非公開リポジトリで行い、データだけが legislative_timeline に流れます）。
