import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/alert_badge.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: context.l10n.alert),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: 24.w,
              top: 8.h,
              right: 24.w,
              bottom: 48.h,
            ),
            sliver: SliverList.separated(
              itemCount: 10,
              separatorBuilder: (context, index) => SizedBox(height: 4.h),
              itemBuilder: (context, index) {
                final isUnread = index % 2 == 0 ? true : false;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.w,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.all(12.w),
                      child: const AlertBadge(iconType: true),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 13.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ArtTripText.pretendard()
                                  .title02Bold()
                                  .color(
                                    isUnread
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  )
                                  .build()
                                  .text('알림 타이틀'),
                              ArtTripText.pretendard()
                                  .body02Light()
                                  .color(AppColors.textTertiary)
                                  .build()
                                  .text('N분 전'),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          ArtTripText.pretendard()
                              .body01Regular()
                              .color(
                                isUnread
                                    ? AppColors.textSecondary
                                    // ignore: dead_code
                                    : AppColors.textTertiary,
                              )
                              .ellipsis(2)
                              .build()
                              .text('알림 내용입니다. 최대 2줄' * 30),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
