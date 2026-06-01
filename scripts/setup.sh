#!/bin/bash
set -e

echo "=== セットアップ開始 ==="

# Python依存パッケージのインストール
echo "--- Python パッケージをインストール中 ---"
pip3 install --user --no-cache-dir -r /workspace/requirements.txt

# Node.js / npm のインストール（textlint用）
echo "--- Node.js をインストール中 ---"
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y --no-install-recommends nodejs
sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

# textlint のインストール
echo "--- textlint をインストール中 ---"
cd /workspace && npm install

# バックアップディレクトリの作成
mkdir -p /workspace/backups
mkdir -p /workspace/figures

echo "=== セットアップ完了 ==="
