import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../controllers/client_controller.dart';
import '../../models/client_model.dart';
import 'client_form_view.dart';

class ClientListView extends StatefulWidget {
  const ClientListView({Key? key}) : super(key: key);
  @override
  _ClientListViewState createState() => _ClientListViewState();
}

class _ClientListViewState extends State<ClientListView> {
  final ctl = ClientController();

  void _confirmDelete(Client c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Cliente'),
        content: Text('Excluir "${c.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ctl.delete(c.id);
              Navigator.pop(context);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Clientes'),
      body: StreamBuilder<List<Client>>(
        stream: ctl.allClients,
        builder: (ctx, snap) {
          if (snap.hasError) return const Center(child: Text('Erro ao carregar clientes'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('Nenhum cliente cadastrado'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final c = list[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(c.name),
                  subtitle: Text(c.phone),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ClientFormView(client: c)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(c),
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
        child: const Icon(Icons.person_add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClientFormView()),
        ),
      ),
    );
  }
}
