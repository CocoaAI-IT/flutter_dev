# アーキテクチャ設計書

## 概要

「頑張る人のための稼働時間タイマー」アプリは、**Clean Architecture** + **Feature-First** アプローチで設計されています。

---

## アーキテクチャパターン

### Clean Architecture (レイヤー構造)

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│   (Screens, Widgets, Providers)         │
│   - UI表示                               │
│   - ユーザー入力処理                      │
│   - 状態管理 (Riverpod)                  │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│   (Entities, Use Cases)                 │
│   - ビジネスロジック                      │
│   - アプリのコアルール                    │
│   - フレームワーク非依存                  │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│   (Models, Repositories, DataSources)   │
│   - データの永続化                        │
│   - 外部APIとの通信                       │
│   - データ変換                            │
└─────────────────────────────────────────┘
```

### 依存関係のルール

- **Presentation** → Domain → Data
- 内側のレイヤーは外側のレイヤーを知らない
- 各レイヤーは独立してテスト可能

---

## 状態管理: Riverpod

### 選定理由

1. **型安全**: コンパイル時にエラーを検出
2. **パフォーマンス**: 必要な部分のみ再ビルド
3. **テスタビリティ**: Provider単位でテスト可能
4. **スコープ管理**: グローバル状態とローカル状態の明確な分離

### Provider構成

```dart
// 例: タイマーの状態管理

// StateNotifierProvider: 状態を持ち、変更を通知
@riverpod
class TimerNotifier extends _$TimerNotifier {
  @override
  TimerState build() {
    return const TimerState.idle();
  }

  Future<void> start(String taskId) async {
    // タイマー開始ロジック
  }

  Future<void> stop() async {
    // タイマー停止ロジック
  }
}

// 他のウィジェットから使用
final timerState = ref.watch(timerNotifierProvider);
```

---

## データ永続化: Hive

### 選定理由

1. **高速**: NoSQL、キーバリュー型データベース
2. **軽量**: SQLiteより小さいフットプリント
3. **型安全**: Dart objectをそのまま保存
4. **クロスプラットフォーム**: すべてのプラットフォームで動作

### データモデル例

```dart
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final TaskStatus status;

  @HiveField(3)
  final Duration totalTime;

  @HiveField(4)
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.totalTime,
    required this.createdAt,
  });
}

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  done,
}
```

---

## ルーティング: GoRouter

### ルート定義

```dart
final goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/timer',
      builder: (context, state) => const TimerScreen(),
    ),
    GoRoute(
      path: '/kanban',
      builder: (context, state) => const KanbanScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
```

---

## 機能別設計

### 1. タイマー機能

#### 状態遷移図

```
    [Idle]
      ↓ start()
   [Running]
      ↓ pause()
   [Paused]
      ↓ resume()
   [Running]
      ↓ stop()
    [Idle]
```

#### データフロー

```
User Action (UI)
  ↓
TimerProvider (State Management)
  ↓
TimerUseCase (Business Logic)
  ↓
TimerRepository (Data Access)
  ↓
Hive (Local Database)
```

#### 主要クラス

```dart
// Domain Entity
class TimerState {
  final TimerStatus status;
  final Duration elapsed;
  final String? taskId;
  final DateTime? startedAt;

  const TimerState({
    required this.status,
    required this.elapsed,
    this.taskId,
    this.startedAt,
  });
}

enum TimerStatus {
  idle,
  running,
  paused,
}
```

---

### 2. カンバンボード機能

#### カラム構成

- **ToDo**: 未着手タスク
- **In Progress**: 進行中タスク
- **Done**: 完了タスク

#### ドラッグ&ドロップ実装

```dart
// DragTarget と Draggable を使用
Draggable<Task>(
  data: task,
  feedback: TaskCard(task: task, isDragging: true),
  child: TaskCard(task: task),
)

DragTarget<Task>(
  onAccept: (task) {
    // タスクのステータスを更新
    ref.read(kanbanProvider.notifier).moveTask(task, newStatus);
  },
  builder: (context, candidateData, rejectedData) {
    return TaskColumn(status: status);
  },
)
```

---

### 3. ポモドーロタイマー

#### 設定値

```dart
class PomodoroSettings {
  final Duration workDuration;      // 作業時間 (デフォルト: 25分)
  final Duration shortBreak;        // 短い休憩 (デフォルト: 5分)
  final Duration longBreak;         // 長い休憩 (デフォルト: 15分)
  final int sessionsUntilLongBreak; // 長い休憩までのセッション数 (デフォルト: 4)

  const PomodoroSettings({
    this.workDuration = const Duration(minutes: 25),
    this.shortBreak = const Duration(minutes: 5),
    this.longBreak = const Duration(minutes: 15),
    this.sessionsUntilLongBreak = 4,
  });
}
```

#### フロー

```
[Work 25min]
     ↓ 完了
[Short Break 5min]
     ↓ 完了
[Work 25min]
     ↓ ... (4セット繰り返し)
[Long Break 15min]
```

---

### 4. 統計・可視化機能

#### GitHub風ヒートマップ

```dart
class HeatmapData {
  final DateTime date;
  final Duration totalTime;
  final int intensity; // 0-4 (色の濃さ)

  HeatmapData({
    required this.date,
    required this.totalTime,
  }) : intensity = _calculateIntensity(totalTime);

  static int _calculateIntensity(Duration duration) {
    final hours = duration.inHours;
    if (hours == 0) return 0;
    if (hours < 1) return 1;
    if (hours < 2) return 2;
    if (hours < 4) return 3;
    return 4;
  }
}
```

#### 色スケール

```dart
const heatmapColors = {
  0: Color(0xFFEBEDF0), // グレー (0時間)
  1: Color(0xFFC6E48B), // 薄緑 (0-1時間)
  2: Color(0xFF7BC96F), // 緑 (1-2時間)
  3: Color(0xFF239A3B), // 濃緑 (2-4時間)
  4: Color(0xFF196127), // 最濃緑 (4時間以上)
};
```

---

## UIテーマ設計

### カラーパレット

```dart
class AppColors {
  // Primary
  static const primary = Color(0xFF5B8DEF);
  static const primaryLight = Color(0xFF8AB4F8);
  static const primaryDark = Color(0xFF3B6FD4);

  // Secondary (GitHub Green)
  static const secondary = Color(0xFF4CAF50);
  static const secondaryLight = Color(0xFF80E27E);
  static const secondaryDark = Color(0xFF087F23);

  // Accent
  static const accent = Color(0xFFFF6B6B);

  // Background
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);

  // Text
  static const textPrimary = Color(0xFF212529);
  static const textSecondary = Color(0xFF6C757D);

  // Status
  static const success = Color(0xFF28A745);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFDC3545);
  static const info = Color(0xFF17A2B8);
}
```

### タイポグラフィ

```dart
final textTheme = TextTheme(
  displayLarge: GoogleFonts.notoSansJp(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  ),
  headlineMedium: GoogleFonts.notoSansJp(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  ),
  bodyLarge: GoogleFonts.notoSansJp(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  ),
  bodyMedium: GoogleFonts.notoSansJp(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  ),
  labelLarge: GoogleFonts.notoSansJp(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ),
);
```

---

## パフォーマンス最適化

### 1. ウィジェット最適化

```dart
// const constructorを使用
const CustomButton(text: 'Start');

// Keyを使用してウィジェット再利用
ListView.builder(
  itemBuilder: (context, index) {
    return TaskCard(
      key: ValueKey(tasks[index].id),
      task: tasks[index],
    );
  },
)
```

### 2. 状態管理の最適化

```dart
// 必要な部分のみwatch
final taskCount = ref.watch(
  kanbanProvider.select((state) => state.tasks.length)
);
```

### 3. 画像・アセット最適化

- SVGアイコンを使用（ベクター形式）
- 画像は適切なサイズにリサイズ
- 必要に応じてキャッシュを活用

---

## セキュリティ考慮事項

### データ保護

1. **ローカルストレージ**: Hiveは暗号化をサポート（必要に応じて）
2. **個人情報**: 最小限のデータのみ保存
3. **バックアップ**: ユーザーがデータをエクスポート可能に

### 権限管理

- **通知権限**: ポモドーロタイマーの完了通知に必要
- **ストレージ権限**: データエクスポート時に必要（Androidのみ）

---

## テスト戦略

### 1. ユニットテスト

```dart
// Domain層のビジネスロジックをテスト
test('タイマーが正しく開始される', () {
  final timer = TimerState.idle();
  final running = timer.start('task-1');

  expect(running.status, TimerStatus.running);
  expect(running.taskId, 'task-1');
});
```

### 2. ウィジェットテスト

```dart
testWidgets('タイマー画面が正しく表示される', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: TimerScreen()),
    ),
  );

  expect(find.text('00:00:00'), findsOneWidget);
  expect(find.byIcon(Icons.play_arrow), findsOneWidget);
});
```

### 3. 統合テスト

```dart
// アプリ全体のフローをテスト
testWidgets('タスク作成からタイマー開始までの流れ', (tester) async {
  // 1. タスクを作成
  // 2. タイマー画面に移動
  // 3. タスクを選択
  // 4. タイマーを開始
  // 5. 時間が進むことを確認
});
```

---

## デプロイ戦略

### Android

```bash
# リリースビルド
flutter build apk --release

# App Bundle (Google Play推奨)
flutter build appbundle --release
```

### iOS

```bash
# リリースビルド (Mac環境で)
flutter build ios --release
```

### Web

```bash
# Webビルド
flutter build web --release

# デプロイ先候補
# - Firebase Hosting
# - Vercel
# - Netlify
# - GitHub Pages
```

---

## 今後の拡張性

### 将来的な機能追加

1. **クラウド同期**: FirebaseやSupabaseでデータ同期
2. **チーム機能**: 複数ユーザーでタスク共有
3. **レポート機能**: PDF/CSVエクスポート
4. **カスタマイズ**: テーマカラー、タイマー音の変更
5. **ウィジェット**: ホーム画面にタイマーウィジェット配置

### スケーラビリティ

- **マイクロフロントエンド**: 機能ごとにパッケージ分割可能
- **プラグインアーキテクチャ**: 新機能を独立したモジュールとして追加
- **API対応**: RESTful APIを介してバックエンドと通信

---

**このアーキテクチャで、保守性・拡張性・テスタビリティの高いアプリを実現します！**
