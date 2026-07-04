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
