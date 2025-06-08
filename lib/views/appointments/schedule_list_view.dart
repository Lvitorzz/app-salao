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
        backgroundColor: const Color(0xFFF2D4C2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          a.serviceName,
          style: const TextStyle(color: Color(0xFF591E18), fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${a.clientName}', style: const TextStyle(color: Color(0xFF591E18))),
            const SizedBox(height: 8),
            Text(
              'Data: ${DateFormat('dd/MM/yyyy – HH:mm').format(a.dateTime)}',
              style: const TextStyle(color: Color(0xFF591E18)),
            ),
          ],
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
                MaterialPageRoute(builder: (_) => ScheduleFormView(appointment: a)),
              );
            },
            child: const Text('Editar', style: TextStyle(color: Color(0xFF732027))),
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
        stream: _ctl.allAppointments,
        builder: (ctx, snap) {
          if (snap.hasError) {
            return Center(
              child: Text('Erro: ${snap.error}', style: const TextStyle(color: Color(0xFF591E18))),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(
              child: Text('Nenhum agendamento', style: TextStyle(color: Color(0xFF591E18))),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    a.serviceName,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF591E18)),
                  ),
                  subtitle: Text(
                    '${a.clientName}\n${DateFormat('dd/MM/yyyy – HH:mm').format(a.dateTime)}',
                    style: const TextStyle(color: Color(0xFF591E18)),
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF732027)),
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
