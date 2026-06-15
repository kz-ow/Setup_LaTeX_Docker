# LaTeX DevContainer + Claude Code

Docker DevContainer 上に LaTeX 環境を構築し、Claude Code が論文執筆を支援するプラットフォームです。

## 特徴

- **DevContainer で即起動** — ローカルに LaTeX をインストール不要。VS Code で開くだけで環境が整います
- **1論文 = 1フォルダ** — `papers/<name>/` に論文ごとのフォルダを作り、`main.tex` 一本で完結
- **フォーマット切り替え** — `format/` にクラスファイルを置いてスクリプトを実行するだけで即ビルド可能
- **Claude Code 統合** — `CLAUDE.md` を読んでリポジトリ構成・論文方針を把握した状態で執筆支援
- **textlint による文章校正** — ら抜き言葉・表記ゆれ・二重否定を自動検出（日本語）
- **latexdiff による差分 PDF** — レビュー返しの際に旧バージョンとの差分 PDF を生成

## 環境

- Windows（WSL2）/ macOS / Linux
- Docker Desktop
- VS Code + Dev Containers 拡張

## セットアップ

```bash
git clone <this-repo>
cd <this-repo>
```

VS Code でフォルダを開き、「Reopen in Container」を選択します。

## 使い方

### 1. 論文フォルダを作成

```bash
# デフォルトテンプレート（日本語）
scripts/init_paper.sh my_paper_2026 default_japanese

# デフォルトテンプレート（英語）
scripts/init_paper.sh my_paper_2026 default_english

# cls ファイルのあるディレクトリを直接指定
scripts/init_paper.sh ipsj_2026 format/ipsj_v4-1/UTF8
```

`papers/my_paper_2026/` が作成され、`main.tex`・`references.bib`・`latexmk.conf`・`Makefile` が自動生成されます。

### 2. 執筆

`papers/<name>/main.tex` を直接編集します（`\documentclass`〜`\end{document}` の自己完結ファイル）。

### 3. ビルド

```bash
# papers/<name>/ の中から実行（推奨）
cd papers/my_paper_2026
make pdf          # PDF をビルド
make watch        # ファイル変更を監視して自動ビルド
make clean        # 中間ファイルを削除
make lint         # textlint で文章校正（日本語）
make diff OLD=v1.0  # 旧バージョンとの差分 PDF を生成

# ワークスペースルートから実行
make pdf   PAPER=my_paper_2026
make watch PAPER=my_paper_2026
make lint  PAPER=my_paper_2026
make diff  PAPER=my_paper_2026 OLD=v1.0
```

### 4. その他

```bash
make eps   # figures/ の EPS ファイルを PDF に変換
```

## ディレクトリ構成

```
.
├── Dockerfile                  # ubuntu:24.04 + texlive-full + Python + pandoc
├── .devcontainer/
│   └── devcontainer.json       # DevContainer 設定（拡張機能・remoteUser 等）
├── .latexmkrc                  # latexmk 設定（papers/<name>/latexmk.conf を読む）
├── Makefile                    # タスクランナー（PAPER=<name> 指定）
├── CLAUDE.md                   # Claude Code への指示書
├── requirements.txt            # Python 依存パッケージ（arxiv, pdfplumber 等）
├── package.json                # textlint 依存パッケージ
├── .textlintrc                 # textlint ルール設定
├── prh.yml                     # 表記ゆれ辞書
├── papers/
│   └── <論文名>/               # 1論文 = 1フォルダ
│       ├── latexmk.conf        # エンジン設定（init_paper.sh が自動生成）
│       ├── main.tex            # 本文（\documentclass〜\end{document} 完結）
│       ├── references.bib      # 参考文献
│       └── Makefile            # pdf / watch / clean / lint / diff
├── format/                     # フォーマット定義（投稿先ごとに追加）
│   ├── default_japanese/       # デフォルト日本語（jsarticle + uplatex）
│   └── default_english/        # デフォルト英語（article + lualatex）
├── figures/                    # 図ファイル（EPS / PDF）
├── backups/                    # PDF スナップショット（レビュー管理用）
└── scripts/
    ├── setup.sh                # DevContainer 初回セットアップ
    └── init_paper.sh           # 論文フォルダ作成スクリプト
```

## 新しいフォーマットの追加

投稿先のクラスファイル（`.cls`）を `format/<vendor>/` に置き、`init_paper.sh` を実行するだけです。

```bash
# 例: IPSJ 向け論文を作成
mkdir -p format/ipsj_v4-1/UTF8
cp path/to/ipsj.cls format/ipsj_v4-1/UTF8/
scripts/init_paper.sh ipsj_2026 format/ipsj_v4-1/UTF8
```

エンジン（platex / uplatex / lualatex）はクラスファイルの内容から自動判定されます。

## VS Code 拡張機能（自動インストール）

| 拡張機能 | 役割 |
|---|---|
| LaTeX Workshop | LaTeX プレビュー・自動ビルド |
| Claude Code | AI 論文執筆支援 |
| LTeX | 文法・スペルチェック（日英） |
| Code Spell Checker | 英語スペルチェック |
| GitLens | Git 履歴管理 |

## ライセンス

MIT
