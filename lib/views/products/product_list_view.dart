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
      appBar:const AppHeader(
        title: 'Produtos',
        imageUrl: 'https://seu_servidor.com/avatar.jpg',
        // onProfileTap: () => Navigator.pushNamed(context, '/perfil'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: _controller.allProducts,
        builder: (ctx, snap) {
          if (snap.hasError) return const Center(child: Text('Erro ao carregar'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final produtos = snap.data!;
          if (produtos.isEmpty) return const Center(child: Text('Nenhum produto'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemCount: produtos.length,
            itemBuilder: (_, i) {
              final p = produtos[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Qtd: ${p.quantity}   R\$ ${p.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: p.quantity > 0
                          ? () => _controller.updateStock(p.id, p.quantity - 1)
                          : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => _controller.updateStock(p.id, p.quantity + 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductFormView(product: p),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(p),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/form'),
      ),
    );
  }

  void _confirmDelete(Product p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: Text('Excluir "${p.name}"?'),
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
