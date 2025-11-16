# クイックスタートガイド

「頑張る人のための稼働時間タイマー」の開発を**最速**で始めるためのガイドです。

---

## 🚀 5分で開発環境を構築

### 前提条件

✅ Windows 11 (64-bit)
✅ 空きディスク容量 15GB以上
✅ RAM 8GB以上

---

## ステップ1: 必須ツールのインストール (15分)

### 1. Git for Windowsをインストール

```powershell
# ダウンロード: https://git-scm.com/download/win
# インストール後、確認:
git --version
```

### 2. Flutter SDKをインストール

```powershell
# ダウンロード: https://docs.flutter.dev/get-started/install/windows
# C:\src\flutter に展開

# 環境変数に追加 (システム環境変数 > Path)
C:\src\flutter\bin

# 新しいPowerShellで確認:
flutter --version
flutter doctor
```

### 3. Android Studioをインストール

```powershell
# ダウンロード: https://developer.android.com/studio
# インストール後、Flutterプラグインを追加
```

### 4. VSCodeをインストール

```powershell
# ダウンロード: https://code.visualstudio.com/
# Flutterプラグインをインストール
```

**詳細な手順**: [README.md](./README.md)を参照

---

## ステップ2: プロジェクトのセットアップ (5分)

### このリポジトリをクローン

```powershell
# GitHubからクローン
cd C:\Users\<ユーザー名>\Documents
git clone https://github.com/<your-username>/flutter_dev.git
cd flutter_dev
```

### Flutterプロジェクトを作成

```powershell
# プロジェクトを作成 (初回のみ)
flutter create --org com.worktime --project-name work_time_tracker .

# 依存パッケージを取得
flutter pub get
```

### デバイスを確認

```powershell
flutter devices
```

**出力例:**
```
Chrome (web) • chrome • web-javascript
Android SDK  • emulator-5554 • android-x64
```

---

## ステップ3: アプリを起動 (1分)

### Webで起動（最速）

```powershell
flutter run -d chrome
```

### Androidエミュレーターで起動

```powershell
# エミュレーターを起動（Android Studio > AVD Manager）
# その後:
flutter run
```

---

## 🎨 開発の流れ

### VSCodeで開発

```powershell
# VSCodeでプロジェクトを開く
code .
```

#### 推奨VSCode拡張機能

- Flutter (Dart Code)
- Awesome Flutter Snippets
- Error Lens
- GitLens

### ホットリロード

アプリを実行中に:
- **r**: ホットリロード（変更をすぐ反映）
- **R**: ホットリスタート（アプリを再起動）
- **q**: 終了

---

## 📁 プロジェクト構造

```
flutter_dev/
├── lib/                    # アプリのソースコード
│   ├── main.dart          # エントリーポイント
│   ├── features/          # 機能モジュール
│   │   ├── timer/         # タイマー機能
│   │   ├── kanban/        # カンバンボード
│   │   ├── pomodoro/      # ポモドーロタイマー
│   │   ├── statistics/    # 統計・可視化
│   │   └── settings/      # 設定
│   └── core/              # 共通機能
│
├── test/                  # テストコード
├── docs/                  # ドキュメント
├── README.md              # 環境構築手順
├── QUICKSTART.md          # このファイル
└── pubspec.yaml           # 依存パッケージ管理
```

---

## 🔨 よく使うコマンド

### 開発中

```powershell
# アプリを実行（デバッグモード）
flutter run

# Webで実行
flutter run -d chrome

# パッケージを追加
flutter pub add パッケージ名

# パッケージを取得
flutter pub get

# コード生成（build_runnerを使用時）
flutter pub run build_runner build --delete-conflicting-outputs
```

### ビルド

```powershell
# Androidビルド（APK）
flutter build apk --release

# Androidビルド（App Bundle）
flutter build appbundle --release

# Webビルド
flutter build web --release
```

### トラブルシューティング

```powershell
# キャッシュをクリア
flutter clean

# 環境を確認
flutter doctor -v

# Androidライセンスに同意
flutter doctor --android-licenses
```

---

## 📚 ドキュメント

- **[README.md](./README.md)**: 詳細な環境構築手順
- **[docs/PROJECT_SETUP.md](./docs/PROJECT_SETUP.md)**: プロジェクトセットアップガイド
- **[docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)**: アーキテクチャ設計書
- **[docs/SETUP_TROUBLESHOOTING.md](./docs/SETUP_TROUBLESHOOTING.md)**: トラブルシューティング

---

## 🎯 開発ロードマップ

### Phase 1: MVP（基本機能）

- [ ] タイマー機能（ストップウォッチ）
- [ ] タスク一覧表示
- [ ] 時間記録と保存
- [ ] シンプルな統計表示

### Phase 2: コア機能

- [ ] カンバンボード実装
- [ ] ポモドーロタイマー
- [ ] GitHub風ヒートマップ
- [ ] 通知機能

### Phase 3: 拡張機能

- [ ] ダークモード
- [ ] データエクスポート
- [ ] タスクタグ・フィルター
- [ ] 達成バッジシステム

---

## ❓ よくある質問

### Q: iOSアプリはWindowsで開発できますか？

A: WindowsではiOSアプリの直接ビルドはできませんが、Flutterコードはクロスプラットフォームなので、Mac環境やCI/CDサービス（Codemagic、GitHub Actionsなど）でビルド可能です。

### Q: エミュレーターが起動しません

A: BIOSで仮想化（Intel VT-xまたはAMD-V）を有効にしてください。詳細は[SETUP_TROUBLESHOOTING.md](./docs/SETUP_TROUBLESHOOTING.md)を参照。

### Q: どのIDEを使うべきですか？

A: VSCodeとAndroid Studioの両方を推奨します。
- **VSCode**: 軽量で高速。日常的なコーディングに最適
- **Android Studio**: Androidエミュレーターの管理、プロファイリングに便利

---

## 🤝 コントリビューション

プルリクエスト、Issue報告、機能提案を歓迎します！

---

## 📞 サポート

問題が発生した場合:
1. [SETUP_TROUBLESHOOTING.md](./docs/SETUP_TROUBLESHOOTING.md)を確認
2. GitHubでIssueを作成
3. Flutterコミュニティで質問

---

**🎉 準備完了！素晴らしいアプリを作りましょう！**

