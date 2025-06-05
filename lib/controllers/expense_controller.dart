import '../models/expense_model.dart';
import '../services/expense_service.dart';

class ExpenseController {
  final _svc = ExpenseService();

  Future<void> add(Expense e)    => _svc.add(e);
  Future<void> update(Expense e) => _svc.update(e);
  Future<void> delete(String id) => _svc.delete(id);
  Stream<List<Expense>> get allExpenses => _svc.getAll();
}
