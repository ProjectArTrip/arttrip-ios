import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/features/alert/alert_viewmodel.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class AlertBadge extends StatelessWidget {
  const AlertBadge({super.key, this.iconType = false, this.hasUnread});

  final bool iconType;
  final bool? hasUnread;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !iconType
          ? () {
              Routes.push(context, AppRoutes.alerts).then((_) {
                if (context.mounted) {
                  final alertVM = context.read<AlertViewModel>();
                  alertVM.getUnreadAlerts();
                }
              });
            }
          : null,
      child: SizedBox(
        width: 24.w,
        height: 24.w,
        child: Stack(
          children: [
            SvgPicture.asset(
              AppAssets.icNotification,
              width: 24.w,
              height: 24.w,
            ),
            hasUnread == null
                ? Selector<AlertViewModel, bool>(
                    selector: (_, vm) => vm.hasUnread,
                    builder: (context, hasUnread, _) {
                      if (!hasUnread) return const SizedBox.shrink();

                      return _buildUnreadMark();
                    },
                  )
                : hasUnread == true
                ? _buildUnreadMark()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Positioned _buildUnreadMark() {
    return Positioned(
      top: 3.h,
      right: 2.5.w,
      child: CircleAvatar(
        backgroundColor: const Color(0xFFFF5255),
        radius: 3.w,
      ),
    );
  }
}
