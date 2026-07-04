import '../models/user_model.dart';

void saveClearedFlagImpl(bool isCleared) {
  // No-op on non-web platforms
}

bool getClearedFlagImpl() {
  return false;
}

void saveUserProfileImpl(String uid, UserModel user) {
  // No-op on non-web platforms
}

UserModel? getUserProfileImpl(String uid) {
  return null;
}
