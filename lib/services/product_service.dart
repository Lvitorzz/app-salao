import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(Product product) async {
    await _products.add(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _products.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  Stream<List<Product>> getProducts() {
    return _products.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) =>
        Product.fromMap(doc.id, doc.data() as Map<String, dynamic>)
      ).toList()
    );
  }

  Future<void> updateStock(String id, int newQuantity) async {
    await _products.doc(id).update({'quantity': newQuantity});
  }
}