import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../widgets/app_header.dart';
import '../../controllers/client_controller.dart';
import '../../models/client_model.dart';
import '../../models/product_model.dart';
import '../../models/service_model.dart';
import '../../services/product_service.dart';
import '../../services/service_service.dart';

class ClientFormView extends StatefulWidget {
  final Client? client;
  const ClientFormView({Key? key, this.client}) : super(key: key);

  @override
  _ClientFormViewState createState() => _ClientFormViewState();
}

class _ClientFormViewState extends State<ClientFormView> {
  final _formKey = GlobalKey<FormState>();
  final _ctl     = ClientController();
  final _prodSvc = ProductService();
  final _servSvc = ServiceService();

  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _notesC;

  List<String> _selectedProducts = [];
  List<String> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    _nameC  = TextEditingController(text: widget.client?.name  ?? '');
    _phoneC = TextEditingController(text: widget.client?.phone ?? '');
    _notesC = TextEditingController(text: widget.client?.notes ?? '');
    _selectedProducts = widget.client?.productIds ?? [];
    _selectedServices = widget.client?.serviceIds ?? [];
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final c = Client(
      id:         widget.client?.id ?? '',
      name:       _nameC.text.trim(),
      phone:      _phoneC.text.trim(),
      productIds: _selectedProducts,
      serviceIds: _selectedServices,
      notes:      _notesC.text.trim(),
    );
    if (widget.client != null) _ctl.update(c);
    else                     _ctl.add(c);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.client != null;
    return Scaffold(
      appBar: AppHeader(title: isEdit ? 'Editar Cliente' : 'Cadastrar Cliente'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nome
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),

              // Telefone
              TextFormField(
                controller: _phoneC,
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 20),

              // Seção de informações extras
              const Text(
                'Informações extras do cliente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Produtos (0 ou vários)
              StreamBuilder<List<Product>>(
                stream: _prodSvc.getProducts(),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final produtos = snap.data!;
                  return MultiSelectDialogField<String>(
                    items: produtos
                        .map((p) => MultiSelectItem(p.id, p.name))
                        .toList(),
                    initialValue: _selectedProducts,
                    title: const Text('Produtos'),
                    buttonText: const Text('Selecione produtos'),
                    searchable: true,
                    onConfirm: (vals) => _selectedProducts = vals,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Serviços (0 ou vários)
              StreamBuilder<List<Service>>(
                stream: _servSvc.getAll(),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final servicos = snap.data!;
                  return MultiSelectDialogField<String>(
                    items: servicos
                        .map((s) => MultiSelectItem(s.id, s.name))
                        .toList(),
                    initialValue: _selectedServices,
                    title: const Text('Serviços'),
                    buttonText: const Text('Selecione serviços'),
                    searchable: true,
                    onConfirm: (vals) => _selectedServices = vals,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Observações
              TextFormField(
                controller: _notesC,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Botão de ação
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Salvar' : 'Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
