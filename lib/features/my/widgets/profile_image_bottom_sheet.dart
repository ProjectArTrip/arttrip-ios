import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ProfileImageAction { gallery, camera, delete }

class ProfileImageBottomSheet extends StatelessWidget {
  const ProfileImageBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildOption(
              context,
              title: context.l10n.pickFromGallery,
              onTap: () => Navigator.pop(context, ProfileImageAction.gallery),
            ),
            const AppDivider(),
            _buildOption(
              context,
              title: context.l10n.takePhoto,
              onTap: () => Navigator.pop(context, ProfileImageAction.camera),
            ),
            const AppDivider(),
            _buildOption(
              context,
              title: context.l10n.deleteImage,
              textColor: AppColors.subRed,
              onTap: () => Navigator.pop(context, ProfileImageAction.delete),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 19.h,
        bottom: 12.h,
        left: 24.w,
        right: 24.w,
      ),
      child: Row(
        children: [
          Expanded(
            child: ArtTripText.pretendard()
                .title02Bold()
                .color(AppColors.textPrimary)
                .build()
                .text(context.l10n.changeProfileImage),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              AppAssets.icClose,
              width: 24.w,
              height: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: ArtTripText.pretendard()
            .body01Regular()
            .color(textColor ?? AppColors.textPrimary)
            .build()
            .text(title),
      ),
    );
  }
}

Future<ProfileImageAction?> showProfileImageBottomSheet(BuildContext context) {
  return showModalBottomSheet<ProfileImageAction>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const ProfileImageBottomSheet(),
  );
}
