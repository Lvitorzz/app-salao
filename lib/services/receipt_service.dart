// lib/services/receipt_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/receipt_model.dart';

class ReceiptService {
  final _col = FirebaseFirestore.instance.collection('receipts');

  Future<void> add(Receipt r) async {
    await _col.add(r.toMap());
  }

  Future<void> update(Receipt r) async {
    await _col.doc(r.id).update(r.toMap());
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  Stream<List<Receipt>> getAll() {
    return _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) {
            final data = d.data();
            final items = (data['items'] as List<dynamic>)
                .map((e) => ReceiptItem(
                      id: e['id'] as String,
                      name: e['name'] as String,
                      price: (e['price'] as num).toDouble(),
                      quantity: (e['quantity'] as num).toInt(),
                    ))
                .toList();
            return Receipt(
              id: d.id,
              type: data['type'] as String,
              items: items,
              description: data['description'] as String?,
              total: (data['total'] as num).toDouble(),
              createdAt: data['createdAt'] as Timestamp,
            );
          }).toList());
  }

  Future<Receipt> getById(String id) async {
    final doc = await _col.doc(id).get();
    final data = doc.data() as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>)
        .map((e) => ReceiptItem(
              id: e['id'] as String,
              name: e['name'] as String,
              price: (e['price'] as num).toDouble(),
              quantity: (e['quantity'] as num).toInt(),
            ))
        .toList();
    return Receipt(
      id: doc.id,
      type: data['type'] as String,
      items: items,
      description: data['description'] as String?,
      total: (data['total'] as num).toDouble(),
      createdAt: data['createdAt'] as Timestamp,
    );
  }
}
