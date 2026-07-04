import 'local_storage_helper_non_web.dart'
    if (dart.library.html) 'local_storage_helper_web.dart';
import '../models/user_model.dart';

class LocalStorageHelper {
  static void saveClearedFlag(bool isCleared) {
    saveClearedFlagImpl(isCleared);
  }

  static bool getClearedFlag() {
    return getClearedFlagImpl();
  }

  static void saveUserProfile(String uid, UserModel user) {
    saveUserProfileImpl(uid, user);
  }

  static UserModel? getUserProfile(String uid) {
    return getUserProfileImpl(uid);
  }
}
