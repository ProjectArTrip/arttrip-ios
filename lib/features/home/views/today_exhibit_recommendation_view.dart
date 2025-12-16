import 'package:flutter/material.dart';

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
              return const SizedBox.shrink();
            case 1:
              return const SizedBox.shrink();
            default:
              return const SizedBox.shrink();
          }
        },
        childCount: 2,
      ),
    );
  }
}
