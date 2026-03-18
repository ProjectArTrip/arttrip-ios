import 'dart:io';

import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/viewmodels/write_review_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// 리뷰 작성 페이지 - 사진 첨부 섹션
class PhotoAttachSection extends StatelessWidget {
  const PhotoAttachSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WriteReviewViewModel>(
      builder: (context, vm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ArtTripText.pretendard()
                    .body01Regular()
                    .color(AppColors.textPrimary)
                    .build()
                    .text(context.l10n.photoAttachLabel),
                SizedBox(width: 4.w),
                ArtTripText.pretendard()
                    .body01Regular()
                    .color(AppColors.textTertiary)
                    .build()
                    .text(context.l10n.photoAttachHint),
              ],
            ),
            SizedBox(height: 12.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // 기존 네트워크 이미지 (수정 모드)
                  ...vm.existingPhotoUrls
                      .asMap()
                      .entries
                      .where((e) => !vm.isExistingImageDeleted(e.key))
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: _NetworkImageThumbnail(
                            imageUrl: entry.value,
                            onRemove: () => vm.removeExistingImage(entry.key),
                          ),
                        ),
                      ),
                  // 새로 추가한 로컬 이미지
                  ...vm.selectedImages.asMap().entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: _ImageThumbnail(
                        file: entry.value,
                        onRemove: () => vm.removeImage(entry.key),
                      ),
                    ),
                  ),
                  if (vm.canAddImage)
                    _AddImageButton(onTap: () => _pickImages(context, vm)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImages(
    BuildContext context,
    WriteReviewViewModel vm,
  ) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      vm.addImages(images);
    }
  }
}

/// 네트워크 이미지 썸네일 (수정 모드 - 기존 이미지)
class _NetworkImageThumbnail extends StatelessWidget {
  const _NetworkImageThumbnail({
    required this.imageUrl,
    required this.onRemove,
  });

  final String imageUrl;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppCachedImage(
          imageUrl: imageUrl,
          width: 72.w,
          height: 72.w,
          borderRadius: BorderRadius.circular(8.r),
        ),
        Positioned(
          top: 4.w,
          right: 4.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
              ),
              child: Icon(Icons.close, size: 16.w, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// 이미지 썸네일
class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({required this.file, required this.onRemove});

  final XFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.file(
            File(file.path),
            width: 72.w,
            height: 72.w,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4.w,
          right: 4.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
              ),
              child: Icon(Icons.close, size: 16.w, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// 이미지 추가 버튼
class _AddImageButton extends StatelessWidget {
  const _AddImageButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          color: AppColors.subLightGray,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.add, size: 24.w, color: AppColors.gray900),
      ),
    );
  }
}
