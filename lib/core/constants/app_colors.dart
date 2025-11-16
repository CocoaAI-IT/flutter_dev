import 'package:flutter/material.dart';

/// アプリケーション全体で使用するカラーパレット
class AppColors {
  AppColors._();

  // Primary Colors
  static const primary = Color(0xFF5B8DEF);
  static const primaryLight = Color(0xFF8AB4F8);
  static const primaryDark = Color(0xFF3B6FD4);

  // Secondary Colors (GitHub Green)
  static const secondary = Color(0xFF4CAF50);
  static const secondaryLight = Color(0xFF80E27E);
  static const secondaryDark = Color(0xFF087F23);

  // Accent Colors
  static const accent = Color(0xFFFF6B6B);
  static const accentLight = Color(0xFFFF9999);
  static const accentDark = Color(0xFFCC5555);

  // Background Colors
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const textPrimary = Color(0xFF212529);
  static const textSecondary = Color(0xFF6C757D);
  static const textTertiary = Color(0xFF9CA3AF);

  // Status Colors
  static const success = Color(0xFF28A745);
  static const warning = Color(0xFFFFC107);
  static const error = Color(0xFFDC3545);
  static const info = Color(0xFF17A2B8);

  // Task Status Colors
  static const taskTodo = Color(0xFF9CA3AF);
  static const taskInProgress = Color(0xFF3B82F6);
  static const taskDone = Color(0xFF10B981);

  // Heatmap Colors (GitHub風)
  static const heatmapLevel0 = Color(0xFFEBEDF0); // グレー (0時間)
  static const heatmapLevel1 = Color(0xFFC6E48B); // 薄緑 (0-1時間)
  static const heatmapLevel2 = Color(0xFF7BC96F); // 緑 (1-2時間)
  static const heatmapLevel3 = Color(0xFF239A3B); // 濃緑 (2-4時間)
  static const heatmapLevel4 = Color(0xFF196127); // 最濃緑 (4時間以上)

  // Dark Mode Colors
  static const darkBackground = Color(0xFF1E1E1E);
  static const darkSurface = Color(0xFF2D2D2D);
  static const darkTextPrimary = Color(0xFFE0E0E0);
  static const darkTextSecondary = Color(0xFFB0B0B0);

  /// ヒートマップの色を強度レベルから取得
  static Color getHeatmapColor(int level) {
    switch (level) {
      case 0:
        return heatmapLevel0;
      case 1:
        return heatmapLevel1;
      case 2:
        return heatmapLevel2;
      case 3:
        return heatmapLevel3;
      case 4:
        return heatmapLevel4;
      default:
        return heatmapLevel0;
    }
  }
}
