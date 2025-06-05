import '../models/client_model.dart';
import '../services/client_service.dart';

class ClientController {
  final _svc = ClientService();

  Stream<List<Client>> get allClients => _svc.getAll();
  Future<void> add(Client c)    => _svc.add(c);
  Future<void> update(Client c) => _svc.update(c);
  Future<void> delete(String id)=> _svc.delete(id);
}
