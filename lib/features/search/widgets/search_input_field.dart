import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 검색 입력 필드
class SearchInputField extends StatelessWidget {
  const SearchInputField({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  final TextEditingController controller;
  final Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray100),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: controller,
        style:
            ArtTripText.pretendard()
                .body01Regular()
                .color(AppColors.textPrimary)
                .build()
                .style(),
        decoration: InputDecoration(
          hintText: context.l10n.searchPlaceholder,
          hintStyle:
              ArtTripText.pretendard()
                  .body01Regular()
                  .color(AppColors.textTertiary)
                  .build()
                  .style(),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
          suffixIcon: GestureDetector(
            onTap: () => onSearch(controller.text),
            child: Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: SvgPicture.asset(
                AppAssets.icSearch,
                width: 24.w,
                height: 24.w,
              ),
            ),
          ),
          suffixIconConstraints: BoxConstraints(
            maxHeight: 24.w,
            maxWidth: 40.w,
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: onSearch,
      ),
    );
  }
}
