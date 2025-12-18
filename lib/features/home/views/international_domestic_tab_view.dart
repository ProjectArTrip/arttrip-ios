import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class InternationalDomesticTabView extends StatefulWidget {
  const InternationalDomesticTabView({super.key});

  @override
  State<InternationalDomesticTabView> createState() =>
      _InternationalDomesticTabViewState();
}

class _InternationalDomesticTabViewState
    extends State<InternationalDomesticTabView> {
  List<GlobalKey>? _itemKeys;

  void _updateSelectedLocation(int index, String location) {
    var homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    homeViewModel.updateSelectedLocation(location);
    if (_itemKeys![index].currentContext != null) {
      Scrollable.ensureVisible(
        _itemKeys![index].currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 64.h,
        child: Selector<HomeViewModel, AsyncState<List<String>>>(
          selector: (_, vm) => vm.locations,
          builder: (context, state, _) {
            return AsyncView(
              state: state,
              onData: (data) {
                if (data.isEmpty) return const SizedBox.shrink();

                var itemCount = data.length;
                _itemKeys = List.generate(itemCount, (_) => GlobalKey());

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: itemCount,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(
                    left: 24.w,
                    top: 8.h,
                    right: 24.w,
                    bottom: 16.h,
                  ),
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    return _buildLocationItem(
                      _itemKeys![index],
                      index,
                      data[index],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  GestureDetector _buildLocationItem(
    GlobalKey key,
    int index,
    String location,
  ) {
    return GestureDetector(
      onTap: () {
        var homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
        if (homeViewModel.selectedLocation != location) {
          _updateSelectedLocation(index, location);
        }
      },
      child: Selector<HomeViewModel, String>(
        selector: (_, vm) => vm.selectedLocation,
        builder: (context, selectedLocationIndex, _) {
          var isSelected = location == selectedLocationIndex;
          return Container(
            key: key,
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: isSelected ? AppColors.primary300 : AppColors.gray0,
              border: Border.all(
                color: isSelected ? AppColors.primary300 : AppColors.gray100,
                width: 1.w,
              ),
            ),
            child: ArtTripText.pretendard()
                .body01Bold()
                .color(isSelected ? AppColors.textWhite : AppColors.textPrimary)
                .build()
                .text(location),
          );
        },
      ),
    );
  }
}
