// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

void saveClearedFlagImpl(bool isCleared) {
  html.window.localStorage['visitor_logs_cleared'] = isCleared.toString();
}

bool getClearedFlagImpl() {
  return html.window.localStorage['visitor_logs_cleared'] == 'true';
}
