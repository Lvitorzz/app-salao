// lib/views/service/service_form_view.dart
import 'package:flutter/material.dart';
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
    if (widget.service != null)
      ctl.update(s);
    else
      ctl.add(s);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.service != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF732027),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Editar Serviço' : 'Cadastrar Serviço',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(
                controller: _nameC,
                label: 'Nome',
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _priceC,
                label: 'Preço',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return (n == null || n < 0) ? 'Preço inválido' : null;
                },
              ),
              const SizedBox(height: 24),
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
                    isEdit ? 'Salvar' : 'Adicionar',
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
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
      ),
    );
  }
}
