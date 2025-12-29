import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/viewmodels/alert_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class AlertBadge extends StatelessWidget {
  const AlertBadge({super.key, this.isUnread, required this.path});

  final bool? isUnread;
  final String path;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          isUnread == null
              ? () => Routes.push(context, path).then((_) {
                if (context.mounted) {
                  Provider.of<AlertViewModel>(context, listen: false)
                      .unreadCount = 0;
                }
              })
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

            isUnread != null
                ? isUnread == true
                    ? _buildUnreadMark()
                    : const SizedBox.shrink()
                : Selector<AlertViewModel, bool>(
                  selector: (_, vm) => vm.hasUnread,
                  builder: (context, hasUnread, _) {
                    if (!hasUnread) return const SizedBox.shrink();

                    return _buildUnreadMark();
                  },
                ),
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
