import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 공용 확인 다이얼로그
///
/// 타이틀, 내용, 버튼 텍스트를 커스터마이즈할 수 있는 다이얼로그
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
  });

  final String title;
  final Widget content;
  final String cancelText;
  final String confirmText;

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required Widget content,
    required String cancelText,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AppConfirmDialog(
            title: title,
            content: content,
            cancelText: cancelText,
            confirmText: confirmText,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.gray0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ArtTripText.pretendard()
                .title01Bold()
                .color(AppColors.textPrimary)
                .build()
                .text(title),
            SizedBox(height: 12.h),
            const Divider(height: 1, color: AppColors.gray100),
            SizedBox(height: 24.h),
            content,
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.gray0,
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: Color(0xFFDBDBDB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: ArtTripText.pretendard()
                          .body01Bold()
                          .color(AppColors.textPrimary)
                          .build()
                          .text(cancelText),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary300,
                        foregroundColor: AppColors.gray0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: ArtTripText.pretendard()
                          .body01Bold()
                          .color(AppColors.gray0)
                          .build()
                          .text(confirmText),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
