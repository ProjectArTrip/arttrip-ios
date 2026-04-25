import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/my/data/models/user_profile_model.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyProfileSection extends StatelessWidget {
  const MyProfileSection({
    super.key,
    required this.profile,
    required this.onTap,
  });

  final UserProfileModel profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        children: [
          _buildProfileImage(),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Flexible(
                    child: ArtTripText.pretendard()
                        .headline()
                        .color(AppColors.textPrimary)
                        .build()
                        .text(profile.nickName ?? context.l10n.tempNickname),
                  ),
                  SizedBox(width: 4.w),
                  SvgPicture.asset(
                    AppAssets.icNoArrowRight,
                    width: 24.w,
                    height: 24.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    const double size = 80;

    if (profile.profileImage != null && profile.profileImage!.isNotEmpty) {
      return ClipOval(
        child: AppCachedImage(
          imageUrl: profile.profileImage!,
          width: size.w,
          height: size.w,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipOval(
      child: SvgPicture.asset(
        AppAssets.icEmptyProfile,
        width: size.w,
        height: size.w,
      ),
    );
  }
}
