import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final _col = FirebaseFirestore.instance.collection('expenses');

  Future<void> add(Expense e) => _col.add(e.toMap());

  Future<void> update(Expense e) => _col.doc(e.id).update(e.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();

  Stream<List<Expense>> getAll() {
    return _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
        .map((d) => Expense.fromMap(d.id, d.data()))
        .toList());
  }
}
