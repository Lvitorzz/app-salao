import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gestao_salao/controllers/expense_controller.dart';
import '../../widgets/app_header.dart';

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

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'fixed' ? _fixedOptions : _varOptions;
    return Scaffold(
      appBar: const AppHeader(title: 'Nova Despesa'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tipo: Fixa ou Variável
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'fixed', child: Text('Despesa Fixa')),
                  DropdownMenuItem(value: 'variable', child: Text('Despesa Variável')),
                ],
                decoration: const InputDecoration(labelText: 'Tipo'),
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
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Categoria'),
                onChanged: (v) {
                  setState(() {
                    _category = v;
                    if (v != 'Outros') _customCategory.clear();
                  });
                },
                validator: (v) => v == null ? 'Selecione a categoria' : null,
              ),
              const SizedBox(height: 12),

              // Se "Outros", mostra campo de texto
              if (_category == 'Outros') ...[
                TextFormField(
                  controller: _customCategory,
                  decoration: const InputDecoration(labelText: 'Descreva a categoria'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a categoria' : null,
                ),
                const SizedBox(height: 12),
              ],

              // Valor
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  return (n == null || n <= 0) ? 'Valor inválido' : null;
                },
              ),

              const Spacer(),

              // Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text('Cadastrar Despesa'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
