import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_review.dart';
import 'package:arttrip/features/exhibit/viewmodel/exhibit_detail_viewmodel.dart';
import 'package:arttrip/features/exhibit/widgets/review_list_item.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/init_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 전시 리뷰 탭 콘텐츠
class ExhibitReviewTabContent extends StatelessWidget {
  const ExhibitReviewTabContent({super.key, required this.exhibitId});

  final int exhibitId;

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      init: () {
        context.read<ExhibitDetailViewModel>().fetchExhibitReviews(exhibitId);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBox(context),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildReviewContent(context),
          ),
        ],
      ),
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
      child: Selector<ExhibitDetailViewModel, int>(
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
        onPressed: () {
          // TODO: 리뷰 작성 화면 이동
        },
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

  Widget _buildReviewContent(BuildContext context) {
    return Selector<ExhibitDetailViewModel, AsyncState<List<ExhibitReview>>>(
      selector: (_, vm) => vm.reviewsState,
      builder: (context, state, _) {
        return AsyncView<List<ExhibitReview>>(
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

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: Center(
        child: ArtTripText.pretendard()
            .body01Regular()
            .color(AppColors.textTertiary)
            .build()
            .text(context.l10n.noReviews),
      ),
    );
  }

  Widget _buildReviewItems(BuildContext context, List<ExhibitReview> reviews) {
    return Selector<ExhibitDetailViewModel, bool>(
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
