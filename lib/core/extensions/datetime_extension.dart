import 'package:intl/intl.dart';

/// DateTimeの拡張メソッド
extension DateTimeExtension on DateTime {
  /// 日付を"yyyy/MM/dd"形式でフォーマット
  String toFormattedDate() {
    return DateFormat('yyyy/MM/dd').format(this);
  }

  /// 日付を"MM/dd"形式でフォーマット
  String toShortDate() {
    return DateFormat('MM/dd').format(this);
  }

  /// 日付時刻を"yyyy/MM/dd HH:mm"形式でフォーマット
  String toFormattedDateTime() {
    return DateFormat('yyyy/MM/dd HH:mm').format(this);
  }

  /// 時刻を"HH:mm"形式でフォーマット
  String toFormattedTime() {
    return DateFormat('HH:mm').format(this);
  }

  /// 今日かどうかを判定
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 昨日かどうかを判定
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// 今週かどうかを判定
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// 今月かどうかを判定
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// その日の開始時刻（0時0分0秒）を取得
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// その日の終了時刻（23時59分59秒）を取得
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59);
  }

  /// 週の開始日（月曜日）を取得
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  /// 週の終了日（日曜日）を取得
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).endOfDay;
  }

  /// 月の開始日を取得
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// 月の終了日を取得
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59);
  }

  /// 相対的な日付表現を取得（今日、昨日、○日前など）
  String toRelativeString() {
    if (isToday) {
      return '今日';
    } else if (isYesterday) {
      return '昨日';
    }

    final difference = DateTime.now().difference(this).inDays;

    if (difference < 7) {
      return '$difference日前';
    } else if (difference < 30) {
      return '${(difference / 7).floor()}週間前';
    } else if (difference < 365) {
      return '${(difference / 30).floor()}ヶ月前';
    } else {
      return '${(difference / 365).floor()}年前';
    }
  }
}
