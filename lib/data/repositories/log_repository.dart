import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/visit_log_model.dart';

final logRepositoryProvider = Provider((ref) => LogRepository());

final visitLogsProvider = StreamProvider.autoDispose<List<VisitLogModel>>((ref) {
  return ref.watch(logRepositoryProvider).getVisitLogs();
});

class LogRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  // Local/memory fallback list of logs to guarantee local mock profiles work
  static final List<VisitLogModel> _localLogs = [
    VisitLogModel(
      uid: 'dealer_1',
      displayName: 'Vasavi Traders',
      email: 'vasavitraders2004@gmail.com',
      phoneNumber: '9876543211',
      role: 'dealer',
      visitCount: 29,
      lastVisited: DateTime.now().subtract(const Duration(seconds: 15)),
    ),
    VisitLogModel(
      uid: 'user_ankith',
      displayName: 'Ankith',
      phoneNumber: '6301211601',
      role: 'customer',
      visitCount: 5,
      lastVisited: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    VisitLogModel(
      uid: 'user_ankith',
      displayName: 'Ankith',
      phoneNumber: '6301211601',
      role: 'customer',
      visitCount: 5,
      lastVisited: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    VisitLogModel(
      uid: 'user_1',
      displayName: 'John Doe',
      email: 'customer@test.com',
      phoneNumber: '9876543210',
      role: 'customer',
      visitCount: 3,
      lastVisited: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    VisitLogModel(
      uid: 'user_ankith_p',
      displayName: 'Ankith P',
      email: 'ankith133079@gmail.com',
      phoneNumber: '1234567890',
      role: 'customer',
      visitCount: 3,
      lastVisited: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    VisitLogModel(
      uid: 'user_ankith',
      displayName: 'Ankith',
      phoneNumber: '6301211601',
      role: 'customer',
      visitCount: 2,
      lastVisited: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    VisitLogModel(
      uid: 'user_ankith',
      displayName: 'Ankith',
      phoneNumber: '6301211601',
      role: 'customer',
      visitCount: 1,
      lastVisited: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    VisitLogModel(
      uid: 'user_ankith',
      displayName: 'Ankith',
      phoneNumber: '6301211601',
      role: 'customer',
      visitCount: 1,
      lastVisited: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    VisitLogModel(
      uid: 'user_ankith_2',
      displayName: 'Ankith',
      phoneNumber: '6601211601',
      role: 'customer',
      visitCount: 1,
      lastVisited: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  Future<void> logVisit(UserModel user) async {
    final now = DateTime.now();

    // 1. Calculate next visitCount locally
    final userLogs = _localLogs.where((log) => log.uid == user.uid);
    final nextVisitCount = userLogs.isEmpty 
        ? 1 
        : userLogs.map((l) => l.visitCount).reduce((a, b) => a > b ? a : b) + 1;

    // Add new log to local cache
    _localLogs.add(
      VisitLogModel(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        phoneNumber: user.phoneNumber,
        role: user.role,
        visitCount: nextVisitCount,
        lastVisited: now,
      ),
    );

    // Keep only top 100 in local cache
    _localLogs.sort((a, b) => b.lastVisited.compareTo(a.lastVisited));
    if (_localLogs.length > 100) {
      _localLogs.removeRange(100, _localLogs.length);
    }

    // 2. Sync to Firestore (asynchronous, doesn't block the UI)
    final firestore = _firestore;
    if (firestore == null) {
      debugPrint('Firestore is not initialized. Running in local fallback mode.');
      return;
    }
    try {
      // Find the next visitCount from Firestore
      final querySnap = await firestore
          .collection('visit_logs')
          .where('uid', isEqualTo: user.uid)
          .get();
      int maxCount = 0;
      for (final doc in querySnap.docs) {
        final count = doc.data()['visitCount'] as int? ?? 0;
        if (count > maxCount) {
          maxCount = count;
        }
      }
      final dbVisitCount = maxCount + 1;

      // Add as a new document
      await firestore.collection('visit_logs').add({
        'uid': user.uid,
        'displayName': user.displayName,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'role': user.role,
        'visitCount': dbVisitCount,
        'lastVisited': FieldValue.serverTimestamp(),
      });

      // Keep only top 100 in Firestore
      final firestoreSnap = await firestore
          .collection('visit_logs')
          .orderBy('lastVisited', descending: true)
          .get();
      if (firestoreSnap.docs.length > 100) {
        final batch = firestore.batch();
        for (int i = 100; i < firestoreSnap.docs.length; i++) {
          batch.delete(firestoreSnap.docs[i].reference);
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Firestore logVisit error: $e');
    }
  }

  Future<void> clearVisitLogs() async {
    _localLogs.clear();
    final firestore = _firestore;
    if (firestore == null) {
      return;
    }
    try {
      final snap = await firestore.collection('visit_logs').get();
      final batch = firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore clearVisitLogs error: $e');
    }
  }

  Stream<List<VisitLogModel>> getVisitLogs() {
    final firestore = _firestore;
    if (firestore == null) {
      final list = List<VisitLogModel>.from(_localLogs);
      list.sort((a, b) => b.lastVisited.compareTo(a.lastVisited));
      return Stream.value(list.take(100).toList());
    }
    // Listen to Firestore, and merge with the local logs (avoiding duplicates)
    return firestore
        .collection('visit_logs')
        .snapshots()
        .map((snapshot) {
      final firestoreLogs = snapshot.docs
          .map((doc) => VisitLogModel.fromMap(doc.data()))
          .toList();

      final Map<String, VisitLogModel> uniqueLogsMap = {};
      
      for (final log in _localLogs) {
        final key = '${log.uid}_${log.lastVisited.millisecondsSinceEpoch}';
        uniqueLogsMap[key] = log;
      }
      for (final log in firestoreLogs) {
        final key = '${log.uid}_${log.lastVisited.millisecondsSinceEpoch}';
        uniqueLogsMap[key] = log;
      }

      final list = uniqueLogsMap.values.toList();
      list.sort((a, b) => b.lastVisited.compareTo(a.lastVisited));
      return list.take(100).toList();
    });
  }
}

