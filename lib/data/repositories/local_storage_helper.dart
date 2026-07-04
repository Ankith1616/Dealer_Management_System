import 'local_storage_helper_non_web.dart'
    if (dart.library.html) 'local_storage_helper_web.dart';

class LocalStorageHelper {
  static void saveClearedFlag(bool isCleared) {
    saveClearedFlagImpl(isCleared);
  }

  static bool getClearedFlag() {
    return getClearedFlagImpl();
  }
}
