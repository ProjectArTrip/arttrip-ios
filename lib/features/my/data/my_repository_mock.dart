import 'package:arttrip/features/my/data/models/user_profile_model.dart';
import 'package:arttrip/features/my/data/my_repository.dart';
import 'package:image_picker/image_picker.dart';

class MyRepositoryMockImpl implements MyRepository {
  @override
  Future<UserProfileModel?> fetchUserProfile({
    int width = 100,
    int height = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const UserProfileModel(nickName: '이유지', profileImage: null);
  }

  @override
  Future<bool> uploadProfileImage(XFile image) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> deleteProfileImage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
