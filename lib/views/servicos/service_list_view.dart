import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../controllers/service_controller.dart';
import '../../models/service_model.dart';
import 'service_form_view.dart';

class ServiceListView extends StatefulWidget {
  const ServiceListView({Key? key}) : super(key: key);
  @override
  _ServiceListViewState createState() => _ServiceListViewState();
}

class _ServiceListViewState extends State<ServiceListView> {
  final ctl = ServiceController();

  void _delete(Service s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: Text('Excluir "${s.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ctl.delete(s.id);
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
      appBar: const AppHeader(title: 'Serviços'),
      body: StreamBuilder<List<Service>>(
        stream: ctl.allServices,
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('Nenhum serviço cadastrado'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.build),
                  title: Text(s.name),
                  subtitle: Text('R\$ ${s.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ServiceFormView(service: s)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _delete(s),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ServiceFormView()),
        ),
      ),
    );
  }
}
