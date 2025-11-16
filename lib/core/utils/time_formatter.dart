/// 時間をフォーマットするユーティリティクラス
class TimeFormatter {
  TimeFormatter._();

  /// DurationをHH:MM:SS形式にフォーマット
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// DurationをMM:SS形式にフォーマット（短縮版）
  static String formatDurationShort(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Durationを人間が読みやすい形式にフォーマット（例: 2時間30分）
  static String formatDurationHuman(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      if (minutes > 0) {
        return '$hours時間$minutes分';
      }
      return '$hours時間';
    }

    if (minutes > 0) {
      return '$minutes分';
    }

    return '0分';
  }

  /// Durationを小数点時間に変換（例: 1.5時間）
  static double durationToHours(Duration duration) {
    return duration.inMinutes / 60.0;
  }

  /// 小数点時間をDurationに変換
  static Duration hoursToDuration(double hours) {
    return Duration(minutes: (hours * 60).round());
  }

  /// 秒数からDurationを作成
  static Duration fromSeconds(int seconds) {
    return Duration(seconds: seconds);
  }

  /// 分数からDurationを作成
  static Duration fromMinutes(int minutes) {
    return Duration(minutes: minutes);
  }

  /// 時間数からDurationを作成
  static Duration fromHours(int hours) {
    return Duration(hours: hours);
  }
}
