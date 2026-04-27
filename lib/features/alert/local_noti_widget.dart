import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/routes/app_router.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LocalNotiWidget extends StatefulWidget {
  const LocalNotiWidget({
    required this.message,
    required this.onDismiss,
    super.key,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  State<LocalNotiWidget> createState() => _LocalNotiWidgetState();
}

class _LocalNotiWidgetState extends State<LocalNotiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _slideAnim = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, -1),
          end: const Offset(0, 0.18),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, 0.18),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.forward();
    SystemSound.play(SystemSoundType.alert);
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted || _isDismissing) return;
    _isDismissing = true;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnim,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: GestureDetector(
              onTap: () {
                _dismiss().then((_) => appRouter.push(AppRoutes.alerts));
              },
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 16.h, left: 32.w, right: 32.w),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.primary100,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.topCenter,
                child: Row(
                  spacing: 2.w,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ArtTripText.pretendard()
                          .body01Bold()
                          .color(AppColors.textPoint)
                          .textAlign(TextAlign.center)
                          .build()
                          .text(widget.message),
                    ),
                    SvgPicture.asset(
                      AppAssets.icNoArrowRight,
                      width: 24.w,
                      height: 24.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.textPoint,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
