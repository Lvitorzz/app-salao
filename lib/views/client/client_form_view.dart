// lib/views/client/client_form_view.dart
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
  final _ctl = ClientController();
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
    _nameC = TextEditingController(text: widget.client?.name ?? '');
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
      id: widget.client?.id ?? '',
      name: _nameC.text.trim(),
      phone: _phoneC.text.trim(),
      productIds: _selectedProducts,
      serviceIds: _selectedServices,
      notes: _notesC.text.trim(),
    );
    if (widget.client != null) _ctl.update(c);
    else _ctl.add(c);
    Navigator.of(context).pop();
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF591E18)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFA67C6D)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF732027)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.client != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF732027),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Editar Cliente' : 'Cadastrar Cliente',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nome
              TextFormField(
                controller: _nameC,
                decoration: _inputDecoration('Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),

              // Telefone
              TextFormField(
                controller: _phoneC,
                decoration: _inputDecoration('Telefone'),
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.isEmpty ? 'Informe o telefone' : null,
              ),
              const SizedBox(height: 20),

              // Informações extras
              const Text(
                'Informações extras do cliente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF591E18)),
              ),
              const SizedBox(height: 12),

              // Produtos
              StreamBuilder<List<Product>>(
                stream: _prodSvc.getProducts(),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final produtos = snap.data!;
                  return MultiSelectDialogField<String>(
                    items: produtos.map((p) => MultiSelectItem(p.id, p.name)).toList(),
                    initialValue: _selectedProducts,
                    title: const Text('Produtos'),
                    buttonText: const Text('Selecione produtos'),
                    searchable: true,
                    confirmText: const Text('OK', style: TextStyle(color: Color(0xFF732027))),
                    cancelText: const Text('CANCELAR', style: TextStyle(color: Color(0xFF732027))),
                    onConfirm: (vals) => _selectedProducts = vals,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Serviços
              StreamBuilder<List<Service>>(
                stream: _servSvc.getAll(),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final servicos = snap.data!;
                  return MultiSelectDialogField<String>(
                    items: servicos.map((s) => MultiSelectItem(s.id, s.name)).toList(),
                    initialValue: _selectedServices,
                    title: const Text('Serviços'),
                    buttonText: const Text('Selecione serviços'),
                    searchable: true,
                    confirmText: const Text('OK', style: TextStyle(color: Color(0xFF732027))),
                    cancelText: const Text('CANCELAR', style: TextStyle(color: Color(0xFF732027))),
                    onConfirm: (vals) => _selectedServices = vals,
                  );
                },
              ),
              const SizedBox(height: 20),

              // Observações
              TextFormField(
                controller: _notesC,
                decoration: _inputDecoration('Observações'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Botão de ação
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF732027),
                    foregroundColor: const Color(0xFFF2E7C4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: Text(
                    isEdit ? 'Salvar' : 'Cadastrar',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
