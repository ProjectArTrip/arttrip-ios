import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 키워드 선택 칩 위젯
class KeywordChip extends StatelessWidget {
  const KeywordChip({
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
        width: 100.w,
        height: 40.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(40.r),
          border: isSelected
              ? null
              : Border.all(color: _unselectedBorderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w300,
              color: isSelected ? Colors.white : _textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
