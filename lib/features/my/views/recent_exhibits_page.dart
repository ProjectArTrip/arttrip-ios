import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/my/data/models/recent_exhibit_model.dart';
import 'package:arttrip/features/my/viewmodels/my_viewmodel.dart';
import 'package:arttrip/features/my/widgets/recent_exhibit_item.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:arttrip/shared/widgets/init_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class RecentExhibitsPage extends StatelessWidget {
  const RecentExhibitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InitWidget(
      init: () => context.read<MyViewModel>().fetchRecentExhibits(),
      child: Scaffold(
        backgroundColor: AppColors.gray0,
        appBar: CommonAppBar(
          title: context.l10n.myRecentExhibits,
          showBackButton: true,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Selector<MyViewModel, AsyncState<List<RecentExhibitModel>>>(
      selector: (_, vm) => vm.recentExhibitsState,
      builder: (context, state, _) {
        return AsyncView<List<RecentExhibitModel>>(
          state: state,
          onData: (exhibits) {
            if (exhibits.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildList(exhibits);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 56),
      child: Center(
        child: Column(
          children: [
            SvgPicture.asset(AppAssets.icRecent),
            const SizedBox(height: 8),
            ArtTripText.pretendard()
                .body01Regular()
                .color(AppColors.textTertiary)
                .build()
                .text(context.l10n.noRecentExhibits),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<RecentExhibitModel> exhibits) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      itemCount: exhibits.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return RecentExhibitItem(exhibit: exhibits[index]);
      },
    );
  }
}
