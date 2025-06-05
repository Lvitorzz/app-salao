import 'dart:async';
import '../models/transaction_model.dart';
import 'receipt_controller.dart';
import 'expense_controller.dart';

class TransactionController {
  final _rc = ReceiptController();
  final _ec = ExpenseController();
  final _ctrl = StreamController<List<Transaction>>.broadcast();
  final List<Transaction> _txs = [];

  TransactionController() {
    _rc.allReceipts.listen((rs) {
      _txs.removeWhere((t) => t.type == TransactionType.receipt);
      for (var r in rs) {
        final desc = r.description ??
            r.items.map((i) => '${i.name}×${i.quantity}').join(', ');
        _txs.add(Transaction(
          id: r.id,
          type: TransactionType.receipt,
          subtype: r.type,       // aqui
          amount: r.total,
          description: desc,
          date: r.createdAt.toDate(),
        ));
      }
      _emit();
    });
    _ec.allExpenses.listen((es) {
      _txs.removeWhere((t) => t.type == TransactionType.expense);
      for (var e in es) {
        _txs.add(Transaction(
          id: e.id,
          type: TransactionType.expense,
          subtype: null,
          amount: e.amount,
          description: e.category,
          date: e.createdAt.toDate(),
        ));
      }
      _emit();
    });
  }

  void _emit() {
    final sorted = [..._txs]..sort((a, b) => b.date.compareTo(a.date));
    _ctrl.add(sorted);
  }

  Stream<List<Transaction>> get allTransactions => _ctrl.stream;
  void dispose() => _ctrl.close();
}
