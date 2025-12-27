import 'package:arttrip/features/my/data/models/user_profile_model.dart';
import 'package:arttrip/features/my/data/my_repository.dart';
import 'package:arttrip/shared/widgets/async_view.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class MyViewModel with ChangeNotifier {
  MyViewModel(this._repository);
  final MyRepository _repository;

  AsyncState<UserProfileModel> _profileState = const AsyncState.loading();
  AsyncState<UserProfileModel> get profileState => _profileState;

  Future<void> fetchUserProfile() async {
    _profileState = const AsyncState.loading();
    notifyListeners();

    var profile = await _repository.fetchUserProfile();
    if (profile != null) {
      _profileState = AsyncState.success(profile);
    } else {
      _profileState = const AsyncState.error(error: '프로필을 불러올 수 없습니다.');
    }
    notifyListeners();
  }

  void reset() {
    _profileState = const AsyncState.loading();
    notifyListeners();
    fetchUserProfile();
  }

  Future<bool> uploadProfileImage(XFile image) async {
    var result = await _repository.uploadProfileImage(image);
    if (result) {
      await fetchUserProfile();
    }
    return result;
  }

  Future<bool> deleteProfileImage() async {
    var result = await _repository.deleteProfileImage();
    if (result) {
      await fetchUserProfile();
    }
    return result;
  }
}
