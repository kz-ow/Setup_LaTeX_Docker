# CLAUDE.md — 論文執筆支援エージェント指示書

## リポジトリ構成

```
.
├── Dockerfile                  # ubuntu:24.04 ベースの LaTeX + Python 環境
├── .devcontainer/              # VS Code DevContainer 設定
├── .latexmkrc                  # latexmk 設定（papers/<name>/latexmk.conf を読む）
├── Makefile                    # pdf / watch / clean / lint / diff / eps
├── requirements.txt            # Python 依存パッケージ
├── package.json                # textlint 依存パッケージ
├── .textlintrc                 # textlint ルール設定
├── prh.yml                     # 表記ゆれ辞書
├── papers/
│   └── <論文名>/               # 論文ごとにフォルダを作る（1論文 = 1フォルダ）
│       ├── latexmk.conf        # エンジン設定（init_paper.sh が自動生成）
│       ├── main.tex            # ← ここに本文を書く（\documentclass〜\end{document} 完結）
│       ├── references.bib
│       └── Makefile            # pdf / watch / clean / lint / diff
├── format/                     # フォーマット定義（投稿先ごとに追加）
│   ├── default_japanese/       # デフォルト日本語（jsarticle + uplatex）
│   └── default_english/        # デフォルト英語（article + lualatex）
├── figures/                    # 図ファイル（EPS / PDF）
├── backups/                    # PDF スナップショット
└── scripts/
    ├── setup.sh                # DevContainer 初回セットアップ
    └── init_paper.sh           # 新しい論文フォルダを作成するスクリプト
```

## 論文の新規作成

```bash
# デフォルトフォーマットで日本語論文を作成
scripts/init_paper.sh my_paper_2026 default_japanese

# cls ファイルのあるディレクトリを直接指定
scripts/init_paper.sh ipsj_2026 format/ipsj_v4-1/UTF8

# 生成後
cd papers/my_paper_2026
# main.tex を編集してから：
make pdf
```

## ビルド方法

```bash
# papers/<name>/ の中から直接実行（推奨）
cd papers/my_paper_2026
make pdf
make watch   # ホットリロード

# ワークスペースルートから実行
make pdf   PAPER=my_paper_2026
make watch PAPER=my_paper_2026
make lint  PAPER=my_paper_2026
make diff  PAPER=my_paper_2026 OLD=<git-tag>
```

## format/ の規約

`format/<name>/` に以下のファイルを置くと `init_paper.sh` のテンプレートとして利用できる。

| ファイル | 役割 |
|---|---|
| `latexmk.conf` | エンジン・bibtex 設定 |
| `main.tex` | 本文テンプレート（`\documentclass`〜`\end{document}` 完結） |

### latexmk.conf のキー

```
latex_cmd=uplatex         # platex / uplatex / lualatex / pdflatex
latex_opts=-kanji=utf8 -synctex=1 -interaction=nonstopmode
bibtex_cmd=biber          # upbibtex / biber
pdf_mode=dvi              # dvi / pdf
```

### 新フォーマットの追加手順

```bash
# cls/sty を format/<vendor>/ に配置して init_paper.sh を実行するだけでOK
scripts/init_paper.sh ipsj_2026 format/ipsj_v4-1/UTF8
```

## Claude Code への指示

### 文献管理
- `references.bib` を読んで引用キーの整合性を確認すること
- arXiv API（Python スクリプト）で関連論文を検索する場合は `scripts/` 以下にスクリプトを作成すること
- 使用フォーマットの `bibtex_cmd` に合わせて BibTeX エントリを生成すること（biber なら biblatex 形式、upbibtex なら従来形式）

### 執筆支援
- 本文は `papers/<name>/main.tex` に直接書くこと（`sections/` への分割は不要）
- `main.tex` は `\documentclass`〜`\end{document}` の自己完結ファイルにすること
- 数式は `amsmath` パッケージの記法を使うこと
- 図の参照は `\ref{fig:xxx}` 形式で統一すること
- 日本語論文では「である調」を基本とすること

### 品質チェック
- `make lint PAPER=<name>` で textlint を実行して日本語文章を校正すること
- 図番号・表番号・式番号と本文中のラベルの整合性を確認すること
- コンパイルエラーが出た場合はログを読んで原因を特定してから修正すること

### latexdiff
- `make diff PAPER=<name> OLD=<タグ>` で旧バージョンとの差分 PDF を生成できる
- レビュー返しの際は差分 PDF を `backups/` に保存すること

## 使用ジャーナル・スタイル

（投稿先が決まったらここに記述する）
例: IEEE Transactions / 情報処理学会論文誌 / NeurIPS / CVPR
