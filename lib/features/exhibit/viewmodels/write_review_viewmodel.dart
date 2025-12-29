import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// 리뷰 작성 ViewModel
class WriteReviewViewModel with ChangeNotifier {
  WriteReviewViewModel(this._repository);
  final ExhibitRepository _repository;

  // === State ===
  DateTime? _visitDate;
  String _content = '';
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  // === Getters ===
  DateTime? get visitDate => _visitDate;
  String get content => _content;
  List<XFile> get selectedImages => List.unmodifiable(_selectedImages);
  bool get isSubmitting => _isSubmitting;
  int get contentLength => _content.length;

  /// 제출 가능 여부: 방문일 + 리뷰 텍스트 필수
  bool get canSubmit =>
      _visitDate != null && _content.trim().isNotEmpty && !_isSubmitting;

  /// 이미지 추가 가능 여부
  bool get canAddImage => _selectedImages.length < maxImageCount;

  /// 최대 글자수
  static const int maxContentLength = 500;

  /// 최대 이미지 개수
  static const int maxImageCount = 4;

  // === Actions ===

  /// 방문일 설정
  void setVisitDate(DateTime date) {
    _visitDate = date;
    notifyListeners();
  }

  /// 리뷰 내용 설정
  void setContent(String value) {
    if (value.length <= maxContentLength) {
      _content = value;
      notifyListeners();
    }
  }

  /// 이미지 추가
  void addImages(List<XFile> images) {
    var remainingSlots = maxImageCount - _selectedImages.length;
    var imagesToAdd = images.take(remainingSlots).toList();
    _selectedImages.addAll(imagesToAdd);
    notifyListeners();
  }

  /// 이미지 삭제
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  /// 상태 초기화 (모달 열릴 때 호출)
  void reset() {
    _visitDate = null;
    _content = '';
    _selectedImages.clear();
    _isSubmitting = false;
    notifyListeners();
  }

  /// 리뷰 제출
  Future<bool> submitReview(int exhibitId) async {
    if (!canSubmit) return false;

    _isSubmitting = true;
    notifyListeners();

    try {
      var dateStr = DateFormat('yyyy-MM-dd').format(_visitDate!);
      var result = await _repository.createReview(
        exhibitId: exhibitId,
        images: _selectedImages,
        date: dateStr,
        content: _content.trim(),
      );

      _isSubmitting = false;
      notifyListeners();

      return result != null;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
