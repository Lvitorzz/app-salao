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
        final id = sel['itemId'] as String;
        final qty = sel['qty'] as int;
        final p = products.firstWhere((p) => p.id == id);
        return ReceiptItem(
          id: p.id,
          name: p.name,
          price: p.price,
          quantity: qty,
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
        final id = sel['itemId'] as String;
        final qty = sel['qty'] as int;
        final s = services.firstWhere((s) => s.id == id);
        return ReceiptItem(
          id: s.id,
          name: s.name,
          price: s.price,
          quantity: qty,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Nova Receita'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tipo de Receita
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'product', child: Text('Produto')),
                  DropdownMenuItem(value: 'service', child: Text('Serviço')),
                  DropdownMenuItem(value: 'other', child: Text('Outros')),
                ],
                decoration: const InputDecoration(labelText: 'Tipo'),
                onChanged: (v) {
                  setState(() {
                    _type = v!;
                    _selected.clear();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Outros
              if (_type == 'other') ...[
                TextFormField(
                  controller: _otherDesc,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  validator: (v) => v == null || v.isEmpty ? 'Informe a descrição' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _otherPrice,
                  decoration: const InputDecoration(labelText: 'Preço'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final n = double.tryParse(v ?? '');
                    return (n == null || n < 0) ? 'Preço inválido' : null;
                  },
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: R\$ ${double.tryParse(_otherPrice.text)?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ] else ...[
                // Produtos
                if (_type == 'product') ...[
                  Expanded(
                    child: StreamBuilder<List<Product>>(
                      stream: _productCtl.allProducts,
                      builder: (ctx, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final products = snap.data!;
                        return ListView.builder(
                          itemCount: _selected.length,
                          itemBuilder: (_, i) {
                            final sel = _selected[i];
                            return Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: sel['itemId'] as String?,
                                    items: products.map((p) =>
                                      DropdownMenuItem(value: p.id, child: Text(p.name))
                                    ).toList(),
                                    decoration: const InputDecoration(labelText: 'Selecione'),
                                    onChanged: (id) => setState(() => sel['itemId'] = id),
                                    validator: (v) => v == null ? 'Selecione um item' : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      if (!hasFocus) setState(() {});
                                    },
                                    child: TextFormField(
                                      initialValue: sel['qty'].toString(),
                                      decoration: const InputDecoration(labelText: 'Qtd'),
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        final n = int.tryParse(v ?? '');
                                        return (n == null || n < 1) ? 'Inválido' : null;
                                      },
                                      onChanged: (v) => sel['qty'] = int.tryParse(v) ?? 1,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    setState(() => _selected.removeAt(i));
                                  },
                                ),
                              ],
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
                          final qty = sel['qty'] as int;
                          return sum + p.price * qty;
                        },
                      );
                      return Text(
                        'Total: R\$ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  TextButton.icon(
                    onPressed: _addItemRow,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar item'),
                  ),
                ],

                // Serviços
                if (_type == 'service') ...[
                  Expanded(
                    child: StreamBuilder<List<Service>>(
                      stream: _serviceCtl.allServices,
                      builder: (ctx, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final services = snap.data!;
                        return ListView.builder(
                          itemCount: _selected.length,
                          itemBuilder: (_, i) {
                            final sel = _selected[i];
                            return Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: sel['itemId'] as String?,
                                    items: services.map((s) =>
                                      DropdownMenuItem(value: s.id, child: Text(s.name))
                                    ).toList(),
                                    decoration: const InputDecoration(labelText: 'Selecione'),
                                    onChanged: (id) => setState(() => sel['itemId'] = id),
                                    validator: (v) => v == null ? 'Selecione um item' : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 60,
                                  child: Focus(
                                    onFocusChange: (hasFocus) {
                                      if (!hasFocus) setState(() {});
                                    },
                                    child: TextFormField(
                                      initialValue: sel['qty'].toString(),
                                      decoration: const InputDecoration(labelText: 'Qtd'),
                                      keyboardType: TextInputType.number,
                                      validator: (v) {
                                        final n = int.tryParse(v ?? '');
                                        return (n == null || n < 1) ? 'Inválido' : null;
                                      },
                                      onChanged: (v) => sel['qty'] = int.tryParse(v) ?? 1,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  color: Colors.redAccent,
                                  onPressed: () {
                                    setState(() => _selected.removeAt(i));
                                  },
                                ),
                              ],
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
                          final s = services.firstWhere((s) => s.id == sel['itemId']);
                          final qty = sel['qty'] as int;
                          return sum + s.price * qty;
                        },
                      );
                      return Text(
                        'Total: R\$ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                  TextButton.icon(
                    onPressed: _addItemRow,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar item'),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Cadastrar Receita'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
