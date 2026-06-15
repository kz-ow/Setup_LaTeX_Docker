#!/bin/bash
set -e

echo "=== セットアップ開始 ==="

# Python依存パッケージのインストール
echo "--- Python パッケージをインストール中 ---"
/opt/venv/bin/pip install --no-cache-dir -r /workspace/requirements.txt

# textlint のインストール
echo "--- textlint をインストール中 ---"
cd /workspace && npm install

# ディレクトリの作成
mkdir -p /workspace/backups
mkdir -p /workspace/figures

echo "=== セットアップ完了 ==="