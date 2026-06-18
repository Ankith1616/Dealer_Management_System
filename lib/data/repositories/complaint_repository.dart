import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/complaint_model.dart';

class ComplaintRepository {
  final _db = FirebaseFirestore.instance;

  Future<List<ComplaintModel>> getAllComplaints() async {
    final snap = await _db.collection('complaints').get();
    var list = snap.docs.map((doc) => ComplaintModel.fromMap(doc.data())).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<ComplaintModel> submitComplaint(ComplaintModel complaint) async {
    await _db.collection('complaints').doc(complaint.id).set(complaint.toMap());
    return complaint;
  }

  Future<void> replyToComplaint(String id, String reply) async {
    await _db.collection('complaints').doc(id).update({
      'reply': reply,
      'replyAt': DateTime.now().toIso8601String(),
      'status': 'Resolved',
    });
  }
}
