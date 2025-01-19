# Setup_LaTeX_Docker# LaTeX Devcontainer

このプロジェクトは、Dev Containers と docker-compose を利用した LaTeX 開発環境構築のサンプルです。文献管理（BibTeX/Biber）をサポートしています。

## 特徴

- **自動コンパイル（ホットリロード）:**  
  ファイル変更時に `latexmk` で自動ビルドを実行し、VS Code の PDF プレビューと連携。

- **文献管理サポート:**  
  BibTeXおよびBiberを使用した文献管理をサポート。`.bib`ファイルの自動処理。

- **拡張機能自動インストール:**  
  LaTeX Workshop、コードスペルチェック、BibTeX 補完、Markdown サポート、Bracket Pair Colorizer、GitLens を自動インストール。

- **サンプルテンプレート提供:**  
  `examples/japanese` と `examples/english` にサンプルの LaTeX テンプレートと `.bib` ファイルを用意。

- **セットアップスクリプト:**  
  初回起動時に必要なパッケージ更新や環境のセットアップを自動実行。

## 利用手順

1. リポジトリをクローンしてください。

   ```bash
   git clone https://github.com/your_account/latex-devcontainer.git
   cd latex-devcontainer
