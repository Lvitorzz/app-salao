// lib/views/transaction/transaction_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';                      // ← adicionado
import 'package:intl/intl.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/receipt_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../models/transaction_model.dart';
import '../../models/receipt_model.dart';
import '../../models/expense_model.dart';

class TransactionListView extends StatefulWidget {
  const TransactionListView({Key? key}) : super(key: key);

  @override
  _TransactionListViewState createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  final _txCtl = TransactionController();
  final _rc   = ReceiptController();
  final _ec   = ExpenseController();
  final _fmt  = DateFormat('dd/MM/yyyy – HH:mm', 'pt_BR');

  int _navIndex    = 2;
  int _filterIndex = 0;
  static const _filterLabels = ['Tudo', 'Receitas', 'Despesas'];

  @override
  void dispose() {
    _txCtl.dispose();
    super.dispose();
  }

  void _onNavTap(int i) {
    setState(() => _navIndex = i);
    switch (i) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
      // ainda não implementado
        break;
      case 2:
      default:
        break;
    }
  }

  void _showDetails(Transaction tx) {
    if (tx.type == TransactionType.receipt) {
      showDialog(
        context: context,
        builder: (_) => FutureBuilder<Receipt>(
          future: _rc.getById(tx.id),
          builder: (ctx, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final r = snap.data!;
            return AlertDialog(
              backgroundColor: const Color(0xFFF2D4C2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(
                tx.subtype == 'product' ? 'Venda' : 'Serviço',
                style: const TextStyle(color: Color(0xFF591E18), fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total: R\$ ${r.total.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text('Data: ${_fmt.format(r.createdAt.toDate())}'),
                  const Divider(),
                  ...r.items.map((i) => ListTile(
                    title: Text(i.name),
                    trailing: Text('${i.quantity}×'),
                    subtitle: Text('R\$ ${i.price.toStringAsFixed(2)}'),
                  )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: const Text('Excluir esta receita?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: () {
                              _rc.delete(tx.id);
                              Navigator.pop(context);
                              Navigator.pop(context);
                              setState(() {});
                            },
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            );
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFF2D4C2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Despesa', style: TextStyle(color: Color(0xFF591E18), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Categoria: ${tx.description}'),
              Text('Valor: R\$ ${tx.amount.toStringAsFixed(2)}'),
              Text('Data: ${_fmt.format(tx.date)}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Confirmar exclusão'),
                    content: const Text('Excluir esta despesa?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Não')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () {
                          _ec.delete(tx.id);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: const Text('Excluir'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7C4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF732027),
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF732027),           // pinta toda a área até os ícones
          statusBarIconBrightness: Brightness.light,    // ícones da status bar em branco
        ),
        title: const Text(
          'Transações',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _txCtl.allTransactions,
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          // aplica filtro
          final all = snap.data!;
          final txs = _filterIndex == 1
              ? all.where((t) => t.type == TransactionType.receipt).toList()
              : _filterIndex == 2
              ? all.where((t) => t.type == TransactionType.expense).toList()
              : all;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ToggleButtons(
                  isSelected: List.generate(_filterLabels.length, (i) => i == _filterIndex),
                  onPressed: (i) => setState(() => _filterIndex = i),
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: const Color(0xFFF2E7C4),
                  fillColor: const Color(0xFF732027),
                  color: const Color(0xFF732027),
                  borderColor: const Color(0xFF732027),
                  selectedBorderColor: const Color(0xFF732027),
                  children: _filterLabels.map((label) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: txs.isEmpty
                      ? const Center(child: Text('Nenhuma transação', style: TextStyle(color: Color(0xFF591E18))))
                      : ListView.builder(
                    itemCount: txs.length,
                    itemBuilder: (_, i) {
                      final tx = txs[i];
                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            tx.type == TransactionType.receipt
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: tx.type == TransactionType.receipt
                                ? const Color(0xFF732027)
                                : const Color(0xFFA67C6D),
                          ),
                          title: Text(
                            tx.type == TransactionType.receipt
                                ? (tx.subtype == 'product' ? 'Venda' : 'Serviço')
                                : tx.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF591E18),
                            ),
                          ),
                          subtitle: Text(
                            'R\$ ${tx.amount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Color(0xFF591E18)),
                          ),
                          trailing: Text(
                            _fmt.format(tx.date),
                            style: const TextStyle(color: Color(0xFF591E18), fontSize: 12),
                          ),
                          onTap: () => _showDetails(tx),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
