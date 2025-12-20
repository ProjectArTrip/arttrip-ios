import 'package:arttrip/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// SnackBar 타입
enum SnackBarType { success, error, warning, info }

/// 공용 SnackBar 유틸리티
class SnackBarUtils {
  SnackBarUtils._();

  /// 성공 SnackBar 표시
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      action: action,
    );
  }

  /// 에러 SnackBar 표시
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      action: action,
    );
  }

  /// 경고 SnackBar 표시
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      action: action,
    );
  }

  /// 정보 SnackBar 표시
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      action: action,
    );
  }

  /// 커스텀 SnackBar 표시
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
    ShapeBorder? shape,
  }) {
    _showCustom(
      context,
      message: message,
      backgroundColor: backgroundColor ?? AppColors.gray900,
      textColor: textColor ?? AppColors.textWhite,
      icon: icon,
      duration: duration,
      action: action,
      behavior: behavior,
      margin: margin,
      padding: padding,
      elevation: elevation,
      shape: shape,
    );
  }

  /// 현재 SnackBar 숨기기
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// 모든 SnackBar 제거
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  static void _show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    required Duration duration,
    SnackBarAction? action,
  }) {
    var config = _getConfig(type);

    _showCustom(
      context,
      message: message,
      backgroundColor: config.backgroundColor,
      textColor: config.textColor,
      icon: config.icon,
      duration: duration,
      action: action,
    );
  }

  static void _showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    required Duration duration,
    SnackBarAction? action,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
    ShapeBorder? shape,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    var snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: behavior,
      margin: margin ?? EdgeInsets.all(16.w),
      padding:
          padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      elevation: elevation ?? 4,
      shape:
          shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      action: action,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFF4CAF50),
          textColor: AppColors.textWhite,
          icon: Icons.check_circle_outline,
        );
      case SnackBarType.error:
        return const _SnackBarConfig(
          backgroundColor: AppColors.subRed,
          textColor: AppColors.textWhite,
          icon: Icons.error_outline,
        );
      case SnackBarType.warning:
        return const _SnackBarConfig(
          backgroundColor: Color(0xFFFFA726),
          textColor: AppColors.textWhite,
          icon: Icons.warning_amber_outlined,
        );
      case SnackBarType.info:
        return const _SnackBarConfig(
          backgroundColor: AppColors.primary300,
          textColor: AppColors.textWhite,
          icon: Icons.info_outline,
        );
    }
  }
}

class _SnackBarConfig {
  const _SnackBarConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
}
