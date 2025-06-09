// lib/views/appointments/schedule_list_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/appointment_controller.dart';
import '../../controllers/client_controller.dart';
import '../../models/appointment_model.dart';
import '../../models/client_model.dart';
import 'schedule_form_view.dart';

class ScheduleListView extends StatefulWidget {
  const ScheduleListView({Key? key}) : super(key: key);

  @override
  _ScheduleListViewState createState() => _ScheduleListViewState();
}

class _ScheduleListViewState extends State<ScheduleListView> {
  final _apptCtl = AppointmentController();
  final _cliCtl  = ClientController();
  final _fmt     = DateFormat('dd/MM/yyyy – HH:mm');

  Future<void> _remindClient(Appointment a) async {
    // Pega a lista de clientes e filtra pelo ID
    final clients = await _cliCtl.allClients.first;
    final client = clients.firstWhere((c) => c.id == a.clientId);

    final phone = client.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final when  = _fmt.format(a.dateTime);
    final text  = Uri.encodeComponent(
        'Olá ${client.name}, lembrete do seu agendamento de '
            '${a.serviceName} em $when!'
    );
    final uri   = Uri.parse('https://wa.me/$phone?text=$text');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
      );
    }
  }

  void _showDetails(Appointment a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF2D4C2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          a.serviceName,
          style: const TextStyle(
            color: Color(0xFF591E18),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${a.clientName}',
                style: const TextStyle(color: Color(0xFF591E18))),
            const SizedBox(height: 8),
            Text('Data: ${_fmt.format(a.dateTime)}',
                style: const TextStyle(color: Color(0xFF591E18))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text('Fechar', style: TextStyle(color: Color(0xFF732027))),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _remindClient(a);
            },
            icon: const Icon(Icons.message, color: Color(0xFF732027)),
            label: const Text('Lembrar cliente',
                style: TextStyle(color: Color(0xFF732027))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ScheduleFormView(appointment: a)),
              );
            },
            child: const Text('Editar',
                style: TextStyle(color: Color(0xFF732027))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              _apptCtl.delete(a.id);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
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
          'Agendamentos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: _apptCtl.allAppointments,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return Center(
              child: Text('Erro: ${snap.error}',
                  style: const TextStyle(color: Color(0xFF591E18))),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(
              child: Text('Nenhum agendamento',
                  style: TextStyle(color: Color(0xFF591E18))),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final a = list[i];
              return Card(
                color: const Color(0xFFF2D4C2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(a.serviceName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF591E18))),
                  subtitle: Text(
                    '${a.clientName}\n${_fmt.format(a.dateTime)}',
                    style: const TextStyle(color: Color(0xFF591E18)),
                  ),
                  isThreeLine: true,
                  trailing:
                  const Icon(Icons.chevron_right, color: Color(0xFF732027)),
                  onTap: () => _showDetails(a),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
