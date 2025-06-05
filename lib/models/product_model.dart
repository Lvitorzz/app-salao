class Product {
  String id;
  String name;
  String description;
  double price;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'quantity': quantity,
  };

  factory Product.fromMap(String id, Map<String, dynamic> map) => Product(
    id: id,
    name: map['name'],
    description: map['description'],
    price: map['price'].toDouble(),
    quantity: map['quantity'],
  );
}
