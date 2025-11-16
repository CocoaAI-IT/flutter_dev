# プロジェクトセットアップガイド

このドキュメントでは、「頑張る人のための稼働時間タイマー」アプリのFlutterプロジェクトをセットアップする手順を説明します。

## プロジェクト情報

- **プロジェクト名**: work_time_tracker
- **アプリ名**: 頑張る人のための稼働時間タイマー
- **英語名**: Work Time Tracker
- **パッケージ名**: com.worktime.tracker

---

## ステップ1: Flutterプロジェクトの作成

### Windows環境での作成手順

```powershell
# プロジェクトディレクトリに移動（このリポジトリのクローン先）
cd C:\path\to\flutter_dev

# Flutterプロジェクトを作成
flutter create --org com.worktime --project-name work_time_tracker .
```

> **注意**: `.` を指定することで、現在のディレクトリにプロジェクトを作成します。

### すでに作成済みの場合

```powershell
# 依存関係を取得
flutter pub get

# プロジェクトが正しく動作するか確認
flutter doctor
flutter devices
```

---

## ステップ2: 依存パッケージの追加

### pubspec.yamlの編集

`pubspec.yaml` に以下の依存パッケージを追加します。

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 状態管理
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # ローカルデータベース
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # ルーティング
  go_router: ^14.0.0

  # UI関連
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10+1

  # 通知
  flutter_local_notifications: ^17.0.0

  # グラフ・チャート
  fl_chart: ^0.66.2

  # 日付・時間
  intl: ^0.19.0

  # ユーティリティ
  uuid: ^4.3.3
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linter
  flutter_lints: ^3.0.1

  # コード生成
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.11
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  hive_generator: ^2.0.1
```

### パッケージのインストール

```powershell
flutter pub get
```

---

## ステップ3: プロジェクト構造の作成

### ディレクトリ構成

```
lib/
├── main.dart                 # アプリのエントリーポイント
├── app.dart                  # アプリケーションルート
│
├── core/                     # コア機能
│   ├── constants/           # 定数定義
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   └── app_routes.dart
│   ├── theme/               # テーマ設定
│   │   ├── app_theme.dart
│   │   └── color_schemes.dart
│   ├── utils/               # ユーティリティ
│   │   ├── time_formatter.dart
│   │   └── date_utils.dart
│   └── extensions/          # 拡張メソッド
│       ├── datetime_extension.dart
│       └── duration_extension.dart
│
├── features/                # 機能モジュール
│   ├── timer/              # タイマー機能
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── timer_session.dart
│   │   │   ├── repositories/
│   │   │   │   └── timer_repository.dart
│   │   │   └── datasources/
│   │   │       └── local_timer_datasource.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── timer_state.dart
│   │   │   └── usecases/
│   │   │       ├── start_timer.dart
│   │   │       └── stop_timer.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── timer_provider.dart
│   │       ├── screens/
│   │       │   └── timer_screen.dart
│   │       └── widgets/
│   │           ├── timer_display.dart
│   │           └── timer_controls.dart
│   │
│   ├── kanban/             # カンバンボード機能
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── task.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── task_entity.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── kanban_provider.dart
│   │       ├── screens/
│   │       │   └── kanban_screen.dart
│   │       └── widgets/
│   │           ├── task_card.dart
│   │           ├── task_column.dart
│   │           └── drag_target_column.dart
│   │
│   ├── pomodoro/           # ポモドーロタイマー
│   │   ├── data/
│   │   │   └── models/
│   │   │       └── pomodoro_session.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── pomodoro_state.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── pomodoro_provider.dart
│   │       ├── screens/
│   │       │   └── pomodoro_screen.dart
│   │       └── widgets/
│   │           ├── pomodoro_timer.dart
│   │           └── pomodoro_settings.dart
│   │
│   ├── statistics/         # 統計・可視化
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── statistics_repository.dart
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── daily_stats.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── statistics_provider.dart
│   │       ├── screens/
│   │       │   └── statistics_screen.dart
│   │       └── widgets/
│   │           ├── heatmap_calendar.dart
│   │           ├── stats_card.dart
│   │           └── time_chart.dart
│   │
│   └── settings/           # 設定
│       ├── data/
│       │   └── models/
│       │       └── app_settings.dart
│       ├── domain/
│       │   └── entities/
│       │       └── settings_entity.dart
│       └── presentation/
│           ├── providers/
│           │   └── settings_provider.dart
│           ├── screens/
│           │   └── settings_screen.dart
│           └── widgets/
│               └── settings_tile.dart
│
└── shared/                 # 共通ウィジェット・ユーティリティ
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_card.dart
    │   └── loading_indicator.dart
    └── providers/
        └── theme_provider.dart
```

### ディレクトリの作成

Windows PowerShellで実行:

```powershell
# lib/core
New-Item -ItemType Directory -Force -Path lib/core/constants
New-Item -ItemType Directory -Force -Path lib/core/theme
New-Item -ItemType Directory -Force -Path lib/core/utils
New-Item -ItemType Directory -Force -Path lib/core/extensions

# lib/features/timer
New-Item -ItemType Directory -Force -Path lib/features/timer/data/models
New-Item -ItemType Directory -Force -Path lib/features/timer/data/repositories
New-Item -ItemType Directory -Force -Path lib/features/timer/data/datasources
New-Item -ItemType Directory -Force -Path lib/features/timer/domain/entities
New-Item -ItemType Directory -Force -Path lib/features/timer/domain/usecases
New-Item -ItemType Directory -Force -Path lib/features/timer/presentation/providers
New-Item -ItemType Directory -Force -Path lib/features/timer/presentation/screens
New-Item -ItemType Directory -Force -Path lib/features/timer/presentation/widgets

# lib/features/kanban
New-Item -ItemType Directory -Force -Path lib/features/kanban/data/models
New-Item -ItemType Directory -Force -Path lib/features/kanban/domain/entities
New-Item -ItemType Directory -Force -Path lib/features/kanban/presentation/providers
New-Item -ItemType Directory -Force -Path lib/features/kanban/presentation/screens
New-Item -ItemType Directory -Force -Path lib/features/kanban/presentation/widgets

# lib/features/pomodoro
New-Item -ItemType Directory -Force -Path lib/features/pomodoro/data/models
New-Item -ItemType Directory -Force -Path lib/features/pomodoro/domain/entities
New-Item -ItemType Directory -Force -Path lib/features/pomodoro/presentation/providers
New-Item -ItemType Directory -Force -Path lib/features/pomodoro/presentation/screens
New-Item -ItemType Directory -Force -Path lib/features/pomodoro/presentation/widgets

# lib/features/statistics
New-Item -ItemType Directory -Force -Path lib/features/statistics/data/repositories
New-Item -ItemType Directory -Force -Path lib/features/statistics/domain/entities
New-Item -ItemType Directory -Force -Path lib/features/statistics/presentation/providers
New-Item -ItemType Directory -Force -Path lib/features/statistics/presentation/screens
New-Item -ItemType Directory -Force -Path lib/features/statistics/presentation/widgets

# lib/features/settings
New-Item -ItemType Directory -Force -Path lib/features/settings/data/models
New-Item -ItemType Directory -Force -Path lib/features/settings/domain/entities
New-Item -ItemType Directory -Force -Path lib/features/settings/presentation/providers
New-Item -ItemType Directory -Force -Path lib/features/settings/presentation/screens
New-Item -ItemType Directory -Force -Path lib/features/settings/presentation/widgets

# lib/shared
New-Item -ItemType Directory -Force -Path lib/shared/widgets
New-Item -ItemType Directory -Force -Path lib/shared/providers
```

または、Linux/macOS/Git Bashの場合:

```bash
mkdir -p lib/core/{constants,theme,utils,extensions}
mkdir -p lib/features/timer/{data/{models,repositories,datasources},domain/{entities,usecases},presentation/{providers,screens,widgets}}
mkdir -p lib/features/kanban/{data/models,domain/entities,presentation/{providers,screens,widgets}}
mkdir -p lib/features/pomodoro/{data/models,domain/entities,presentation/{providers,screens,widgets}}
mkdir -p lib/features/statistics/{data/repositories,domain/entities,presentation/{providers,screens,widgets}}
mkdir -p lib/features/settings/{data/models,domain/entities,presentation/{providers,screens,widgets}}
mkdir -p lib/shared/{widgets,providers}
```

---

## ステップ4: 設定ファイルの作成

### analysis_options.yaml

プロジェクトルートに作成:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false

linter:
  rules:
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_empty_else
    - avoid_print
    - avoid_relative_lib_imports
    - avoid_types_as_parameter_names
    - camel_case_types
    - curly_braces_in_flow_control_structures
    - empty_catches
    - file_names
    - library_names
    - library_prefixes
    - no_duplicate_case_values
    - null_closures
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_if_null_operators
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_single_quotes
    - sort_child_properties_last
    - unnecessary_brace_in_string_interps
    - use_key_in_widget_constructors
```

---

## ステップ5: プロジェクトの実行確認

```powershell
# 依存関係の取得
flutter pub get

# デバイスの確認
flutter devices

# アプリの実行（Androidエミュレーター）
flutter run

# アプリの実行（Web）
flutter run -d chrome
```

---

## 次のステップ

1. 環境構築が完了したら、各機能の実装を開始します
2. Phase 1 (MVP) から順に実装していきます:
   - 基本タイマー機能
   - タスク管理
   - データ永続化
   - 基本的な統計表示

---

## トラブルシューティング

問題が発生した場合は、[SETUP_TROUBLESHOOTING.md](./SETUP_TROUBLESHOOTING.md)を参照してください。

---

**準備完了！開発を始めましょう！**
