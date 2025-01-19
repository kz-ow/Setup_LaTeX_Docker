#!/bin/bash
set -e

echo "初回セットアップを開始します..."

# 例: インストール済みパッケージのアップデート（必要に応じて）
sudo apt-get update && sudo apt-get upgrade -y

# 必要なキャッシュのクリーンアップ
sudo apt-get clean

echo "初回セットアップが完了しました。"
