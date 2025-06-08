// lib/views/service/service_list_view.dart
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
        content: Text('Deseja excluir "${s.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
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
      backgroundColor: const Color(0xFFF2E7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF732027),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Serviços',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Service>>(
        stream: ctl.allServices,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return const Center(
              child: Text(
                'Erro ao carregar serviços',
                style: TextStyle(color: Color(0xFF591E18)),
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum serviço cadastrado',
                style: TextStyle(color: Color(0xFF591E18)),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final s = list[i];
              return Card(
                color: const Color(0xFFF2D4C2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(
                    Icons.build,
                    size: 32,
                    color: const Color(0xFF732027),
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF591E18),
                    ),
                  ),
                  subtitle: Text(
                    'R\$ ${s.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Color(0xFF591E18)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: const Color(0xFF732027),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ServiceFormView(service: s)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.redAccent,
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
        backgroundColor: const Color(0xFF732027),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ServiceFormView()),
        ),
      ),
    );
  }
}
