import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<BottomNavBar> createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // painter를 30px 위로 올림 → flat line(y=30)이 nav bar 상단과 일치
        // bump는 nav bar 상단 위로만 돌출, 흰 배경은 아이템 영역에만 깔림
        Positioned(
          top: -30,
          left: 0,
          right: 0,
          bottom: 0,
          child: CustomPaint(
            painter: BNBCustomPainter(),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  0,
                  AppAssets.icHome,
                  context.l10n.navHome,
                ),
                _buildNavItem(
                  context,
                  1,
                  AppAssets.icLocation,
                  context.l10n.navMap,
                ),
                _buildStampNavItem(context, context.l10n.navStamp),
                _buildNavItem(
                  context,
                  3,
                  AppAssets.icSave,
                  context.l10n.navStorage,
                ),
                _buildNavItem(
                  context,
                  4,
                  AppAssets.icMy,
                  context.l10n.navMy,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String iconPath,
    String label,
  ) {
    final isSelected = widget.currentIndex == index;
    final color = isSelected ? AppColors.primary300 : AppColors.gray900;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 32,
              height: 32,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStampNavItem(BuildContext context, String label) {
    final isSelected = widget.currentIndex == 2;

    return GestureDetector(
      onTap: () => widget.onTap(2),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32,
              child: OverflowBox(
                maxHeight: 48.h,
                alignment: Alignment.bottomCenter,
                child: SvgPicture.asset(
                  AppAssets.icStamp,
                  width: 48.w,
                  height: 48.w,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary300 : AppColors.gray900,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 배경 곡선을 그리는 클래스
class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.textWhite
      ..style = PaintingStyle.fill;

    final Path path = Path();
    // 1. 기본 라인을 y=30으로 설정
    path.moveTo(0, 30.h);
    path.lineTo(size.width * 0.35, 30.h);

    // 2. 왼쪽 완만한 상승 곡선
    path.quadraticBezierTo(size.width * 0.41, 30.h, size.width * 0.45, 15.h);

    // 3. 중앙 상단 볼록한 곡선 (가장 높은 곳 y: 0 부근)
    // clockwise: true로 변경하여 위로 볼록하게 만듭니다.
    path.arcToPoint(
      Offset(size.width * 0.55, 15.h),
      radius: Radius.circular(35.r),
      clockwise: true,
    );

    // 4. 오른쪽 완만한 하강 곡선
    path.quadraticBezierTo(size.width * 0.59, 30.h, size.width * 0.65, 30.h);

    path.lineTo(size.width, 30.h);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final shadowPaint = Paint()
      ..color = const Color(0xFF111111).withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawPath(path.shift(const Offset(0, -3)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
