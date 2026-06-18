import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/complaint_model.dart';
import '../data/repositories/complaint_repository.dart';

final complaintRepositoryProvider = Provider((ref) => ComplaintRepository());

final allComplaintsProvider = FutureProvider<List<ComplaintModel>>((ref) async {
  final repo = ref.watch(complaintRepositoryProvider);
  return repo.getAllComplaints();
});
