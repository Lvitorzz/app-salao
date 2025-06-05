import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';
import '../../controllers/service_controller.dart';
import '../../models/service_model.dart';

class ServiceFormView extends StatefulWidget {
  final Service? service;
  const ServiceFormView({Key? key, this.service}) : super(key: key);
  @override
  _ServiceFormViewState createState() => _ServiceFormViewState();
}

class _ServiceFormViewState extends State<ServiceFormView> {
  final _formKey = GlobalKey<FormState>();
  final ctl = ServiceController();
  late final TextEditingController _nameC;
  late final TextEditingController _priceC;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.service?.name ?? '');
    _priceC = TextEditingController(text: widget.service?.price.toString() ?? '');
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final s = Service(
      id: widget.service?.id ?? '',
      name: _nameC.text.trim(),
      price: double.parse(_priceC.text),
    );
    if (widget.service != null) ctl.update(s);
    else ctl.add(s);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;
    return Scaffold(
      appBar: AppHeader(title: isEdit ? 'Editar Serviço' : 'Cadastrar Serviço'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceC,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return n == null || n < 0 ? 'Preço inválido' : null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Salvar' : 'Adicionar')),
            ],
          ),
        ),
      ),
    );
  }
}
