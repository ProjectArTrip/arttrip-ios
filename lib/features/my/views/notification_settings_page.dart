import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/config/prefs.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/my/viewmodels/my_viewmodel.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:arttrip/shared/widgets/common_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notice = Prefs().pushEnabled;
  bool _isUpdating = false;

  Future<void> _onNoticeChanged(bool value) async {
    if (_isUpdating) return;

    final previous = _notice;
    setState(() {
      _notice = value;
      _isUpdating = true;
    });

    final vm = context.read<MyViewModel>();
    final success = await vm.updatePushEnabled(value);

    if (!mounted) return;
    if (success) {
      await Prefs().setPushEnabled(value);
    }
    setState(() {
      if (!success) _notice = previous;
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: CommonAppBar(
        title: context.l10n.notificationSettings,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              _buildSectionHeader(context.l10n.serviceNotification),
              SizedBox(height: 8.h),
              ArtTripText.pretendard()
                  .body01Regular()
                  .color(AppColors.textTertiary)
                  .build()
                  .text(context.l10n.serviceNotificationDesc),
              SizedBox(height: 16.h),
              _buildToggleRow(
                label: context.l10n.notifNotice,
                value: _notice,
                onChanged: _isUpdating ? null : _onNoticeChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return ArtTripText.pretendard()
        .title02Bold()
        .color(AppColors.textPrimary)
        .build()
        .text(title);
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ArtTripText.pretendard()
            .title02Light()
            .color(AppColors.textPrimary)
            .build()
            .text(label),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary300,
        ),
      ],
    );
  }
}
