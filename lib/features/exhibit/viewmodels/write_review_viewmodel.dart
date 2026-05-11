import 'package:arttrip/features/exhibit/data/exhibit_repository.dart';
import 'package:arttrip/features/exhibit/data/models/review_create_result.dart';
import 'package:arttrip/features/exhibit/data/models/review_submit_result.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

/// 리뷰 작성/수정 ViewModel
class WriteReviewViewModel with ChangeNotifier {
  WriteReviewViewModel(this._repository);
  final ExhibitRepository _repository;

  // === State ===
  DateTime? _visitDate;
  String _content = '';
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  // === 수정 모드 State ===
  bool _isEditMode = false;
  int? _reviewId;
  final List<ReviewImage> _existingImages = [];
  final Set<int> _deleteImageIds = {};
  bool _isLoadingDetail = false;

  // === Getters ===
  DateTime? get visitDate => _visitDate;
  String get content => _content;
  List<XFile> get selectedImages => List.unmodifiable(_selectedImages);
  bool get isSubmitting => _isSubmitting;
  int get contentLength => _content.length;
  bool get isEditMode => _isEditMode;
  bool get isLoadingDetail => _isLoadingDetail;

  /// 기존 이미지 목록 (URL만 반환)
  List<String> get existingPhotoUrls =>
      _existingImages.map((e) => e.imageUrl).toList();

  /// 기존 이미지가 삭제 대상인지 확인
  bool isExistingImageDeleted(int index) {
    if (index >= _existingImages.length) return false;
    return _deleteImageIds.contains(_existingImages[index].reviewImageId);
  }

  /// 표시 중인 기존 이미지 수 (삭제 예정 제외)
  int get _activeExistingImageCount =>
      _existingImages.length - _deleteImageIds.length;

  /// 제출 가능 여부: 방문일 + 리뷰 텍스트 필수
  bool get canSubmit =>
      _visitDate != null &&
      _content.trim().length >= minContentLength &&
      !_isSubmitting;

  /// 이미지 추가 가능 여부
  bool get canAddImage =>
      _activeExistingImageCount + _selectedImages.length < maxImageCount;

  /// 최소 글자수
  static const int minContentLength = 20;

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
    final remainingSlots =
        maxImageCount - _activeExistingImageCount - _selectedImages.length;
    final imagesToAdd = images.take(remainingSlots).toList();
    _selectedImages.addAll(imagesToAdd);
    notifyListeners();
  }

  /// 새 이미지 삭제
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  /// 기존 이미지 삭제 표시 (reviewImageId로 삭제)
  void removeExistingImage(int index) {
    if (index >= 0 && index < _existingImages.length) {
      _deleteImageIds.add(_existingImages[index].reviewImageId);
      notifyListeners();
    }
  }

  /// 상태 초기화 (신규 작성 모드)
  void reset({bool notify = true}) {
    _visitDate = null;
    _content = '';
    _selectedImages.clear();
    _isSubmitting = false;
    _isEditMode = false;
    _reviewId = null;
    _existingImages.clear();
    _deleteImageIds.clear();
    _isLoadingDetail = false;
    if (notify) notifyListeners();
  }

  /// 수정 모드 초기화 - API로 리뷰 상세 조회
  Future<void> initForEdit({required int reviewId}) async {
    reset(notify: false);
    _isEditMode = true;
    _reviewId = reviewId;
    _isLoadingDetail = true;
    notifyListeners();

    final detail = await _repository.fetchReviewDetail(reviewId);
    if (detail != null) {
      _content = detail.content;
      _existingImages.addAll(detail.images);

      try {
        _visitDate = DateFormat('yyyy-MM-dd').parse(detail.visitDate);
      } catch (_) {}
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  /// 리뷰 제출 (신규)
  Future<ReviewSubmitResult> submitReview(int exhibitId) async {
    if (!canSubmit) return ReviewSubmitResult.failure;

    _isSubmitting = true;
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_visitDate!);
      final result = await _repository.createReview(
        exhibitId: exhibitId,
        images: _selectedImages,
        date: dateStr,
        content: _content.trim(),
      );

      _isSubmitting = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return ReviewSubmitResult.failure;
    }
  }

  /// 리뷰 수정
  Future<ReviewSubmitResult> updateReview() async {
    if (!canSubmit || _reviewId == null) return ReviewSubmitResult.failure;

    _isSubmitting = true;
    notifyListeners();

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_visitDate!);
      final result = await _repository.updateReview(
        reviewId: _reviewId!,
        newImages: _selectedImages,
        date: dateStr,
        content: _content.trim(),
        deleteImageIds: _deleteImageIds.toList(),
      );

      _isSubmitting = false;
      notifyListeners();

      return result;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return ReviewSubmitResult.failure;
    }
  }
}
