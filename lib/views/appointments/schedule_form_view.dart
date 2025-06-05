// lib/views/appointments/schedule_form_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/app_header.dart';
import '../../controllers/appointment_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/client_controller.dart';
import '../../models/service_model.dart';
import '../../models/client_model.dart';
import '../../models/appointment_model.dart';

class ScheduleFormView extends StatefulWidget {
  final Appointment? appointment;
  const ScheduleFormView({Key? key, this.appointment}) : super(key: key);

  @override
  _ScheduleFormViewState createState() => _ScheduleFormViewState();
}

class _ScheduleFormViewState extends State<ScheduleFormView> {
  final _formKey = GlobalKey<FormState>();
  final _apptCtl = AppointmentController();
  final _svcCtl = ServiceController();
  final _cliCtl = ClientController();

  String? _selectedServiceId;
  String? _selectedClientId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  List<Client> _clients = [];
  bool _loadingClients = true;

  @override
  void initState() {
    super.initState();
    // carrega clientes
    _cliCtl.allClients.listen((list) {
      setState(() {
        _clients = list;
        _loadingClients = false;
      });
    });
    // se estiver editando, pré-carrega valores
    final appt = widget.appointment;
    if (appt != null) {
      _selectedServiceId = appt.serviceId;
      _selectedClientId = appt.clientId;
      _selectedDate = appt.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(appt.dateTime);
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (t != null) setState(() => _selectedTime = t);
  }

  Future<void> _addNewClient() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
              final doc = await FirebaseFirestore.instance.collection('clients').add({
                'name': nameCtrl.text.trim(),
                'phone': phoneCtrl.text.trim(),
              });
              setState(() {
                _selectedClientId = doc.id;
              });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final service = (await _svcCtl.allServices.first)
        .firstWhere((s) => s.id == _selectedServiceId);
    final client = _clients.firstWhere((c) => c.id == _selectedClientId);
    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    if (widget.appointment != null) {
      // atualização
      final orig = widget.appointment!;
      final updated = Appointment(
        id: orig.id,
        serviceId: service.id,
        serviceName: service.name,
        clientId: client.id,
        clientName: client.name,
        dateTime: dt,
        createdAt: orig.createdAt,
      );
      await _apptCtl.update(updated);
    } else {
      // novo agendamento
      final newAppt = Appointment(
        id: '',
        serviceId: service.id,
        serviceName: service.name,
        clientId: client.id,
        clientName: client.name,
        dateTime: dt,
        createdAt: Timestamp.now(),
      );
      await _apptCtl.add(newAppt);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.appointment != null;
    return Scaffold(
      appBar: AppHeader(title: isEdit ? 'Editar Agendamento' : 'Agendar Serviço'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Serviço
              StreamBuilder<List<Service>>(
                stream: _svcCtl.allServices,
                builder: (ctx, snap) {
                  if (!snap.hasData) return const CircularProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: _selectedServiceId,
                    items: snap.data!
                        .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Serviço'),
                    onChanged: isEdit ? null : (v) => setState(() => _selectedServiceId = v),
                    validator: (v) => v == null ? 'Selecione um serviço' : null,
                  );
                },
              ),
              const SizedBox(height: 12),

              // Cliente
              _loadingClients
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _selectedClientId,
                      items: [
                        ..._clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                        if (!isEdit)
                          const DropdownMenuItem(value: 'new', child: Text('Novo Cliente')),
                      ],
                      decoration: const InputDecoration(labelText: 'Cliente'),
                      onChanged: isEdit
                          ? null
                          : (v) {
                              if (v == 'new') {
                                _addNewClient();
                              } else {
                                setState(() => _selectedClientId = v);
                              }
                            },
                      validator: (v) => v == null ? 'Selecione o cliente' : null,
                    ),
              const SizedBox(height: 12),

              // Data e Hora
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Data'),
                        child: Text(
                          _selectedDate == null
                              ? 'Selecione'
                              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Hora'),
                        child: Text(
                          _selectedTime == null ? 'Selecione' : _selectedTime!.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Botão
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEdit ? 'Salvar' : 'Agendar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
