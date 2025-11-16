# Phase 1 MVP 実装ガイド

Phase 1（MVP: Minimum Viable Product）の実装が完了しました。このドキュメントでは実装内容と、Windows環境でのセットアップ・実行方法を説明します。

---

## 実装完了機能

### ✅ 基本タイマー機能（ストップウォッチ）
- タイマーの開始/停止/一時停止/再開
- 経過時間の表示（HH:MM:SS形式）
- タスク選択機能
- タイマーセッションの記録
- 今日の作業履歴表示

### ✅ タスク管理
- タスクの作成・編集・削除
- タスクステータス管理（ToDo/進行中/完了）
- タスク優先度設定（低/中/高）
- タスク説明・タグ機能
- タスク別の総作業時間記録

### ✅ データ永続化
- Hiveによるローカルデータベース
- タスクデータの保存
- タイマーセッションの保存
- アプリ再起動後もデータ保持

### ✅ シンプルなダッシュボード
- 今日/今週の総作業時間表示
- タスク統計（ToDo/進行中/完了の件数）
- 完了率の視覚化
- 稼働中タイマーの表示

---

## プロジェクト構造

```
lib/
├── main.dart                          # アプリエントリーポイント
├── app.dart                           # アプリケーションルート
│
├── core/                              # コア機能
│   ├── constants/
│   │   ├── app_colors.dart           # カラーパレット
│   │   ├── app_sizes.dart            # サイズ定数
│   │   └── app_routes.dart           # ルート定数
│   ├── theme/
│   │   └── app_theme.dart            # アプリテーマ
│   ├── utils/
│   │   └── time_formatter.dart       # 時間フォーマッター
│   └── extensions/
│       └── datetime_extension.dart   # DateTime拡張
│
├── features/                          # 機能モジュール
│   ├── dashboard/                     # ダッシュボード
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── daily_stats.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── dashboard_screen.dart
│   │
│   ├── timer/                         # タイマー
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── timer_session.dart
│   │   │   └── repositories/
│   │   │       └── timer_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── timer_provider.dart
│   │       └── screens/
│   │           └── timer_screen.dart
│   │
│   └── task/                          # タスク管理
│       ├── data/
│       │   ├── models/
│       │   │   └── task.dart
│       │   └── repositories/
│       │       └── task_repository.dart
│       └── presentation/
│           ├── providers/
│           │   └── task_provider.dart
│           └── screens/
│               └── task_list_screen.dart
│
└── shared/                            # 共通コンポーネント
    ├── widgets/
    └── providers/
```

---

## Windows環境でのセットアップ

### 前提条件

✅ Flutter SDK 3.2.0以降
✅ Android Studio（Androidエミュレーター用）
✅ Google Chrome（Web実行用）

詳細な環境構築手順は [README.md](../README.md) を参照してください。

### 1. プロジェクトのクローン

```powershell
git clone https://github.com/CocoaAI-IT/flutter_dev.git
cd flutter_dev
```

### 2. 依存パッケージの取得

```powershell
flutter pub get
```

### 3. Hiveアダプターの生成

Hiveのモデルクラスには`@HiveType`アノテーションが付いているため、コード生成が必要です。

```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

これにより、以下のファイルが自動生成されます：
- `task.g.dart`
- `timer_session.g.dart`
- `daily_stats.g.dart`

### 4. アプリの実行

#### Webで実行（推奨：最速）

```powershell
flutter run -d chrome
```

#### Androidエミュレーターで実行

```powershell
# エミュレーターを起動（Android Studio > AVD Manager）
# その後：
flutter run
```

#### 利用可能なデバイスを確認

```powershell
flutter devices
```

---

## 使い方

### 1. タスクを作成する

1. 画面下部の「タスク」タブをタップ
2. 右下の「タスク追加」ボタンをタップ
3. タスク名、説明（任意）、優先度を入力
4. 「作成」をタップ

### 2. タイマーを開始する

1. 画面下部の「タイマー」タブをタップ
2. ドロップダウンからタスクを選択
3. 「開始」ボタンをタップ
4. タイマーが開始され、経過時間が表示されます

### 3. タイマーを停止する

1. 「停止」ボタンをタップ
2. 作業時間がタスクに記録されます
3. 今日の記録セクションに履歴が表示されます

### 4. ダッシュボードで確認

1. 画面下部の「ダッシュボード」タブをタップ
2. 今日/今週の総作業時間を確認
3. タスクの進捗状況を確認

---

## 実装の詳細

### 状態管理: Riverpod

- `timerProvider`: タイマーの状態管理
- `taskNotifierProvider`: タスクの作成・更新・削除
- `allTasksProvider`: すべてのタスク一覧
- `todoTasksProvider`: Todoタスク一覧
- `inProgressTasksProvider`: 進行中タスク一覧
- `doneTasksProvider`: 完了タスク一覧
- `taskStatsProvider`: タスク統計情報

### データモデル

#### Task（タスク）
```dart
- id: String                    // ユニークID
- title: String                 // タスク名
- description: String?          // 説明
- status: TaskStatus            // ステータス（todo/inProgress/done）
- totalTimeInSeconds: int       // 総作業時間（秒）
- createdAt: DateTime           // 作成日時
- completedAt: DateTime?        // 完了日時
- tags: List<String>            // タグ
- priority: int                 // 優先度（1-3）
```

#### TimerSession（タイマーセッション）
```dart
- id: String                    // ユニークID
- taskId: String                // 関連タスクID
- startTime: DateTime           // 開始時刻
- endTime: DateTime?            // 終了時刻
- durationInSeconds: int        // 継続時間（秒）
- note: String?                 // メモ
```

### ローカルデータベース: Hive

- **Box名**:
  - `tasks`: タスクデータ
  - `timer_sessions`: タイマーセッションデータ
  - `daily_stats`: 日次統計データ（Phase 2で使用予定）

- **データ保存場所**:
  - Windows: `C:\Users\<ユーザー名>\AppData\Roaming\work_time_tracker`
  - Android: アプリのプライベートストレージ
  - Web: IndexedDB

---

## トラブルシューティング

### ❌ `*.g.dart` ファイルが見つからない

**解決方法:**
```powershell
flutter pub run build_runner build --delete-conflicting-outputs
```

### ❌ `Bad state: No element` エラー

タスクが存在しない場合に発生します。タスクを作成してから再試行してください。

### ❌ アプリが起動しない

1. 依存関係を再取得:
   ```powershell
   flutter clean
   flutter pub get
   ```

2. コード生成を再実行:
   ```powershell
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. アプリを再実行:
   ```powershell
   flutter run
   ```

---

## 既知の制限事項

### MVP（Phase 1）では未実装の機能

- ❌ カンバンボード（ドラッグ&ドロップ）
- ❌ ポモドーロタイマー
- ❌ GitHub風ヒートマップ
- ❌ 通知機能
- ❌ データエクスポート
- ❌ ダークモードの切り替えUI
- ❌ タスクの検索・フィルター
- ❌ タスクの編集機能

これらの機能は **Phase 2** および **Phase 3** で実装予定です。

---

## 次のステップ: Phase 2

Phase 2では以下の機能を実装予定：

1. **カンバンボード**: タスクをドラッグ&ドロップで移動
2. **ポモドーロタイマー**: 25分作業 + 5分休憩サイクル
3. **GitHub風ヒートマップ**: 過去の活動を可視化
4. **通知機能**: タイマー完了時の通知
5. **グラフ・チャート**: 作業時間の推移をグラフ表示

---

## 開発者向け情報

### コード生成

新しいHiveモデルを追加した場合：

```powershell
# 開発中は watch モードが便利
flutter pub run build_runner watch
```

### Linter実行

```powershell
flutter analyze
```

### フォーマット

```powershell
flutter format lib/
```

---

## フィードバック・バグ報告

問題が発生した場合やフィードバックがある場合は、GitHubのIssueを作成してください。

---

**🎉 Phase 1 MVP実装完了！次はPhase 2の開発に進みましょう！**
