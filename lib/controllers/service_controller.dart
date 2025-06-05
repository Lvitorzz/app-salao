import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceController {
  final _svc = ServiceService();
  Stream<List<Service>> get allServices => _svc.getAll();
  Future<void> add(Service s) => _svc.add(s);
  Future<void> update(Service s) => _svc.update(s);
  Future<void> delete(String id) => _svc.delete(id);
}
