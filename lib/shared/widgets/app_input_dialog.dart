import 'package:arttrip/core/app_colors.dart';
import 'package:arttrip/shared/utils/text/arttrip_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 공용 입력 다이얼로그
///
/// 텍스트 입력 필드와 검증 기능을 제공하는 다이얼로그
class AppInputDialog extends StatefulWidget {
  const AppInputDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.cancelText,
    required this.confirmText,
    this.initialValue,
    this.maxLength,
    this.validator,
    this.asyncValidator,
  });

  final String title;
  final String hintText;
  final String cancelText;
  final String confirmText;
  final String? initialValue;
  final int? maxLength;

  /// 동기 검증 함수 - 에러 메시지 반환, null이면 유효
  final String? Function(String value, String? initialValue)? validator;

  /// 비동기 검증 함수 - 에러 메시지 반환, null이면 유효
  final Future<String?> Function(String value)? asyncValidator;

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String hintText,
    required String cancelText,
    required String confirmText,
    String? initialValue,
    int? maxLength,
    String? Function(String value, String? initialValue)? validator,
    Future<String?> Function(String value)? asyncValidator,
  }) {
    return showDialog<String>(
      context: context,
      builder:
          (context) => AppInputDialog(
            title: title,
            hintText: hintText,
            cancelText: cancelText,
            confirmText: confirmText,
            initialValue: initialValue,
            maxLength: maxLength,
            validator: validator,
            asyncValidator: asyncValidator,
          ),
    );
  }

  @override
  State<AppInputDialog> createState() => _AppInputDialogState();
}

class _AppInputDialogState extends State<AppInputDialog> {
  late TextEditingController _controller;
  String? _errorMessage;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  bool get _isInputEmpty => _controller.text.trim().isEmpty;

  bool get _hasValidationError {
    if (widget.validator == null) return false;
    return widget.validator!(_controller.text.trim(), widget.initialValue) !=
        null;
  }

  bool get _canConfirm =>
      !_isInputEmpty &&
      !_hasValidationError &&
      _errorMessage == null &&
      !_isChecking;

  Future<void> _onConfirmPressed() async {
    final value = _controller.text.trim();

    // 동기 검증
    if (widget.validator != null) {
      final error = widget.validator!(value, widget.initialValue);
      if (error != null) {
        setState(() => _errorMessage = error);
        return;
      }
    }

    // 비동기 검증
    if (widget.asyncValidator != null) {
      setState(() => _isChecking = true);
      final error = await widget.asyncValidator!(value);
      setState(() {
        _isChecking = false;
        _errorMessage = error;
      });

      if (error != null) return;
    }

    if (mounted) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.gray0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.only(
          top: 32.w,
          left: 18.w,
          right: 18.w,
          bottom: 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTitle(),
            SizedBox(height: 16.h),
            _buildTextField(),
            if (_errorMessage != null && _errorMessage!.isNotEmpty)
              _buildErrorMessage(),
            SizedBox(height: 28.h),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return ArtTripText.pretendard()
        .title02Bold()
        .color(AppColors.textPrimary)
        .build()
        .text(widget.title);
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      maxLength: widget.maxLength,
      style:
          ArtTripText.pretendard()
              .body01Regular()
              .color(AppColors.textPrimary)
              .build()
              .style(),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle:
            ArtTripText.pretendard()
                .body01Regular()
                .color(AppColors.textTertiary)
                .build()
                .style(),
        counterText: '',
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color:
                _errorMessage != null && _errorMessage!.isNotEmpty
                    ? AppColors.subRed
                    : AppColors.gray100,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color:
                _errorMessage != null && _errorMessage!.isNotEmpty
                    ? AppColors.subRed
                    : AppColors.primary300,
          ),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ArtTripText.pretendard()
            .body02Light()
            .color(AppColors.subRed)
            .build()
            .text(_errorMessage!),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.gray0,
                border: Border.all(color: const Color(0xFFDBDBDB)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: ArtTripText.pretendard()
                  .body01Bold()
                  .color(AppColors.textPrimary)
                  .build()
                  .text(widget.cancelText),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: _canConfirm ? _onConfirmPressed : null,
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color:
                    _canConfirm ? AppColors.primary300 : AppColors.primary100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child:
                  _isChecking
                      ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.gray0,
                        ),
                      )
                      : ArtTripText.pretendard()
                          .body01Bold()
                          .color(AppColors.gray0)
                          .build()
                          .text(widget.confirmText),
            ),
          ),
        ),
      ],
    );
  }
}
