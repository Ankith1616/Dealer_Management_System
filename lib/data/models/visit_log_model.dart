import 'package:cloud_firestore/cloud_firestore.dart';

class VisitLogModel {
  final String uid;
  final String displayName;
  final String? email;
  final String phoneNumber;
  final String role;
  final int visitCount;
  final DateTime lastVisited;

  VisitLogModel({
    required this.uid,
    required this.displayName,
    this.email,
    required this.phoneNumber,
    required this.role,
    required this.visitCount,
    required this.lastVisited,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'visitCount': visitCount,
      'lastVisited': lastVisited.toIso8601String(),
    };
  }

  factory VisitLogModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) {
        return val.toDate();
      } else if (val is String) {
        return DateTime.parse(val);
      } else if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      }
      return DateTime.now();
    }

    return VisitLogModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? 'Unknown User',
      email: map['email'],
      phoneNumber: map['phoneNumber'] ?? '',
      role: map['role'] ?? 'customer',
      visitCount: map['visitCount'] ?? 1,
      lastVisited: parseDateTime(map['lastVisited']),
    );
  }
}
