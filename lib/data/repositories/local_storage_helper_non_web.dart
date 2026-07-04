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

void saveMockUsersImpl(Map<String, UserModel> users) {
  // No-op on non-web platforms
}

Map<String, UserModel> getMockUsersImpl() {
  return {};
}

void saveMockPasswordsImpl(Map<String, String> passwords) {
  // No-op on non-web platforms
}

Map<String, String> getMockPasswordsImpl() {
  return {};
}
