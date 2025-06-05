class Service {
  String id;
  String name;
  double price;

  Service({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
      };

  factory Service.fromMap(String id, Map<String, dynamic> m) => Service(
        id: id,
        name: m['name'] as String,
        price: (m['price'] as num).toDouble(),
      );
}
