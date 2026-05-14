import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/features/stamp/widgets/stamp_header.dart';
import 'package:arttrip/features/stamp/widgets/stamp_sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StampPage extends StatefulWidget {
  const StampPage({super.key});

  @override
  State<StampPage> createState() => _StampPageState();
}

class _StampPageState extends State<StampPage> {
  static const double _progressValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.gray0,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.imgStampBg,
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: StampHeader(topPadding: topPadding),
                pinned: false,
              ),
              const SliverToBoxAdapter(
                child: StampSheetHeader(progress: _progressValue),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.subLightGray,
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 24.w,
                    bottom: 40.h + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Image.asset(
                    AppAssets.imgStampSample,
                    fit: BoxFit.cover,
                  ),
                ), // 샘플 이미지
              ),
            ],
          ),
        ],
      ),
    );
  }
}
