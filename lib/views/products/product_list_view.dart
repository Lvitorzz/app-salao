// lib/views/product/product_list_view.dart
import 'package:flutter/material.dart';
import 'package:gestao_salao/controllers/product_controller.dart';
import 'package:gestao_salao/models/product_model.dart';
import '../../widgets/app_header.dart';
import 'product_form_view.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({Key? key}) : super(key: key);

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final ProductController _controller = ProductController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF732027),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Produtos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _controller.allProducts,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar',
                style: TextStyle(color: Color(0xFF591E18)),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final produtos = snap.data!;
          if (produtos.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum produto',
                style: TextStyle(color: Color(0xFF591E18)),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: produtos.length,
            itemBuilder: (context, i) {
              final p = produtos[i];
              return _ProductCard(
                product: p,
                onDecrement: () {
                  if (p.quantity > 0) _controller.updateStock(p.id, p.quantity - 1);
                },
                onIncrement: () => _controller.updateStock(p.id, p.quantity + 1),
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductFormView(product: p)),
                ),
                onDelete: () => _confirmDelete(p),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF732027),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductFormView()),
        ),
      ),
    );
  }

  void _confirmDelete(Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: Text('Deseja excluir "${p.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              _controller.delete(p.id);
              Navigator.pop(context);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    Key? key,
    required this.product,
    required this.onDecrement,
    required this.onIncrement,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF2D4C2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone do produto
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2E7C4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.inventory_2, color: Color(0xFF732027), size: 28),
            ),
            const SizedBox(width: 16),
            // Detalhes em coluna
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF591E18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantidade em estoque
                  Row(
                    children: [
                      const Icon(Icons.storage, size: 16, color: Color(0xFF591E18)),
                      const SizedBox(width: 4),
                      Text(
                        '${product.quantity} em estoque',
                        style: const TextStyle(color: Color(0xFF591E18)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Preço
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, size: 16, color: Color(0xFF591E18)),
                      const SizedBox(width: 4),
                      Text(
                        'R\$ ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Color(0xFF591E18)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Ações
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: const Color(0xFF591E18),
                  onPressed: product.quantity > 0 ? onDecrement : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF591E18),
                  onPressed: onIncrement,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF732027)),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
