import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String id;
  String type;       // 'fixed' ou 'variable'
  String category;   // ex: 'Aluguel', 'Compra de produtos', ou texto customizado
  double amount;
  Timestamp createdAt;

  Expense({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'category': category,
        'amount': amount,
        'createdAt': createdAt,
      };

  factory Expense.fromMap(String id, Map<String, dynamic> m) => Expense(
        id: id,
        type: m['type'] as String,
        category: m['category'] as String,
        amount: (m['amount'] as num).toDouble(),
        createdAt: m['createdAt'] as Timestamp,
      );
}
