// lib/controllers/receipt_controller.dart
import '../models/receipt_model.dart';
import '../services/receipt_service.dart';

class ReceiptController {
  final _svc = ReceiptService();

  Future<void> add(Receipt r)    => _svc.add(r);
  Future<void> update(Receipt r) => _svc.update(r);
  Future<void> delete(String id) => _svc.delete(id);
  Stream<List<Receipt>> get allReceipts => _svc.getAll();
  Future<Receipt> getById(String id) => _svc.getById(id);
}
