class Client {
  String id;
  String name;
  String phone;
  List<String> productIds;
  List<String> serviceIds;
  String? notes;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    this.productIds = const [],
    this.serviceIds = const [],
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'productIds': productIds,
        'serviceIds': serviceIds,
        'notes': notes,
      };

  factory Client.fromMap(String id, Map<String, dynamic> m) => Client(
        id: id,
        name: m['name'] as String,
        phone: m['phone'] as String,
        productIds: List<String>.from(m['productIds'] ?? []),
        serviceIds: List<String>.from(m['serviceIds'] ?? []),
        notes: m['notes'] as String?,
      );
}
