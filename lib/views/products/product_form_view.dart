// lib/views/product/product_form_view.dart
import 'package:flutter/material.dart';
import 'package:gestao_salao/controllers/product_controller.dart';
import 'package:gestao_salao/models/product_model.dart';

class ProductFormView extends StatefulWidget {
  final Product? product;
  const ProductFormView({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormViewState createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = ProductController();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _priceCtrl = TextEditingController(text: p != null ? p.price.toString() : '');
    _qtyCtrl = TextEditingController(text: p != null ? p.quantity.toString() : '');
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF732027),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Editar Produto' : 'Novo Produto',
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
                controller: _nameCtrl,
                label: 'Nome',
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _descCtrl,
                label: 'Descrição',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _priceCtrl,
                label: 'Preço',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return (n == null || n < 0) ? 'Preço inválido' : null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                controller: _qtyCtrl,
                label: 'Quantidade em estoque',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  return (n == null || n < 0) ? 'Quantidade inválida' : null;
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
                    isEdit ? 'Atualizar' : 'Cadastrar',
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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final prod = Product(
      id: widget.product?.id ?? '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      quantity: int.parse(_qtyCtrl.text),
    );
    if (widget.product != null) {
      _ctrl.update(prod);
    } else {
      _ctrl.add(prod);
    }
    Navigator.pop(context);
  }
}
