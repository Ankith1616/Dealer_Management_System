// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:html' as html;
import '../models/user_model.dart';

void saveClearedFlagImpl(bool isCleared) {
  html.window.localStorage['visitor_logs_cleared'] = isCleared.toString();
}

bool getClearedFlagImpl() {
  return html.window.localStorage['visitor_logs_cleared'] == 'true';
}

void saveUserProfileImpl(String uid, UserModel user) {
  html.window.localStorage['user_profile_$uid'] = json.encode(user.toMap());
}

UserModel? getUserProfileImpl(String uid) {
  final data = html.window.localStorage['user_profile_$uid'];
  if (data == null) return null;
  try {
    return UserModel.fromMap(json.decode(data) as Map<String, dynamic>);
  } catch (e) {
    return null;
  }
}

void saveMockUsersImpl(Map<String, UserModel> users) {
  final Map<String, dynamic> data = {};
  users.forEach((key, value) {
    data[key] = value.toMap();
  });
  html.window.localStorage['mock_users_db'] = json.encode(data);
}

Map<String, UserModel> getMockUsersImpl() {
  final data = html.window.localStorage['mock_users_db'];
  if (data == null) return {};
  try {
    final decoded = json.decode(data) as Map<String, dynamic>;
    final Map<String, UserModel> result = {};
    decoded.forEach((key, value) {
      result[key] = UserModel.fromMap(value as Map<String, dynamic>);
    });
    return result;
  } catch (e) {
    return {};
  }
}

void saveMockPasswordsImpl(Map<String, String> passwords) {
  html.window.localStorage['mock_passwords_db'] = json.encode(passwords);
}

Map<String, String> getMockPasswordsImpl() {
  final data = html.window.localStorage['mock_passwords_db'];
  if (data == null) return {};
  try {
    final decoded = json.decode(data) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value.toString()));
  } catch (e) {
    return {};
  }
}
