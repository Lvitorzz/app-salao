import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController {
  final _service = ProductService();

  Stream<List<Product>> get allProducts => _service.getProducts();

  Future<void> add(Product product) => _service.addProduct(product);

  Future<void> update(Product product) => _service.updateProduct(product);

  Future<void> delete(String id) => _service.deleteProduct(id);

  Future<void> updateStock(String id, int quantity) =>
      _service.updateStock(id, quantity);
}
