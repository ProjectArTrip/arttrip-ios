import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/map/data/models/country_location.dart';
import 'package:arttrip/features/map/viewmodels/map_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class MapCategoryBar extends StatelessWidget {
  const MapCategoryBar({super.key, required this.onCountrySelected});

  final void Function(CountryLocationData location) onCountrySelected;

  @override
  Widget build(BuildContext context) {
    return Consumer<MapViewModel>(
      builder: (context, vm, _) {
        final isOpen = vm.isDropdownOpen;
        final allCountries = [context.l10n.domestic, ...vm.countries];

        return Container(
          decoration: BoxDecoration(
            color: AppColors.gray0,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.gray100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더 (선택된 국가 + chevron)
              GestureDetector(
                onTap: () => vm.toggleDropdown(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: isOpen
                      ? const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.gray100),
                          ),
                        )
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: ArtTripText.pretendard()
                            .body01Bold()
                            .color(AppColors.textPrimary)
                            .build()
                            .text(
                              vm.selectedCountry ??
                                  context.l10n.mapSelectCountry,
                            ),
                      ),
                      Icon(
                        isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textPrimary,
                        size: 24.w,
                      ),
                    ],
                  ),
                ),
              ),

              // 국가 리스트 (열린 상태)
              if (isOpen)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 240.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: allCountries.length,
                    itemBuilder: (context, index) {
                      final country = allCountries[index];
                      return GestureDetector(
                        onTap: () {
                          final location = vm.selectCountry(country);
                          onCountrySelected(
                            location ?? CountryLocation.defaultLocation,
                          );
                        },
                        child: Container(
                          color: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          child: ArtTripText.pretendard()
                              .body01Light()
                              .color(AppColors.textPrimary)
                              .build()
                              .text(country),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
