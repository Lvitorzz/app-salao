import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceService {
  final _col = FirebaseFirestore.instance.collection('services');

  Future<void> add(Service s) => _col.add(s.toMap());

  Future<void> update(Service s) => _col.doc(s.id).update(s.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();

  Stream<List<Service>> getAll() => _col.snapshots().map((snap) =>
      snap.docs.map((d) => Service.fromMap(d.id, d.data())).toList());
}