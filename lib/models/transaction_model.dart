enum TransactionType { receipt, expense }

class Transaction {
  final String id;
  final TransactionType type;
  final String? subtype;
  final double amount;
  final String description;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    this.subtype,
    required this.amount,
    required this.description,
    required this.date,
  });
}
