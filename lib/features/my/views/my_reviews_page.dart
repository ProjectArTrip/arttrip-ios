import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/write_review_params.dart';
import 'package:arttrip/features/my/data/models/my_review_model.dart';
import 'package:arttrip/features/my/viewmodels/my_viewmodel.dart';
import 'package:arttrip/features/my/widgets/my_review_item.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/app_confirm_dialog.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/init_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MyViewModel>().fetchMoreReviews();
    }
  }

  Future<void> _handleDelete(int reviewId) async {
    var confirmed = await AppConfirmDialog.show(
      context: context,
      title: context.l10n.deleteReviewTitle,
      content: Text(
        context.l10n.deleteReviewContent,
        textAlign: TextAlign.center,
        style:
            ArtTripText.pretendard()
                .body01Regular()
                .color(AppColors.textSecondary)
                .build()
                .style(),
      ),
      cancelText: context.l10n.cancel,
      confirmText: context.l10n.deleteButton,
    );

    if (confirmed == true && mounted) {
      await context.read<MyViewModel>().deleteReview(reviewId);
    }
  }

  Future<void> _handleEdit(MyReviewModel review) async {
    var result = await Routes.modal<bool>(
      context,
      '/review/edit/${review.reviewId}',
      extra: WriteReviewParams(
        posterUrl: review.posterUrl ?? '',
        title: review.reviewTitle,
        hallName: review.hallName ?? '',
        reviewId: review.reviewId,
      ),
    );

    if (result == true && mounted) {
      await context.read<MyViewModel>().fetchMyReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      init: () {
        var vm = context.read<MyViewModel>();
        vm.resetReviews();
        vm.fetchMyReviews();
      },
      child: Scaffold(
        backgroundColor: AppColors.gray0,
        appBar: CommonAppBar(
          title: context.l10n.myReviewsTitle,
          showBackButton: true,
        ),
        body: _buildReviewList(),
      ),
    );
  }

  Widget _buildReviewList() {
    return Selector<MyViewModel, AsyncState<List<MyReviewModel>>>(
      selector: (_, vm) => vm.reviewsState,
      builder: (context, state, _) {
        return AsyncView<List<MyReviewModel>>(
          state: state,
          onData: (reviews) {
            if (reviews.isEmpty) {
              return _buildEmptyState();
            }
            return _buildReviewItems(reviews);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 57),
      child: Center(
        child: Column(
          children: [
            SvgPicture.asset(AppAssets.icReview),
            const SizedBox(height: 8),
            ArtTripText.pretendard()
                .body01Regular()
                .color(AppColors.textTertiary)
                .build()
                .text(context.l10n.noReviewsYet),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItems(List<MyReviewModel> reviews) {
    return Consumer<MyViewModel>(
      builder: (context, vm, _) {
        var isLoadingMore = vm.isLoadingMoreReviews;
        var totalCount = vm.reviewTotalCount;
        // +1 for header, +1 for loading indicator if loading
        var itemCount = reviews.length + 1 + (isLoadingMore ? 1 : 0);

        return ListView.builder(
          controller: _scrollController,
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // 첫 번째 아이템: 총 개수
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(
                  top: 16.h,
                  bottom: 20.h,
                  left: 24.w,
                  right: 24.w,
                ),
                child: ArtTripText.pretendard()
                    .title02Bold()
                    .color(AppColors.textPrimary)
                    .build()
                    .text(context.l10n.totalCount(totalCount)),
              );
            }

            // 마지막 아이템: 로딩 인디케이터
            if (index == itemCount - 1 && isLoadingMore) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            // 리뷰 아이템 (index - 1 because of header)
            var reviewIndex = index - 1;
            return Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
              child: MyReviewItem(
                review: reviews[reviewIndex],
                onDelete: () => _handleDelete(reviews[reviewIndex].reviewId),
                onEdit: () => _handleEdit(reviews[reviewIndex]),
              ),
            );
          },
        );
      },
    );
  }
}
