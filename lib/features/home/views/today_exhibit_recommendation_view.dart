import 'package:arttrip/features/home/home_viewmodel.dart';
import 'package:arttrip/features/home/widgets/today_exhibition_widget.dart';
import 'package:arttrip/shared/models/exhibit_model.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class TodayExhibitRecommendationView extends StatefulWidget {
  const TodayExhibitRecommendationView({super.key});

  @override
  State<TodayExhibitRecommendationView> createState() => _TodayExhibitRecommendationViewState();
}

class _TodayExhibitRecommendationViewState extends State<TodayExhibitRecommendationView> {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          switch (index) {
            case 0:
              return Selector<HomeViewModel, AsyncState<List<ExhibitModel>>>(
                selector: (_, vm) => vm.todayExhibitRecommendations,
                builder: (context, state, _) {
                  return AsyncView(
                    state: state,
                    onData: (data) {
                      return SizedBox(
                        height: 240.h,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: data.length,
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          separatorBuilder: (context, index) => SizedBox(width: 8.w),
                          itemBuilder: (context, index) {
                            var item = data[index];
                            return item.posterUrl?.isNotEmpty == true
                                ? TodayExhibitionWidget(
                                    item: item,
                                    onTap: () {},
                                    likeOnTap: () {},
                                  )
                                : const SizedBox.shrink();
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
        childCount: 1,
      ),
    );
  }
}
