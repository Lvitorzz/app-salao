import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final _col = FirebaseFirestore.instance.collection('appointments');

  Future<void> add(Appointment a) => _col.add(a.toMap());

  Future<void> update(Appointment a) =>
      _col.doc(a.id).update(a.toMap());

  Future<void> delete(String id) => _col.doc(id).delete();

  Stream<List<Appointment>> getAll() {
    return _col
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Appointment.fromMap(d.id, d.data()))
            .toList());
  }
}
