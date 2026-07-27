import 'package:arttrip/core/app_utils.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_filter_model.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/exception_view.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item.dart';
import 'package:arttrip/shared/widgets/exhibits_loading_view.dart';
import 'package:arttrip/shared/widgets/no_exhibits_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CurationDetailPage extends StatefulWidget {
  const CurationDetailPage({
    super.key,
    required this.title,
    required this.curationId,
  });

  final String title;
  final String curationId;

  @override
  State<CurationDetailPage> createState() => _CurationDetailPageState();
}

class _CurationDetailPageState extends State<CurationDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<List<ExhibitModel>?> _exhibits = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(true); // 전체 로딩 상태
  final ValueNotifier<bool> _hasNext = ValueNotifier(true); // 다음 페이지 존재 여부
  final ValueNotifier<bool> _loadingMore = ValueNotifier(false); // 추가 로딩 상태

  final double _threshold = 50.0;
  final int _size = 10;
  int _cursor = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _getCurationExhibits());

    _scrollController.addListener(() async {
      // 데이터 로딩중이거나 더 불러올 데이터가 없으면 추가 로딩 방지
      if (_loadingMore.value || !_hasNext.value) return;

      final position = _scrollController.position;

      if (position.pixels >= position.maxScrollExtent - _threshold) {
        if (!_isLoading.value && _hasNext.value) {
          AppUtil.debugLog('now loading more');
          await _loadMoreExhibits();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurationExhibits() async {
    _isLoading.value = true;
    _cursor = 0;

    final homeVM = Provider.of<HomeViewModel>(context, listen: false);
    final ExhibitFilterModel? result = await homeVM.getCurationDetail(
      curationId: widget.curationId,
      cursor: _cursor,
      size: _size,
    );

    _exhibits.value = result?.exhibits;
    _hasNext.value = result?.hasNext ?? false;
    _cursor = result?.nextCursor ?? 0;
    _isLoading.value = false;
  }

  Future<void> _loadMoreExhibits() async {
    if (!_hasNext.value) return;
    _loadingMore.value = true;

    final homeVM = context.read<HomeViewModel>();
    final result = await homeVM.getCurationDetail(
      curationId: widget.curationId,
      cursor: _cursor,
      size: _size,
    );

    _exhibits.value = [...?_exhibits.value, ...?result?.exhibits];
    _hasNext.value = result?.hasNext ?? false;
    _cursor = result?.nextCursor ?? 0;
    _loadingMore.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: ArtTripText.pretendard()
            .headline()
            .ellipsis(2)
            .textAlign(TextAlign.center)
            .build()
            .text(
              widget.title.isEmpty ? context.l10n.curationTitle : widget.title,
            ),
        actions: const [AlertBadge()],
      ),
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
              child: const ExhibitsLoadingView(),
            );
          }

          return ValueListenableBuilder(
            valueListenable: _exhibits,
            builder: (context, exhibits, child) {
              if (exhibits == null) {
                return const ExceptionView();
              } else if (exhibits.isEmpty) {
                return const NoExhibitsView();
              }
              final bool isDomestic =
                  context.read<HomeViewModel>().locationType ==
                  LocationType.domestic;
              return ValueListenableBuilder(
                valueListenable: _loadingMore,
                builder: (context, loadingMore, child) {
                  final int length = exhibits.length + (loadingMore ? 1 : 0);

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    itemCount: length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (loadingMore && index == exhibits.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final ExhibitModel item = exhibits[index];
                      return ExhibitListItem(
                        item: item,
                        isDomestic: isDomestic,
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
