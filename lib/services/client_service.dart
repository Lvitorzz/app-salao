import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client_model.dart';

class ClientService {
  final _col = FirebaseFirestore.instance.collection('clients');

  Future<void> add(Client c) => _col.add(c.toMap());

  Future<void> update(Client c) => _col.doc(c.id).update(c.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();

  Stream<List<Client>> getAll() => _col.snapshots().map((snap) =>
      snap.docs.map((d) => Client.fromMap(d.id, d.data())).toList());
}
