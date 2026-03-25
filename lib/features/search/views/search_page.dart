import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/data/models/exhibit_model.dart';
import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';
import 'package:arttrip/features/search/data/models/search_history_model.dart';
import 'package:arttrip/features/search/viewmodels/search_viewmodel.dart';
import 'package:arttrip/features/search/widgets/recent_search_section.dart';
import 'package:arttrip/features/search/widgets/recommended_search_section.dart';
import 'package:arttrip/features/search/widgets/search_input_field.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/exhibit_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 검색 페이지
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<SearchViewModel>();
    vm.reset(notify: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.init();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: CommonAppBar(title: context.l10n.searchTitle),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
            child: SearchInputField(
              controller: _controller,
              onSearch: _onSearch,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Selector<SearchViewModel, bool>(
      selector: (_, vm) => vm.isSearchMode,
      builder: (context, isSearchMode, _) {
        return isSearchMode ? _buildSearchResults() : _buildInitialView();
      },
    );
  }

  /// 초기 화면: 최근 검색어 + 추천 검색어
  Widget _buildInitialView() {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 최근 검색어
            Selector<SearchViewModel, List<SearchHistoryModel>>(
              selector: (_, vm) => vm.recentSearches,
              builder: (context, recentSearches, _) {
                if (recentSearches.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(bottom: 32.h),
                  child: RecentSearchSection(
                    recentSearches: recentSearches,
                    onTap: _onChipTap,
                    onDelete: (id) {
                      context.read<SearchViewModel>().removeRecentSearch(id);
                    },
                    onClearAll: () {
                      context.read<SearchViewModel>().clearAllRecentSearches();
                    },
                  ),
                );
              },
            ),
            // 추천 검색어
            Selector<SearchViewModel, AsyncState<List<KeywordModel>>>(
              selector: (_, vm) => vm.recommendedKeywords,
              builder: (context, state, _) {
                return AsyncView<List<KeywordModel>>(
                  state: state,
                  onData: (keywords) {
                    if (keywords.isEmpty) return const SizedBox.shrink();
                    return RecommendedSearchSection(
                      keywords: keywords,
                      onTap: _onChipTap,
                    );
                  },
                  onLoading: () => const SizedBox.shrink(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 검색 결과
  Widget _buildSearchResults() {
    return Selector<SearchViewModel, AsyncState<List<ExhibitModel>>>(
      selector: (_, vm) => vm.searchResults,
      builder: (context, state, _) {
        return AsyncView<List<ExhibitModel>>(
          state: state,
          onData: (exhibits) {
            if (exhibits.isEmpty) return _buildEmptyState();
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              itemCount: exhibits.length,
              separatorBuilder: (_, _) => SizedBox(height: 16.h),
              itemBuilder: (_, index) => ExhibitListItem(item: exhibits[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ArtTripText.pretendard()
          .body01Regular()
          .color(AppColors.textTertiary)
          .build()
          .text(context.l10n.noSearchResults),
    );
  }

  void _onSearch(String query) {
    context.read<SearchViewModel>().search(query.trim());
  }

  void _onChipTap(String keyword) {
    _controller.text = keyword;
    _controller.selection = TextSelection.collapsed(offset: keyword.length);
    _onSearch(keyword);
  }
}
