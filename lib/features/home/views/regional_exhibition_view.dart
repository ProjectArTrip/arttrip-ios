import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class RegionalExhibitionView extends StatefulWidget {
  const RegionalExhibitionView({super.key});

  @override
  State<RegionalExhibitionView> createState() => _RegionalExhibitionViewState();
}

class _RegionalExhibitionViewState extends State<RegionalExhibitionView> {
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsetsGeometry.only(top: 32.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            switch (index) {
              case 0:
                return Padding(
                  padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 12.h),
                  child: ArtTripText.pretendard().title01Bold().build().text(context.l10n.regionalExhibition),
                );
              case 1:
                return Selector<HomeViewModel, AsyncState<List<String>>>(
                  selector: (_, vm) => vm.locations,
                  builder: (context, state, _) {
                    return AsyncView(
                      state: state,
                      onData: (data) {
                        return SizedBox(
                          height: 90.h,
                          child: ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: data.length,
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            separatorBuilder: (context, index) => SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
                              var item = data[index];
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CircleAvatar(
                                    radius: 32.w,
                                    backgroundColor: Colors.black,
                                  ),
                                  ArtTripText.pretendard().body02Bold().build().text(item),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              default:
                return const SizedBox.shrink();
            }
          },
          childCount: 2,
        ),
      ),
    );
  }
}
