#!/usr/bin/env bash
set -e

echo "🛠️ 環境セットアップ開始..."

# PATH修正（nvm / flutter）
export NVM_DIR="/usr/local/nvm"
export ANDROID_SDK_ROOT="/opt/android-sdk"
export PATH=$PATH:/flutter/bin:$NVM_DIR/versions/node/v22/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# FlutterのGit安全設定
sudo git config --system --add safe.directory /flutter

# Git設定のエラー回避
if [ -d "$HOME/.gitconfig" ]; then
  echo "⚠️ /home/dev/.gitconfig がディレクトリです。バックアップ中..."
  mv "$HOME/.gitconfig" "$HOME/.gitconfig_dir_backup_$(date +%s)"
fi

# FlutterとNodeのバージョン確認
echo "🔍 バージョン確認:"
flutter --version || echo "⚠️ Flutter not found"
bash -c ". $NVM_DIR/nvm.sh && node -v && npm -v && amplify --version" || echo "⚠️ Node/Amplify not found"

# Amplify CLI のパス再登録（NVM PATH補強）
sudo ln -sf "$NVM_DIR/versions/node/v22/bin/amplify" /usr/local/bin/amplify
sudo ln -sf "$NVM_DIR/versions/node/v22/bin/node" /usr/local/bin/node
sudo ln -sf "$NVM_DIR/versions/node/v22/bin/npm" /usr/local/bin/npm

# Flutterキャッシュ更新
flutter precache

echo "✅ セットアップ完了！"
