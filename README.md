# 頑張る人のための稼働時間タイマー

Flutter製のクロスプラットフォーム（Android/iOS/Web）タイマー＆タスク管理アプリ

## アプリ概要

稼働時間の記録、カンバンボード式タスク管理、ポモドーロタイマー、GitHub風の活動可視化機能を備えた生産性向上アプリです。

### 主要機能
- ⏱️ **稼働時間ストップウォッチ**: タスク別に作業時間を記録
- 📋 **カンバンボード**: ToDo/進行中/完了でタスクを管理
- 🍅 **ポモドーロタイマー**: 集中作業と休憩を効率的に管理
- 📊 **GitHub風可視化**: 過去の活動をヒートマップで表示

---

## 🖥️ Windows 11でのFlutter開発環境構築手順

このガイドでは、Windows 11でFlutterの開発環境を構築し、Android、Web、iOS（※）アプリを開発できる環境を整えます。

> **⚠️ iOS開発について**: WindowsではiOSアプリの直接ビルド・実行はできません。FlutterコードはクロスプラットフォームなのでMac環境やCI/CDでビルド可能です。

---

### 📋 システム要件

- **OS**: Windows 11 (64-bit)
- **ディスク空き容量**: 最低 10GB (推奨 20GB以上)
- **RAM**: 最低 8GB (推奨 16GB以上)
- **PowerShell**: 5.0以降 (Windows 11には標準搭載)

---

## ステップ1: Gitのインストール

### 1-1. Git for Windowsのダウンロード

1. [Git公式サイト](https://git-scm.com/download/win)にアクセス
2. 「64-bit Git for Windows Setup」をダウンロード
3. インストーラーを実行

### 1-2. インストール設定

- **Adjusting your PATH environment**: 「Git from the command line and also from 3rd-party software」を選択
- **Choosing the SSH executable**: 「Use bundled OpenSSH」を選択
- **Configuring the line ending conversions**: 「Checkout Windows-style, commit Unix-style line endings」を選択
- その他はデフォルトでOK

### 1-3. 動作確認

PowerShellまたはコマンドプロンプトで確認:
```powershell
git --version
# 出力例: git version 2.43.0.windows.1
```

---

## ステップ2: Flutter SDKのインストール

### 2-1. Flutter SDKのダウンロード

1. [Flutter公式サイト](https://docs.flutter.dev/get-started/install/windows)にアクセス
2. 最新の安定版（Stable）をダウンロード
   - ファイル名: `flutter_windows_3.x.x-stable.zip`

### 2-2. Flutter SDKの展開

1. ダウンロードしたZIPファイルを展開
2. **推奨配置場所**: `C:\src\flutter`
   - ⚠️ `C:\Program Files`などスペースを含むパスは避ける

```powershell
# PowerShellで展開例
Expand-Archive -Path "C:\Users\<ユーザー名>\Downloads\flutter_windows_*.zip" -DestinationPath "C:\src"
```

### 2-3. 環境変数の設定

**システム環境変数にFlutterのパスを追加:**

1. Windowsキー + `R` → `sysdm.cpl` を実行
2. 「詳細設定」タブ → 「環境変数」をクリック
3. 「システム環境変数」の「Path」を選択 → 「編集」
4. 「新規」をクリックし、以下を追加:
   ```
   C:\src\flutter\bin
   ```
5. OKですべて閉じる

### 2-4. 動作確認

**新しいPowerShellウィンドウを開いて実行:**
```powershell
flutter --version
# 出力例: Flutter 3.24.0 • channel stable
```

### 2-5. Flutter Doctorの実行

環境の状態を確認:
```powershell
flutter doctor
```

**初回実行時の出力例:**
```
Doctor summary (to see all details, run flutter doctor -v):
[√] Flutter (Channel stable, 3.24.0, on Microsoft Windows [Version 10.0.22631], locale ja-JP)
[X] Android toolchain - develop for Android devices
[!] Chrome - develop for the web
[X] Visual Studio - develop Windows apps
[X] Android Studio (not installed)
[√] VS Code (version 1.92)
[!] Connected device
```

これから各項目を解決していきます。

---

## ステップ3: Android Studioのインストール

### 3-1. Android Studioのダウンロード

1. [Android Studio公式サイト](https://developer.android.com/studio)にアクセス
2. 「Download Android Studio」をクリック
3. 利用規約に同意してダウンロード

### 3-2. Android Studioのインストール

1. インストーラーを実行
2. **セットアップタイプ**: 「Standard」を選択
3. 必要なコンポーネントが自動でインストールされます:
   - Android SDK
   - Android SDK Platform
   - Android Virtual Device (AVD)

### 3-3. Android Studioの初期設定

1. Android Studioを起動
2. 「More Actions」→ 「SDK Manager」を開く
3. **SDK Platforms**タブで以下をインストール:
   - ✅ Android 13.0 (Tiramisu) - API Level 33
   - ✅ Android 14.0 (UpsideDownCake) - API Level 34
4. **SDK Tools**タブで以下を確認/インストール:
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Command-line Tools
   - ✅ Android Emulator
   - ✅ Android SDK Platform-Tools

### 3-4. Flutterプラグインのインストール

1. Android Studioで「Settings」→ 「Plugins」
2. 「Marketplace」で「Flutter」を検索
3. 「Install」をクリック（Dartプラグインも自動インストールされます）
4. Android Studioを再起動

### 3-5. Android Licensesの承諾

PowerShellで実行:
```powershell
flutter doctor --android-licenses
```
すべて `y` で同意します。

---

## ステップ4: VSCodeのセットアップ

### 4-1. Visual Studio Codeのインストール

1. [VSCode公式サイト](https://code.visualstudio.com/)からダウンロード
2. インストーラーを実行
3. **推奨オプション**:
   - ✅ Add "Open with Code" action to Windows Explorer file context menu
   - ✅ Add "Open with Code" action to Windows Explorer directory context menu
   - ✅ Add to PATH

### 4-2. Flutter拡張機能のインストール

VSCodeを起動して:
1. 拡張機能アイコン（Ctrl + Shift + X）をクリック
2. 以下の拡張機能をインストール:

**必須:**
- **Flutter** (by Dart Code)
- **Dart** (by Dart Code) - Flutterと一緒に自動インストールされます

**推奨:**
- **Awesome Flutter Snippets** - コードスニペット
- **Pubspec Assist** - 依存関係管理
- **Error Lens** - エラーの視覚化
- **GitLens** - Git統合強化

### 4-3. VSCodeの設定

`Ctrl + ,` で設定を開き、以下を設定:

```json
{
  "dart.flutterSdkPath": "C:\\src\\flutter",
  "editor.formatOnSave": true,
  "editor.rulers": [80, 120],
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true
}
```

---

## ステップ5: Web開発環境のセットアップ

### 5-1. Google Chromeのインストール

1. [Chrome公式サイト](https://www.google.com/chrome/)からダウンロード
2. インストール実行

### 5-2. Web開発の有効化確認

```powershell
flutter config --enable-web
flutter doctor
```

---

## ステップ6: Android仮想デバイス(AVD)の作成

### 6-1. AVD Managerを開く

Android Studioで:
1. 「More Actions」→ 「Virtual Device Manager」
2. 「Create Device」をクリック

### 6-2. デバイスの設定

1. **デバイス選択**: Pixel 7 を選択 → Next
2. **システムイメージ**:
   - API Level 34 (Android 14.0)
   - Target: Android 14.0 (Google APIs)
   - 「Download」をクリックしてダウンロード
3. **AVD設定**:
   - AVD Name: `Pixel_7_API_34`
   - Graphics: Hardware - GLES 2.0
4. 「Finish」をクリック

### 6-3. エミュレーターの起動テスト

AVD Managerから「▶」をクリックしてエミュレーターを起動

---

## ステップ7: 環境確認

### 7-1. Flutter Doctor最終確認

```powershell
flutter doctor -v
```

**すべて✅になっていることを確認:**
```
[√] Flutter (Channel stable, 3.24.0)
[√] Windows Version (Windows 11)
[√] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[√] Chrome - develop for the web
[√] Android Studio (version 2023.3)
[√] VS Code (version 1.92.0)
[√] Connected device (3 available)
[√] HTTP Host Availability
```

---

## ステップ8: サンプルアプリで動作テスト

### 8-1. テストプロジェクトの作成

```powershell
cd C:\Users\<ユーザー名>\Documents
flutter create test_app
cd test_app
```

### 8-2. Android実行テスト

```powershell
# エミュレーターを起動してから
flutter run
```

### 8-3. Web実行テスト

```powershell
flutter run -d chrome
```

### 8-4. 実行デバイスの確認

```powershell
flutter devices
```

**出力例:**
```
3 connected devices:

Pixel 7 API 34 (mobile) • emulator-5554 • android-x64    • Android 14 (API 34) (emulator)
Chrome (web)            • chrome        • web-javascript • Google Chrome 120.0
Edge (web)              • edge          • web-javascript • Microsoft Edge 120.0
```

---

## 🎯 次のステップ

環境構築が完了したら、このリポジトリのFlutterプロジェクトで開発を始められます！

### プロジェクトの開始

```powershell
# このリポジトリをクローン済みの場合
cd <リポジトリパス>
flutter pub get
flutter run
```

---

## 🔧 トラブルシューティング

### よくある問題と解決方法

#### ❌ "cmdline-tools component is missing"

**解決方法:**
1. Android Studio → SDK Manager → SDK Tools
2. 「Android SDK Command-line Tools (latest)」にチェック
3. Apply → OK

#### ❌ "Unable to locate Android SDK"

**解決方法:**
```powershell
flutter config --android-sdk C:\Users\<ユーザー名>\AppData\Local\Android\Sdk
```

#### ❌ エミュレーターが起動しない

**解決方法:**
1. BIOSで「Intel VT-x」または「AMD-V」を有効化
2. Windowsの機能:
   - 「Hyper-V」を無効化
   - 「Windows ハイパーバイザー プラットフォーム」を有効化

#### ❌ `flutter doctor`でライセンスエラー

**解決方法:**
```powershell
flutter doctor --android-licenses
# すべて y で承諾
```

---

## 📚 参考リンク

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Flutter日本語ドキュメント](https://docs.flutter.dev/get-started/install)
- [Dart言語ツアー](https://dart.dev/guides/language/language-tour)
- [FlutterサンプルApp](https://flutter.github.io/samples/)

---

## iOS開発について（参考）

WindowsではiOSアプリのビルドはできませんが、以下の方法で対応可能:

### オプション1: Mac環境を用意
- Mac（またはHackintosh）でXcodeをインストール
- 同じFlutterコードでiOSビルド可能

### オプション2: CI/CDサービス利用
- **Codemagic**: Flutter専用CI/CD（無料プランあり）
- **GitHub Actions**: macOSランナーでビルド
- **Bitrise**: モバイルCI/CD

### オプション3: クラウド開発環境
- **FlutterFlow**: ノーコード/ローコードでFlutterアプリ開発
- **AWS Device Farm**: クラウドでテスト

---

**🚀 環境構築お疲れ様でした！開発を始めましょう！**
