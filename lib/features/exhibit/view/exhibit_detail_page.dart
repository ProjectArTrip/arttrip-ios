import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_detail.dart';
import 'package:arttrip/features/exhibit/viewmodel/exhibit_detail_viewmodel.dart';
import 'package:arttrip/features/exhibit/widgets/exhibit_detail_tab.dart';
import 'package:arttrip/features/exhibit/widgets/exhibit_header_section.dart';
import 'package:arttrip/features/exhibit/widgets/exhibit_map_tab.dart';
import 'package:arttrip/features/exhibit/widgets/exhibit_poster_image.dart';
import 'package:arttrip/features/exhibit/widgets/exhibit_review_tab.dart';
import 'package:arttrip/features/exhibit/widgets/exhibit_tab_bar.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/init_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// 전시 상세 페이지
class ExhibitDetailPage extends StatefulWidget {
  const ExhibitDetailPage({super.key, required this.exhibitId});
  final int exhibitId;

  @override
  State<ExhibitDetailPage> createState() => _ExhibitDetailPageState();
}

class _ExhibitDetailPageState extends State<ExhibitDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      init: () {
        var vm = context.read<ExhibitDetailViewModel>();
        vm.fetchExhibitDetail(widget.exhibitId);
        vm.checkFavorite(widget.exhibitId);
      },
      child: Scaffold(
        backgroundColor: AppColors.gray0,
        appBar: AppBar(
          backgroundColor: AppColors.gray0,
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            Selector<ExhibitDetailViewModel, bool>(
              selector: (_, vm) => vm.isFavorite,
              builder: (context, isFavorite, _) {
                return IconButton(
                  onPressed: () {
                    context.read<ExhibitDetailViewModel>().toggleFavorite(
                      widget.exhibitId,
                    );
                  },
                  icon: SvgPicture.asset(
                    isFavorite ? AppAssets.icHeart : AppAssets.icEmptyHeart,
                    width: 24.w,
                    height: 24.w,
                  ),
                );
              },
            ),
          ],
        ),
        body: Selector<ExhibitDetailViewModel, AsyncState<ExhibitDetail>>(
          selector: (_, vm) => vm.exhibitState,
          builder: (context, state, _) {
            return AsyncView<ExhibitDetail>(
              state: state,
              onData: (exhibit) => _buildContent(exhibit),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ExhibitDetail exhibit) {
    return Stack(
      children: [
        // 배경 이미지 (고정)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ExhibitPosterImage(
            posterUrl: exhibit.posterUrl,
            status: exhibit.status,
          ),
        ),

        // 스크롤 가능한 바텀시트 영역
        DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.65,
          maxChildSize: 0.98,
          snap: true,
          snapSizes: const [0.65, 0.98],
          builder: (context, scrollController) {
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.gray0,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  // 제목/장소/기간 섹션
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
                      child: ExhibitHeaderSection(
                        title: exhibit.title,
                        hallName: exhibit.hallName,
                        exhibitPeriod: exhibit.exhibitPeriod,
                        ticketUrl: exhibit.ticketUrl,
                      ),
                    ),
                  ),

                  // 탭바
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppColors.gray0,
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: ExhibitTabBar(tabController: _tabController),
                    ),
                  ),

                  // 탭 콘텐츠
                  SliverToBoxAdapter(
                    child: _buildTabContent(exhibit),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabContent(ExhibitDetail exhibit) {
    switch (_currentTabIndex) {
      case 0:
        return ExhibitDetailTabContent(exhibit: exhibit);
      case 1:
        return ExhibitMapTabContent(exhibit: exhibit);
      case 2:
        return ExhibitReviewTabContent(
          exhibitId: widget.exhibitId,
          exhibit: exhibit,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
