import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/receipt_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../models/transaction_model.dart';
import '../../models/receipt_model.dart';

class TransactionListView extends StatefulWidget {
  const TransactionListView({Key? key}) : super(key: key);
  @override
  _TransactionListViewState createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  final _txCtl = TransactionController();
  final _rc = ReceiptController();
  final _ec = ExpenseController();
  final _fmt = DateFormat('dd/MM/yyyy – HH:mm', 'pt_BR');
  int _navIndex = 2;

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
              title: Text(tx.subtype == 'product' ? 'Venda' : 'Serviço'),
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
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
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
          title: const Text('Despesa'),
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
      appBar: const AppHeader(title: 'Transações'),
      body: StreamBuilder<List<Transaction>>(
        stream: _txCtl.allTransactions,
        builder: (ctx, snap) {
          if (snap.hasError) return Center(child: Text('Erro: ${snap.error}'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final txs = snap.data!;
          if (txs.isEmpty) return const Center(child: Text('Nenhuma transação'));
          return ListView.builder(
            itemCount: txs.length,
            itemBuilder: (_, i) {
              final tx = txs[i];
              return ListTile(
                leading: Icon(
                  tx.type == TransactionType.receipt ? Icons.arrow_upward : Icons.arrow_downward,
                  color: tx.type == TransactionType.receipt ? Colors.green : Colors.red,
                ),
                title: Text(tx.type == TransactionType.receipt
                    ? (tx.subtype == 'product' ? 'Venda' : 'Serviço')
                    : tx.description),
                subtitle: Text('R\$ ${tx.amount.toStringAsFixed(2)}'),
                trailing: Text(_fmt.format(tx.date)),
                onTap: () => _showDetails(tx),
              );
            },
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
