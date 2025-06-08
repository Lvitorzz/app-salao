// lib/views/receipts/receipt_form_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/app_header.dart';
import '../../controllers/receipt_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/service_controller.dart';
import '../../models/product_model.dart';
import '../../models/service_model.dart';
import '../../models/receipt_model.dart';

class ReceiptFormView extends StatefulWidget {
  const ReceiptFormView({Key? key}) : super(key: key);

  @override
  _ReceiptFormViewState createState() => _ReceiptFormViewState();
}

class _ReceiptFormViewState extends State<ReceiptFormView> {
  final _formKey = GlobalKey<FormState>();
  final _receiptCtl = ReceiptController();
  final _productCtl = ProductController();
  final _serviceCtl = ServiceController();

  String _type = 'product';
  List<Map<String, dynamic>> _selected = [];
  final _otherDesc = TextEditingController();
  final _otherPrice = TextEditingController();

  @override
  void dispose() {
    _otherDesc.dispose();
    _otherPrice.dispose();
    super.dispose();
  }

  void _addItemRow() {
    setState(() {
      _selected.add({'itemId': null, 'qty': 1});
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = Timestamp.now();
    late Receipt receipt;

    if (_type == 'other') {
      receipt = Receipt(
        id: '',
        type: 'other',
        items: [],
        description: _otherDesc.text.trim(),
        total: double.parse(_otherPrice.text),
        createdAt: now,
      );
    } else if (_type == 'product') {
      final products = await _productCtl.allProducts.first;
      final items = _selected.map((sel) {
        final p = products.firstWhere((p) => p.id == sel['itemId']);
        return ReceiptItem(
          id: p.id,
          name: p.name,
          price: p.price,
          quantity: sel['qty'] as int,
        );
      }).toList();
      final total = items.fold<double>(0.0, (sum, it) => sum + it.price * it.quantity);
      receipt = Receipt(
        id: '',
        type: 'product',
        items: items,
        description: null,
        total: total,
        createdAt: now,
      );
    } else {
      final services = await _serviceCtl.allServices.first;
      final items = _selected.map((sel) {
        final s = services.firstWhere((s) => s.id == sel['itemId']);
        return ReceiptItem(
          id: s.id,
          name: s.name,
          price: s.price,
          quantity: sel['qty'] as int,
        );
      }).toList();
      final total = items.fold<double>(0.0, (sum, it) => sum + it.price * it.quantity);
      receipt = Receipt(
        id: '',
        type: 'service',
        items: items,
        description: null,
        total: total,
        createdAt: now,
      );
    }

    await _receiptCtl.add(receipt);
    Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF732027),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nova Receita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tipo de Receita
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'product', child: Text('Produto')),
                  DropdownMenuItem(value: 'service', child: Text('Serviço')),
                  DropdownMenuItem(value: 'other', child: Text('Outros')),
                ],
                decoration: _inputDecoration('Tipo'),
                onChanged: (v) {
                  setState(() {
                    _type = v!;
                    _selected.clear();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Caso "Outros"
              if (_type == 'other') ...[
                TextFormField(
                  controller: _otherDesc,
                  decoration: _inputDecoration('Descrição'),
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Informe a descrição' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otherPrice,
                  decoration: _inputDecoration('Preço'),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return (n == null || n < 0) ? 'Preço inválido' : null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: R\$ ${double.tryParse(_otherPrice.text)?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF732027)),
                ),
              ] else if (_type == 'product') ...[
                // Seção de produtos
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: StreamBuilder<List<Product>>(
                    stream: _productCtl.allProducts,
                    builder: (ctx, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selected.length,
                        itemBuilder: (_, i) {
                          final sel = _selected[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: sel['itemId'] as String?,
                                    items: snap.data!
                                        .map((p) => DropdownMenuItem(
                                        value: p.id, child: Text(p.name)))
                                        .toList(),
                                    decoration: _inputDecoration('Selecione'),
                                    onChanged: (id) =>
                                        setState(() => sel['itemId'] = id),
                                    validator: (v) =>
                                    v == null ? 'Selecione um item' : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: sel['qty'].toString(),
                                    decoration: _inputDecoration('Qtd'),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      final n = int.tryParse(v ?? '');
                                      return (n == null || n < 1)
                                          ? 'Inválido'
                                          : null;
                                    },
                                    onChanged: (v) =>
                                    sel['qty'] = int.tryParse(v) ?? 1,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  color: Colors.redAccent,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() => _selected.removeAt(i));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Total de Produtos
                StreamBuilder<List<Product>>(
                  stream: _productCtl.allProducts,
                  builder: (ctx, snap) {
                    if (!snap.hasData) return const SizedBox();
                    final products = snap.data!;
                    final total = _selected.fold<double>(
                      0.0,
                          (sum, sel) {
                        if (sel['itemId'] == null) return sum;
                        final p = products.firstWhere((p) => p.id == sel['itemId']);
                        return sum + p.price * (sel['qty'] as int);
                      },
                    );
                    return Text(
                      'Total: R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF732027)),
                    );
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _addItemRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF732027),
                    foregroundColor: const Color(0xFFF2E7C4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ] else ...[
                // Seção de serviços
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: StreamBuilder<List<Service>>(
                    stream: _serviceCtl.allServices,
                    builder: (ctx, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selected.length,
                        itemBuilder: (_, i) {
                          final sel = _selected[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: sel['itemId'] as String?,
                                    items: snap.data!
                                        .map((s) => DropdownMenuItem(
                                        value: s.id, child: Text(s.name)))
                                        .toList(),
                                    decoration: _inputDecoration('Selecione'),
                                    onChanged: (id) =>
                                        setState(() => sel['itemId'] = id),
                                    validator: (v) =>
                                    v == null ? 'Selecione um item' : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: sel['qty'].toString(),
                                    decoration: _inputDecoration('Qtd'),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      final n = int.tryParse(v ?? '');
                                      return (n == null || n < 1)
                                          ? 'Inválido'
                                          : null;
                                    },
                                    onChanged: (v) =>
                                    sel['qty'] = int.tryParse(v) ?? 1,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  color: Colors.redAccent,
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    setState(() => _selected.removeAt(i));
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Total de Serviços
                StreamBuilder<List<Service>>(
                  stream: _serviceCtl.allServices,
                  builder: (ctx, snap) {
                    if (!snap.hasData) return const SizedBox();
                    final services = snap.data!;
                    final total = _selected.fold<double>(
                      0.0,
                          (sum, sel) {
                        if (sel['itemId'] == null) return sum;
                        final s =
                        services.firstWhere((s) => s.id == sel['itemId']);
                        return sum + s.price * (sel['qty'] as int);
                      },
                    );
                    return Text(
                      'Total: R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF732027)),
                    );
                  },
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _addItemRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF732027),
                    foregroundColor: const Color(0xFFF2E7C4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF732027),
                    foregroundColor: const Color(0xFFF2E7C4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: const Text(
                    'Cadastrar Receita',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
