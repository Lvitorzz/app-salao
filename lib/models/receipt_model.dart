import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  ReceiptItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
      };
}

class Receipt {
  final String id;
  final String type;
  final List<ReceiptItem> items;
  final String? description;
  final double total;
  final Timestamp createdAt;

  Receipt({
    required this.id,
    required this.type,
    required this.items,
    this.description,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'items': items.map((i) => i.toMap()).toList(),
        'description': description,
        'total': total,
        'createdAt': createdAt,
      };
}
