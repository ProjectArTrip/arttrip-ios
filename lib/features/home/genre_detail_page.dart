import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/exhibit/viewmodels/exhibit_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class GenreDetailPage extends StatefulWidget {
  const GenreDetailPage({
    super.key,
    required this.genreName,
    required this.isDomestic,
    this.region,
    this.country,
    this.sortType,
  });

  final String genreName;
  final bool isDomestic;
  final String? region;
  final String? country;
  final String? sortType;

  @override
  State<GenreDetailPage> createState() => _GenreDetailPageState();
}

class _GenreDetailPageState extends State<GenreDetailPage> {
  final int size = 10;
  int cursor = 0;

  @override
  void initState() {
    super.initState();
    final exhibitVM = context.read<ExhibitViewModel>();
    Future.delayed(Duration.zero, () {
      exhibitVM.getExhibitFilters(
        isDomestic: widget.isDomestic,
        cursor: cursor,
        size: size,
        country: widget.country,
        region: widget.region,
        genres: widget.genreName,
        sortType: widget.sortType,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: context.l10n.genreDetailExhibition(widget.genreName),
        actions: const [AlertBadge()],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24.h),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 11.h),
                child: ArtTripText.pretendard().title02Bold().build().text(
                  context.l10n.totalCount(size),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 8.h),
                child: GestureDetector(
                  onTap: () => _buildFilterSheet(),
                  child: SvgPicture.asset(
                    AppAssets.icFilter,
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ),
            ],
          ),

          // Builder(
          //   builder: (context) {
          //     return ListView.separated(
          //       physics: const NeverScrollableScrollPhysics(),
          //       shrinkWrap: true,
          //       size: size,
          //       separatorBuilder: (context, index) => SizedBox(height: 12.h),
          //       itemBuilder: (context, index) {
          //         return ExhibitListItem(item: ,);
          //       },
          //     );
          //   }
          // ),
        ],
      ),
    );
  }

  Future<void> _buildFilterSheet() {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      backgroundColor: AppColors.subLightGray,
      isScrollControlled: true,
      builder: (context) => Container(),
      // builder: (_) => Selector<HomeViewModel, AsyncState<List<String>>>(
      //   selector: (_, vm) => vm.overseasCountries,
      //   builder: (context, overseasCountries, _) {
      //     return AsyncView(
      //       state: overseasCountries,
      //       onData: (data) {
      //         return DateFilterBottomSheet(data);
      //       },
      //     );
      //   },
      // ),
    );
  }
}
