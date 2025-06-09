// lib/views/client/client_list_view.dart
import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../controllers/client_controller.dart';
import '../../models/client_model.dart';
import '../../models/product_model.dart';
import '../../models/service_model.dart';
import '../../services/product_service.dart';
import '../../services/service_service.dart';
import 'client_form_view.dart';

class ClientListView extends StatefulWidget {
  const ClientListView({Key? key}) : super(key: key);

  @override
  _ClientListViewState createState() => _ClientListViewState();
}

class _ClientListViewState extends State<ClientListView> {
  final ctl = ClientController();
  final _prodSvc = ProductService();
  final _servSvc = ServiceService();

  Future<void> _confirmDelete(Client c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir o cliente "${c.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Não')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sim'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ctl.delete(c.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente excluído')),
      );
    }
  }

  void _showClientDetails(Client c) {
    final notesText = (c.notes != null && c.notes!.isNotEmpty) ? c.notes! : '- Nenhuma';

    showDialog(
      context: context,
      builder: (_) => FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _prodSvc.getProducts().first, // Future<List<Product>>
          _servSvc.getAll().first,      // Future<List<Service>>
        ]),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return AlertDialog(
              title: const Text('Erro carregando detalhes'),
              content: Text(snap.error.toString()),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
              ],
            );
          }

          final allProducts = snap.data![0] as List<Product>;
          final allServices = snap.data![1] as List<Service>;
          final clientProducts = allProducts.where((p) => c.productIds.contains(p.id)).toList();
          final clientServices = allServices.where((s) => c.serviceIds.contains(s.id)).toList();

          return AlertDialog(
            backgroundColor: const Color(0xFFF2D4C2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              c.name,
              style: const TextStyle(color: Color(0xFF591E18), fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Telefone: ${c.phone}', style: const TextStyle(color: Color(0xFF591E18))),
                  const SizedBox(height: 8),
                  const Text('Observações:',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF732027))),
                  Text(notesText, style: const TextStyle(color: Color(0xFF591E18))),
                  const SizedBox(height: 12),
                  const Text('Produtos:',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF732027))),
                  if (clientProducts.isEmpty)
                    const Text('- Nenhum', style: TextStyle(color: Color(0xFF591E18))),
                  ...clientProducts.map((p) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• ${p.name}', style: const TextStyle(color: Color(0xFF591E18))),
                  )),
                  const SizedBox(height: 12),
                  const Text('Serviços:',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF732027))),
                  if (clientServices.isEmpty)
                    const Text('- Nenhum', style: TextStyle(color: Color(0xFF591E18))),
                  ...clientServices.map((s) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('• ${s.name}', style: const TextStyle(color: Color(0xFF591E18))),
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar', style: TextStyle(color: Color(0xFF732027))),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClientFormView(client: c)),
                  );
                },
                child: const Text('Editar', style: TextStyle(color: Color(0xFF732027))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  Navigator.pop(context);
                  _confirmDelete(c);
                },
                child: const Text('Excluir'),
              ),
            ],
          );
        },
      ),
    );
  }

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
        title: const Text('Clientes',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Client>>(
        stream: ctl.allClients,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return const Center(
              child: Text('Erro ao carregar clientes',
                  style: TextStyle(color: Color(0xFF591E18))),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(
              child: Text('Nenhum cliente cadastrado',
                  style: TextStyle(color: Color(0xFF591E18))),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final c = list[i];
              return Card(
                color: const Color(0xFFF2D4C2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(Icons.person, size: 32, color: const Color(0xFF732027)),
                  title: Text(c.name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF591E18))),
                  subtitle:
                  Text(c.phone, style: const TextStyle(color: Color(0xFF591E18))),
                  onTap: () => _showClientDetails(c),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF732027)),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF732027),
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientFormView())),
      ),
    );
  }
}
