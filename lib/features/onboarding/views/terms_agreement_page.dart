import 'package:arttrip/core/app_assets.dart';
import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/config/prefs.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/auth/services/auth_service.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/route_params.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// 온보딩 0단계: 약관동의 화면
///
/// 소셜 로그인 성공 후 서버 요청 전에 거치는 화면.
/// 3가지 약관에 모두 동의해야 다음 버튼이 활성화됩니다.
class TermsAgreementPage extends StatefulWidget {
  const TermsAgreementPage({super.key, required this.params});

  final SocialLoginParams params;

  @override
  State<TermsAgreementPage> createState() => _TermsAgreementPageState();
}

class _TermsAgreementPageState extends State<TermsAgreementPage> {
  bool _termsOfService = false;
  bool _privacyPolicy = false;
  bool _locationService = false;
  bool _isLoading = false;

  bool get _allChecked => _termsOfService && _privacyPolicy && _locationService;

  void _toggleAll(bool value) {
    setState(() {
      _termsOfService = value;
      _privacyPolicy = value;
      _locationService = value;
    });
  }

  Future<void> _onNext() async {
    if (!_allChecked || _isLoading) return;

    if (widget.params.skipServerLogin) {
      await Prefs().setOnboardingStep(OnboardingStep.nickname);
      if (!mounted) return;
      Routes.go(context, AppRoutes.onboardingNickname);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await AuthService.instance.loginWithServer(
        context,
        widget.params,
      );
      if (!mounted) return;
      if (result.isSuccess) {
        _navigateAfterLogin(result);
      } else {
        _showError();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateAfterLogin(AuthResult result) {
    switch (result.onboardingStep) {
      case OnboardingStep.nickname:
        Routes.go(context, AppRoutes.onboardingNickname);
      case OnboardingStep.keyword:
        Routes.go(context, AppRoutes.onboardingKeywords);
      case OnboardingStep.completed:
      case null:
        Routes.go(context, '/');
    }
  }

  void _openWebView(String title, String url) {
    Routes.push(
      context,
      AppRoutes.webview,
      extra: WebViewParams(title: title, url: url),
    );
  }

  OverlayEntry? _errorEntry;

  void _showError() {
    _errorEntry?.remove();
    _errorEntry = OverlayEntry(
      builder: (_) => _ErrorOverlay(
        message: context.l10n.loginFailed,
        onDismiss: () {
          _errorEntry?.remove();
          _errorEntry = null;
        },
      ),
    );
    Overlay.of(context).insert(_errorEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              _buildHeader(),
              const Spacer(),
              _buildAgreeAllRow(),
              _buildDivider(),
              _buildTermRow(
                label: context.l10n.termsOfServiceAgree,
                checked: _termsOfService,
                onTap: () => setState(() => _termsOfService = !_termsOfService),
                onTapTerm: () => _openWebView(
                  context.l10n.termsOfServiceAgree,
                  'https://chiseled-cow-85a.notion.site/ArtTrip-2ccbd56ec2ac804ba690ce059d418a63',
                ),
              ),
              SizedBox(height: 16.h),
              _buildTermRow(
                label: context.l10n.termsPrivacyAgree,
                checked: _privacyPolicy,
                onTap: () => setState(() => _privacyPolicy = !_privacyPolicy),
                onTapTerm: () => _openWebView(
                  context.l10n.termsPrivacyAgree,
                  'https://chiseled-cow-85a.notion.site/ArtTrip-2ccbd56ec2ac8075b2e5dfa195f16bba',
                ),
              ),
              SizedBox(height: 16.h),
              _buildTermRow(
                label: context.l10n.termsMarketingAgree,
                checked: _locationService,
                onTap: () =>
                    setState(() => _locationService = !_locationService),
                onTapTerm: () => _openWebView(
                  context.l10n.termsMarketingAgree,
                  'https://chiseled-cow-85a.notion.site/ArtTrip-35dbd56ec2ac802db6a0eca6a8b81cb9',
                ),
              ),
              SizedBox(height: 40.h),
              _buildNextButton(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      spacing: 24.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(AppAssets.icLogoPurple, width: 188.w, height: 59.h),
        ArtTripText.pretendard()
            .headline()
            .fontWeight(FontWeight.bold)
            .build()
            .text(context.l10n.termsAgreementDescription),
      ],
    );
  }

  Widget _buildAgreeAllRow() {
    return GestureDetector(
      onTap: () => _toggleAll(!_allChecked),
      behavior: HitTestBehavior.opaque,
      child: Row(
        spacing: 8.w,
        children: [
          _buildCheckbox(_allChecked),
          ArtTripText.pretendard().title02Bold().build().text(
            context.l10n.termsAgreeAll,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(color: AppColors.gray100, height: 1.h, thickness: 1.h),
    );
  }

  Widget _buildTermRow({
    required String label,
    required bool checked,
    required VoidCallback onTap,
    required VoidCallback onTapTerm,
  }) {
    return GestureDetector(
      onTap: onTapTerm,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          GestureDetector(onTap: onTap, child: _buildCheckbox(checked)),
          SizedBox(width: 8.w),
          Expanded(
            child: ArtTripText.pretendard()
                .body01Regular()
                .color(AppColors.textPrimary)
                .build()
                .text(label),
          ),
          SvgPicture.asset(AppAssets.icNoArrowRight, width: 24.w, height: 24.w),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool checked) {
    return checked
        ? Icon(
            Icons.check_box_rounded,
            color: AppColors.primary300,
            size: 24.w,
          )
        : Icon(
            Icons.check_box_outlined,
            color: AppColors.textTertiary,
            size: 24.w,
          );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _allChecked ? _onNext : null,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: _allChecked ? AppColors.primary300 : AppColors.gray100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  color: AppColors.textWhite,
                  strokeWidth: 2,
                ),
              )
            : ArtTripText.pretendard()
                  .title02Bold()
                  .color(
                    _allChecked ? AppColors.textWhite : AppColors.textTertiary,
                  )
                  .build()
                  .text(context.l10n.termsNextButton),
      ),
    );
  }
}

class _ErrorOverlay extends StatefulWidget {
  const _ErrorOverlay({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  State<_ErrorOverlay> createState() => _ErrorOverlayState();
}

class _ErrorOverlayState extends State<_ErrorOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onDismiss,
          child: SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 32.w, right: 32.w, bottom: 80.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 24.h,
                    horizontal: 10.w,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: ArtTripText.pretendard()
                      .body01Bold()
                      .color(AppColors.gray0)
                      .textAlign(TextAlign.center)
                      .build()
                      .text(widget.message),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
