import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 키워드 선택 칩 위젯
class KeywordModelChip extends StatelessWidget {
  const KeywordModelChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  // 색상 상수
  static const _selectedBgColor = Color(0xFF7859FF);
  static const _unselectedBorderColor = Color(0xFFDBDBDB);
  static const _textColor = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(40.r),
          border: isSelected
              ? null
              : Border.all(color: _unselectedBorderColor, width: 1),
        ),
        child: isSelected
            ? ArtTripText.pretendard()
                  .body01Bold()
                  .textAlign(TextAlign.center)
                  .color(Colors.white)
                  .build()
                  .text(label)
            : ArtTripText.pretendard()
                  .body01Light()
                  .textAlign(TextAlign.center)
                  .color(_textColor)
                  .build()
                  .text(label),
      ),
    );
  }
}
