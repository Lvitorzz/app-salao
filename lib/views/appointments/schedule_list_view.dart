// lib/views/appointments/schedule_list_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_header.dart';
import '../../controllers/appointment_controller.dart';
import '../../models/appointment_model.dart';
import 'schedule_form_view.dart';

class ScheduleListView extends StatefulWidget {
  const ScheduleListView({Key? key}) : super(key: key);

  @override
  _ScheduleListViewState createState() => _ScheduleListViewState();
}

class _ScheduleListViewState extends State<ScheduleListView> {
  final _ctl = AppointmentController();

  void _showDetails(Appointment a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(a.serviceName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cliente: ${a.clientName}'),
            const SizedBox(height: 8),
            Text('Data: ${DateFormat('dd/MM/yyyy – HH:mm').format(a.dateTime)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // fecha o modal
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ScheduleFormView(appointment: a),
                ),
              );
            },
            child: const Text('Editar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              _ctl.delete(a.id);
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
      appBar: const AppHeader(title: 'Agendamentos'),
      body: StreamBuilder<List<Appointment>>(
        stream: _ctl.allAppointments,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(child: Text('Nenhum agendamento'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final a = list[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(a.serviceName),
                  subtitle: Text(
                    '${a.clientName}\n${DateFormat('dd/MM/yyyy – HH:mm').format(a.dateTime)}',
                  ),
                  isThreeLine: true,
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
