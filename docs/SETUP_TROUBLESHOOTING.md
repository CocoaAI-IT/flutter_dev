# Flutter環境構築 トラブルシューティングガイド

Windows 11でのFlutter開発環境構築時によくある問題と解決方法をまとめています。

## 目次

1. [Flutter SDKの問題](#flutter-sdkの問題)
2. [Android開発環境の問題](#android開発環境の問題)
3. [エミュレーターの問題](#エミュレーターの問題)
4. [VSCodeの問題](#vscodeの問題)
5. [ビルド・実行の問題](#ビルド実行の問題)

---

## Flutter SDKの問題

### ❌ `flutter: command not found`

**原因:** 環境変数のPATHが正しく設定されていない

**解決方法:**

1. Flutter SDKのパスを確認
   ```powershell
   # Flutter SDKの場所を確認
   dir C:\src\flutter\bin
   ```

2. 環境変数を再設定
   - Windowsキー + R → `sysdm.cpl`
   - 詳細設定 → 環境変数
   - システム環境変数の「Path」に `C:\src\flutter\bin` を追加
   - **新しいPowerShellウィンドウ**を開いて確認

3. 確認
   ```powershell
   flutter --version
   ```

### ❌ Flutter doctorで「Flutter version unknown」

**原因:** Flutter SDKが破損しているか、不完全

**解決方法:**

```powershell
# Flutterのアップグレード
flutter upgrade

# Flutterのクリーンアップ
flutter doctor -v

# キャッシュをクリア
flutter clean
```

---

## Android開発環境の問題

### ❌ `Android sdkmanager not found`

**原因:** Android SDK Command-line Toolsがインストールされていない

**解決方法:**

1. Android Studioを起動
2. More Actions → SDK Manager
3. SDK Tools タブ
4. 「Android SDK Command-line Tools (latest)」にチェック
5. Apply → OK

再度確認:
```powershell
flutter doctor --android-licenses
```

### ❌ `Android license status unknown`

**原因:** Androidライセンスに同意していない

**解決方法:**

```powershell
flutter doctor --android-licenses
```

すべての質問に `y` で同意します。

**それでも解決しない場合:**

```powershell
# Android SDKのパスを明示的に設定
flutter config --android-sdk C:\Users\<ユーザー名>\AppData\Local\Android\Sdk

# 再度ライセンス同意
flutter doctor --android-licenses
```

### ❌ `Unable to locate Android SDK`

**原因:** Android SDKの場所が認識されていない

**解決方法:**

```powershell
# Android SDKの場所を確認
dir $env:LOCALAPPDATA\Android\Sdk

# Flutterに設定
flutter config --android-sdk $env:LOCALAPPDATA\Android\Sdk

# 確認
flutter doctor -v
```

---

## エミュレーターの問題

### ❌ エミュレーターが起動しない

**原因1:** 仮想化が有効になっていない

**解決方法:**

1. BIOSで仮想化を有効にする
   - 再起動 → BIOS/UEFI設定に入る
   - Intel: 「Intel VT-x」を有効化
   - AMD: 「AMD-V」を有効化

2. Windowsの機能を確認
   ```powershell
   # PowerShellを管理者として実行

   # Hyper-Vを無効化（Androidエミュレーターと競合する場合）
   Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

   # Windows ハイパーバイザー プラットフォームを有効化
   Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform
   Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
   ```

3. 再起動

**原因2:** グラフィックドライバーの問題

**解決方法:**

1. AVD Managerでエミュレーターを編集
2. Graphics: `Hardware - GLES 2.0` → `Software - GLES 2.0` に変更
3. 再度起動

### ❌ `HAXM installation failed`

**原因:** Intel HAXMがインストールできない（Intel CPUの場合）

**解決方法:**

Windows 11では**HAXMは不要**です。代わりに以下を使用:

```powershell
# Windows Hypervisor Platformを有効化（管理者権限のPowerShell）
Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform
```

再起動後、エミュレーターを起動してください。

### ❌ エミュレーターが極端に遅い

**解決方法:**

1. **AVDのRAMを増やす**
   - AVD Manager → 編集
   - RAM: 2048MB → 4096MB

2. **x86_64イメージを使用**
   - ARM系ではなく x86_64 のシステムイメージを選択

3. **グラフィック設定**
   - Graphics: Hardware - GLES 2.0

4. **コールドブート**
   - AVD Manager → コールドブート（電源ボタン長押し → Power off）

---

## VSCodeの問題

### ❌ VSCodeでFlutterが認識されない

**原因:** Flutter SDKのパスが設定されていない

**解決方法:**

1. VSCodeで `Ctrl + ,` → 設定を開く
2. 検索: `dart.flutterSdkPath`
3. 値を設定: `C:\src\flutter`
4. VSCodeを再起動

**または、settings.jsonで直接編集:**

```json
{
  "dart.flutterSdkPath": "C:\\src\\flutter"
}
```

### ❌ Dart Analysisが動作しない

**解決方法:**

```powershell
# Dart Analysisサーバーを再起動
# VSCodeのコマンドパレット (Ctrl + Shift + P)
# "Dart: Restart Analysis Server" を実行
```

または、

1. 依存関係を再取得
   ```powershell
   flutter pub get
   ```

2. VSCodeを再起動

### ❌ 拡張機能が読み込まれない

**解決方法:**

```powershell
# VSCode拡張機能キャッシュをクリア
# VSCodeを閉じてから実行
Remove-Item -Recurse -Force $env:USERPROFILE\.vscode\extensions
```

VSCodeを再起動して、拡張機能を再インストール

---

## ビルド・実行の問題

### ❌ `Gradle build failed`

**原因1:** Java JDKバージョンの問題

**解決方法:**

```powershell
# Android StudioのJDKを使用するよう設定
# android/gradle.properties に追加
org.gradle.java.home=C:\\Program Files\\Android\\Android Studio\\jbr
```

**原因2:** Gradleキャッシュの破損

**解決方法:**

```powershell
cd android
.\gradlew clean
cd ..
flutter clean
flutter pub get
```

### ❌ `Error: Unable to find git`

**原因:** Gitがインストールされていないか、PATHに無い

**解決方法:**

1. Gitをインストール: https://git-scm.com/
2. 環境変数のPATHに追加: `C:\Program Files\Git\cmd`
3. 新しいPowerShellで確認:
   ```powershell
   git --version
   ```

### ❌ `Pub get failed`

**原因:** ネットワーク問題またはキャッシュの破損

**解決方法:**

```powershell
# Pubキャッシュをクリア
flutter pub cache repair

# 依存関係を再取得
flutter clean
flutter pub get
```

**プロキシ環境の場合:**

```powershell
# プロキシ設定
set HTTP_PROXY=http://proxy.example.com:8080
set HTTPS_PROXY=http://proxy.example.com:8080

flutter pub get
```

### ❌ `Exception: Unable to open file`

**原因:** ファイルパスにスペースや日本語が含まれている

**解決方法:**

プロジェクトを英数字のみのパスに移動:

```powershell
# 悪い例
C:\Users\太郎\Documents\My Projects\app

# 良い例
C:\dev\flutter_app
```

---

## Web開発の問題

### ❌ Web開発が有効になっていない

**解決方法:**

```powershell
flutter config --enable-web
flutter devices
```

「Chrome (web)」が表示されることを確認

### ❌ Chromeで実行できない

**解決方法:**

```powershell
# Chromeのパスを確認
flutter config --list

# 明示的に指定
flutter run -d chrome
```

---

## パフォーマンス最適化

### Flutter開発を高速化する設定

```powershell
# ホットリロードを有効化（デフォルトで有効）
flutter run --hot

# Web開発を高速化（HTML rendererを使用）
flutter run -d chrome --web-renderer html

# ビルドキャッシュを有効化
flutter config --build-dir=build
```

---

## 完全リセット手順

すべてがうまくいかない場合の最終手段:

```powershell
# 1. Flutterキャッシュをクリア
flutter clean
flutter pub cache repair

# 2. Flutter SDKを再インストール
Remove-Item -Recurse -Force C:\src\flutter
# 再度ダウンロード・展開

# 3. Android SDKをクリーンアップ
# Android Studio → SDK Manager → すべてアンインストール
# 必要なものだけ再インストール

# 4. VSCode設定をリセット
Remove-Item -Recurse -Force $env:APPDATA\Code

# 5. 環境変数を再設定
```

---

## サポート・コミュニティ

問題が解決しない場合:

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Flutter GitHub Issues](https://github.com/flutter/flutter/issues)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter日本Discordコミュニティ](https://discord.gg/flutter-jp)

---

**問題解決できましたか？次は開発を始めましょう！**
