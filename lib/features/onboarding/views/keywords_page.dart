import 'package:arttrip/features/onboarding/data/models/keyword_model.dart';
import 'package:arttrip/features/onboarding/viewmodels/keywords_viewmodel.dart';
import 'package:arttrip/features/onboarding/widgets/keyword_chip.dart';
import 'package:arttrip/routes/routes.dart';
import 'package:arttrip/shared/utils/snackbar_utils.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// 관심 키워드 선택 페이지
///
/// 신규 사용자(firstLogin: true)가 최초 로그인 시 이동하는 온보딩 화면
class KeywordModelsPage extends StatefulWidget {
  const KeywordModelsPage({super.key});

  @override
  State<KeywordModelsPage> createState() => _KeywordModelsPageState();
}

class _KeywordModelsPageState extends State<KeywordModelsPage> {
  // 색상 상수
  static const _primaryColor = Color(0xFF7859FF);
  static const _textColor = Color(0xFF111111);
  static const _requiredColor = Color(0xFFFF5255);
  static const _disabledBgColor = Color(0xFFDBDBDB);
  static const _disabledTextColor = Color(0xFFA5A5AF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeywordModelsViewModel>().fetchKeywordModels();
    });
  }

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<KeywordModelsViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child:
            vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildDivider(),
                      Expanded(child: _buildContent(vm)),
                      _buildSubmitButton(vm),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 32.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtTripText.pretendard()
              .headline()
              .color(_textColor)
              .build()
              .text('관심있는 키워드를\n골라주세요!'),
          SizedBox(height: 8.h),
          ArtTripText.pretendard()
              .body01Regular()
              .color(_textColor)
              .build()
              .text('한 가지 이상 선택이 가능해요.'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFFDBDBDB), height: 1, thickness: 1);
  }

  Widget _buildContent(KeywordModelsViewModel vm) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: '좋아하는 전시 장르는 무엇인가요?',
            keywords: vm.genres,
            vm: vm,
          ),
          SizedBox(height: 32.h),
          _buildSection(title: '전시 스타일을 골라 주세요', keywords: vm.styles, vm: vm),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<KeywordModel> keywords,
    required KeywordModelsViewModel vm,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              TextSpan(
                text: '*',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: _requiredColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 12.h,
          children:
              keywords.map((keyword) {
                return KeywordModelChip(
                  label: keyword.name,
                  isSelected: vm.isSelected(keyword.keywordId),
                  onTap: () => vm.toggleKeywordModel(keyword.keywordId),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(KeywordModelsViewModel vm) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: vm.canSubmit ? () => _handleSubmit(vm) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: vm.canSubmit ? _primaryColor : _disabledBgColor,
            foregroundColor: vm.canSubmit ? Colors.white : _disabledTextColor,
            disabledBackgroundColor: _disabledBgColor,
            disabledForegroundColor: _disabledTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            elevation: 0,
          ),
          child:
              vm.isSaving
                  ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    '완료',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
        ),
      ),
    );
  }

  // ===== Methods =====

  Future<void> _handleSubmit(KeywordModelsViewModel vm) async {
    var success = await vm.saveKeywordModels();

    if (success) {
      if (mounted) {
        Routes.go(context, '/');
      }
    } else {
      if (mounted) {
        SnackBarUtils.showError(context, message: '키워드 저장에 실패했습니다');
      }
    }
  }
}
