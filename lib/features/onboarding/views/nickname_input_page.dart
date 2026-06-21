import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/core/config/prefs.dart';
import 'package:arttrip/core/enum.dart';
import 'package:arttrip/core/extensions.dart';
import 'package:arttrip/features/my/viewmodels/my_viewmodel.dart';
import 'package:arttrip/routes/app_routes.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 온보딩 1/2: 닉네임 입력 페이지
class NicknameInputPage extends StatefulWidget {
  const NicknameInputPage({super.key});

  @override
  State<NicknameInputPage> createState() => _NicknameInputPageState();
}

class _NicknameInputPageState extends State<NicknameInputPage> {
  static const int _maxLength = 10;

  final TextEditingController _controller = TextEditingController();
  String _nickname = '';
  String? _errorMessage;
  bool _isSubmitting = false;

  /// 영문/숫자/한글 1자 이상 포함 (특수기호만으로는 불가)
  static final RegExp _allowedPattern = RegExp(r'[A-Za-z0-9가-힣]');

  bool get _isValid =>
      _nickname.isNotEmpty &&
      _nickname.length <= _maxLength &&
      _allowedPattern.hasMatch(_nickname);

  bool get _canSubmit => _isValid && !_isSubmitting;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              SizedBox(height: 40.h),
              _buildStepIndicator(),
              SizedBox(height: 16.h),
              _buildHeader(),
              SizedBox(height: 24.h),
              _buildTextField(),
              if (_errorMessage != null) ...[
                SizedBox(height: 8.h),
                _buildErrorMessage(),
              ],
              const Spacer(),
              _buildNextButton(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return ArtTripText.pretendard()
        .body01Bold()
        .color(AppColors.textPrimary)
        .build()
        .text(context.l10n.stepIndicator(1, 2));
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: 8.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtTripText.pretendard()
              .headline()
              .color(AppColors.textPrimary)
              .build()
              .text(context.l10n.nicknameInputTitle),
          SizedBox(height: 8.h),
          ArtTripText.pretendard()
              .body01Light()
              .color(AppColors.textPrimary)
              .build()
              .text(context.l10n.nicknameInputDescription),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    final hasError = _errorMessage != null;
    return TextField(
      controller: _controller,
      maxLength: _maxLength,
      onChanged: _onChanged,
      style: ArtTripText.pretendard()
          .body01Regular()
          .color(AppColors.textPrimary)
          .build()
          .style(),
      decoration: InputDecoration(
        hintText: context.l10n.nicknameInputPlaceholder,
        hintStyle: ArtTripText.pretendard()
            .body01Regular()
            .color(AppColors.textTertiary)
            .build()
            .style(),
        counterText: '',
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        enabledBorder: _border(hasError ? AppColors.subRed : AppColors.gray100),
        focusedBorder: _border(hasError ? AppColors.subRed : AppColors.gray100),
        disabledBorder: _border(AppColors.gray100),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: color),
    );
  }

  Widget _buildErrorMessage() {
    return ArtTripText.pretendard()
        .body02Light()
        .color(AppColors.subRed)
        .build()
        .text(_errorMessage!);
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _canSubmit ? _onSubmit : null,
      child: Container(
        width: double.infinity,
        height: 52.h,
        decoration: BoxDecoration(
          color: _canSubmit ? AppColors.primary300 : AppColors.gray100,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: _isSubmitting
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
                    _canSubmit ? AppColors.textWhite : AppColors.textTertiary,
                  )
                  .build()
                  .text(context.l10n.nextButton),
      ),
    );
  }

  void _onChanged(String value) {
    setState(() {
      _nickname = value;
      // 텍스트 변경 시 에러 메시지 초기화 (사용자가 수정 중)
      if (_errorMessage != null) _errorMessage = null;
    });
  }

  Future<void> _onSubmit() async {
    setState(() => _isSubmitting = true);

    final errorMessage = await context.read<MyViewModel>().updateNickname(
      _nickname,
    );

    if (!mounted) return;

    if (errorMessage == null) {
      await Prefs().setOnboardingStep(OnboardingStep.keyword);
      if (!mounted) return;
      await Routes.replace(context, AppRoutes.onboardingKeywords);
      return;
    }

    setState(() {
      _errorMessage = errorMessage;
      _isSubmitting = false;
    });
  }
}
