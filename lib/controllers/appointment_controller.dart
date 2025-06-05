import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentController {
  final _svc = AppointmentService();

  Future<void> add(Appointment a) => _svc.add(a);
  Future<void> update(Appointment a) => _svc.update(a);
  Future<void> delete(String id) => _svc.delete(id);
  Stream<List<Appointment>> get allAppointments => _svc.getAll();
}
