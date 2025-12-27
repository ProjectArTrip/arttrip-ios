import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/my/data/models/user_profile_model.dart';
import 'package:arttrip/features/my/viewmodels/my_viewmodel.dart';
import 'package:arttrip/features/my/widgets/edit_profile_field.dart';
import 'package:arttrip/features/my/widgets/profile_image_bottom_sheet.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:arttrip/shared/widgets/app_input_dialog.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/shimmer_skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.profile});
  final UserProfileModel profile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: CommonAppBar(
        title: context.l10n.editProfileTitle,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              _buildProfileImage(),
              SizedBox(height: 24.h),
              Selector<MyViewModel, AsyncState<UserProfileModel>>(
                selector: (_, vm) => vm.profileState,
                builder: (context, state, _) {
                  var nickname =
                      state.data?.nickName ?? widget.profile.nickName ?? '';
                  return EditProfileField(
                    onTap: () => _onNicknameTap(nickname),
                    label: context.l10n.nicknameLabel,
                    value: nickname,
                    showArrow: true,
                  );
                },
              ),
              SizedBox(height: 24.h),
              EditProfileField(
                label: context.l10n.emailLabel,
                valueColor: AppColors.textTertiary,
                value: 'abcd1234@naver.com',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    const double size = 96;

    return Selector<MyViewModel, AsyncState<UserProfileModel>>(
      selector: (_, vm) => vm.profileState,
      builder: (context, state, _) {
        return GestureDetector(
          onTap: _isLoading ? null : _onProfileImageTap,
          child: Stack(
            children: [_buildImageWidget(size, state), _buildAddButton()],
          ),
        );
      },
    );
  }

  Widget _buildImageWidget(double size, AsyncState<UserProfileModel> state) {
    if (_isLoading) {
      return _buildImageSkeleton(size);
    }

    switch (state.status) {
      case AsyncStatus.loading:
        return _buildImageSkeleton(size);
      case AsyncStatus.success:
        var profile = state.data!;
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
        return _buildEmptyProfileImage(size);
      case AsyncStatus.error:
        return _buildEmptyProfileImage(size);
    }
  }

  Widget _buildImageSkeleton(double size) {
    return Shimmer(
      child: ShimmerSkeletonItem(width: size, height: size, radius: size / 2),
    );
  }

  Widget _buildEmptyProfileImage(double size) {
    return ClipOval(
      child: SvgPicture.asset(
        AppAssets.icEmptyProfile,
        width: size.w,
        height: size.w,
      ),
    );
  }

  Widget _buildAddButton() {
    return Positioned(
      right: 4,
      bottom: 4,
      child: Container(
        margin: EdgeInsets.all(4.w),
        width: 18.w,
        height: 18.w,
        child: SvgPicture.asset(AppAssets.icGroup),
      ),
    );
  }

  Future<void> _onNicknameTap(String currentNickname) async {
    await AppInputDialog.show(
      context: context,
      title: context.l10n.changeNicknameTitle,
      hintText: context.l10n.changeNicknamePlaceholder,
      cancelText: context.l10n.cancel,
      confirmText: context.l10n.changeNicknameButton,
      initialValue: currentNickname,
      maxLength: 10,
      validator: (value, initial) {
        if (value == initial) return ''; // 같으면 버튼 비활성화 (에러 메시지는 표시 안함)
        return null;
      },
      asyncValidator: (value) async {
        return await context.read<MyViewModel>().updateNickname(value);
      },
    );
  }

  Future<void> _onProfileImageTap() async {
    var action = await showProfileImageBottomSheet(context);
    if (action == null) return;

    switch (action) {
      case ProfileImageAction.gallery:
        await _pickImageFromGallery();
        break;
      case ProfileImageAction.camera:
        await _pickImageFromCamera();
        break;
      case ProfileImageAction.delete:
        await _deleteImage();
        break;
    }
  }

  Future<void> _pickImageFromGallery() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _uploadImage(image);
    }
  }

  Future<void> _pickImageFromCamera() async {
    var image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _uploadImage(image);
    }
  }

  Future<void> _uploadImage(XFile image) async {
    setState(() => _isLoading = true);
    await context.read<MyViewModel>().uploadProfileImage(image);
    setState(() => _isLoading = false);
  }

  Future<void> _deleteImage() async {
    setState(() => _isLoading = true);
    await context.read<MyViewModel>().deleteProfileImage();
    setState(() => _isLoading = false);
  }
}
