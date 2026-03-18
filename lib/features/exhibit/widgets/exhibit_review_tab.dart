import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review_model.dart';
import 'package:arttrip/features/exhibit/data/models/write_review_params.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_detail_viewmodel.dart';
import 'package:arttrip/features/exhibit/widgets/review_list_item.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_confirm_dialog.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 전시 리뷰 탭 콘텐츠
class ExhibitReviewModelTabContent extends StatefulWidget {
  const ExhibitReviewModelTabContent({
    super.key,
    required this.exhibitId,
    required this.exhibit,
  });

  final int exhibitId;
  final ExhibitDetailModel exhibit;

  @override
  State<ExhibitReviewModelTabContent> createState() =>
      _ExhibitReviewModelTabContentState();
}

class _ExhibitReviewModelTabContentState
    extends State<ExhibitReviewModelTabContent> {
  @override
  Widget build(BuildContext context) {
    return Selector<ExhibitDetailModelViewModel, int>(
      selector: (_, vm) => vm.reviewTotalCount,
      builder: (context, totalCount, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBox(context),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _buildReviewContent(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderBox(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 16, 24.w, 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.subLightGray,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Selector<ExhibitDetailModelViewModel, int>(
        selector: (_, vm) => vm.reviewTotalCount,
        builder: (context, totalCount, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ArtTripText.pretendard()
                      .body02Bold()
                      .color(AppColors.textPrimary)
                      .build()
                      .text(context.l10n.exhibitReviewCount),
                  SizedBox(width: 4.w),
                  ArtTripText.pretendard()
                      .body02Bold()
                      .color(AppColors.primary300)
                      .build()
                      .text('($totalCount)'),
                ],
              ),
              SizedBox(height: 16.h),
              _buildWriteReviewButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWriteReviewButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton(
        onPressed: () => _onWriteReviewPressed(context),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.gray0,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: Color(0xFFDBDBDB)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: ArtTripText.pretendard()
            .body02Bold()
            .color(const Color(0xFF111111))
            .build()
            .text(context.l10n.writeReview),
      ),
    );
  }

  Future<void> _onWriteReviewPressed(BuildContext context) async {
    // 다이얼로그로 리뷰 작성 확인
    final confirmed = await _showReviewPromptDialog(context);
    if (confirmed != true || !context.mounted) return;

    // 리뷰 작성 페이지로 이동
    final result = await Routes.modal<bool>(
      context,
      '/exhibit/write-review/${widget.exhibitId}',
      extra: WriteReviewParams(
        posterUrl: widget.exhibit.posterUrl,
        title: widget.exhibit.title,
        hallName: widget.exhibit.hallName,
      ),
    );

    // 리뷰 등록 성공 시 목록 새로고침
    if (result == true && context.mounted) {
      await context
          .read<ExhibitDetailModelViewModel>()
          .fetchExhibitReviewModels(widget.exhibitId);
    }
  }

  Widget _buildReviewContent(BuildContext context) {
    return Selector<
      ExhibitDetailModelViewModel,
      AsyncState<List<ExhibitReviewModel>>
    >(
      selector: (_, vm) => vm.reviewsState,
      builder: (context, state, _) {
        return AsyncView<List<ExhibitReviewModel>>(
          state: state,
          onData: (reviews) {
            if (reviews.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildReviewItems(context, reviews);
          },
        );
      },
    );
  }

  Future<bool?> _showReviewPromptDialog(BuildContext context) {
    return AppConfirmDialog.show(
      context: context,
      title: context.l10n.reviewPromptTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.reviewPromptContent,
            textAlign: TextAlign.center,
            style:
                ArtTripText.pretendard()
                    .body01Regular()
                    .color(AppColors.textPrimary)
                    .build()
                    .style(),
          ),
          SizedBox(height: 16.h),
          ArtTripText.pretendard()
              .body01Bold()
              .color(AppColors.textPrimary)
              .build()
              .text(context.l10n.reviewPromptQuestion),
        ],
      ),
      cancelText: context.l10n.cancel,
      confirmText: context.l10n.writeReviewButton,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: Center(
        child: ArtTripText.pretendard()
            .body01Regular()
            .color(AppColors.textTertiary)
            .build()
            .text(context.l10n.noReviews),
      ),
    );
  }

  Widget _buildReviewItems(
    BuildContext context,
    List<ExhibitReviewModel> reviews,
  ) {
    return Selector<ExhibitDetailModelViewModel, bool>(
      selector: (_, vm) => vm.isLoadingMoreReviews,
      builder: (context, isLoadingMore, _) {
        return Column(
          children: [
            ...reviews.map(
              (review) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: ReviewListItem(review: review),
              ),
            ),
            if (isLoadingMore)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}
