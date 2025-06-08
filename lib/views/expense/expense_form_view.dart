// lib/views/expense/expense_form_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestao_salao/controllers/expense_controller.dart';
import '../../models/expense_model.dart';

class ExpenseFormView extends StatefulWidget {
  const ExpenseFormView({Key? key}) : super(key: key);

  @override
  _ExpenseFormViewState createState() => _ExpenseFormViewState();
}

class _ExpenseFormViewState extends State<ExpenseFormView> {
  final _formKey = GlobalKey<FormState>();
  final _ctl = ExpenseController();

  String _type = 'fixed';
  String? _category;
  final _customCategory = TextEditingController();
  final _amountCtrl = TextEditingController();

  final _fixedOptions = ['Aluguel', 'Água', 'Luz', 'Funcionário'];
  final _varOptions = [
    'Compra de produtos',
    'Compra de equipamentos',
    'Conserto',
    'Outros'
  ];

  @override
  void dispose() {
    _customCategory.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = Timestamp.now();
    final category = (_category == 'Outros')
        ? _customCategory.text.trim()
        : _category!;
    final expense = Expense(
      id: '',
      type: _type,
      category: category,
      amount: double.parse(_amountCtrl.text),
      createdAt: now,
    );
    await _ctl.add(expense);
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF591E18)),
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    final categories =
    _type == 'fixed' ? _fixedOptions : _varOptions;

    return Scaffold(
      backgroundColor: const Color(0xFFF2E7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF732027),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nova Despesa',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tipo: Fixa ou Variável
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(
                      value: 'fixed', child: Text('Despesa Fixa')),
                  DropdownMenuItem(
                      value: 'variable',
                      child: Text('Despesa Variável')),
                ],
                decoration: _inputDecoration('Tipo'),
                onChanged: (v) {
                  setState(() {
                    _type = v!;
                    _category = null;
                    _customCategory.clear();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Categoria
              DropdownButtonFormField<String>(
                value: _category,
                items: categories
                    .map((c) =>
                    DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                decoration: _inputDecoration('Categoria'),
                onChanged: (v) {
                  setState(() {
                    _category = v;
                    if (v != 'Outros') _customCategory.clear();
                  });
                },
                validator: (v) =>
                v == null ? 'Selecione a categoria' : null,
              ),
              const SizedBox(height: 12),

              // Se "Outros", mostra campo de texto extra
              if (_category == 'Outros') ...[
                TextFormField(
                  controller: _customCategory,
                  decoration:
                  _inputDecoration('Descreva a categoria'),
                  validator: (v) => v == null || v.isEmpty
                      ? 'Informe a categoria'
                      : null,
                ),
                const SizedBox(height: 12),
              ],

              // Valor
              TextFormField(
                controller: _amountCtrl,
                decoration: _inputDecoration('Valor (R\$)'),
                keyboardType:
                const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return (n == null || n <= 0)
                      ? 'Valor inválido'
                      : null;
                },
              ),

              const SizedBox(height: 24),

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF732027),
                    foregroundColor: const Color(0xFFF2E7C4),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cadastrar Despesa',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
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
