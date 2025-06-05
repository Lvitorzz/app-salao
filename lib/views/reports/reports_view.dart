// lib/views/reports/reports_view.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';

import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({Key? key}) : super(key: key);

  @override
  _ReportsViewState createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TransactionController _txCtl;

  // Estado para Intervalo
  DateTime? _startDate;
  DateTime? _endDate;

  // Estado para Mensal/Anual
  int _selectedMonth = DateTime.now().month;
  int _selectedYear  = DateTime.now().year;

  @override
  void initState() {
    super.initState();

    // inicializa intervalo com últimos 30 dias
    final today = DateTime.now();
    _endDate   = today;
    _startDate = today.subtract(const Duration(days: 30));

    _tabController = TabController(length: 3, vsync: this);
    _txCtl = TransactionController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _txCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx, bool isStart) async {
    final today = DateTime.now();
    final first = DateTime(today.year - 5);
    final last  = DateTime(today.year + 5);
    final picked = await showDatePicker(
      context: ctx,
      initialDate: isStart ? (_startDate ?? today) : (_endDate ?? today),
      firstDate: first,
      lastDate: last,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) _startDate = picked;
      else         _endDate   = picked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Intervalo'),
            Tab(text: 'Mensal'),
            Tab(text: 'Anual'),
          ],
        ),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _txCtl.allTransactions,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final txs = snap.data!;
          return TabBarView(
            controller: _tabController,
            children: [
              _intervalTab(txs),
              _monthlyTab(txs),
              _annualTab(txs),
            ],
          );
        },
      ),
    );
  }

  /// Aba Intervalo: filtra por start/end e agrupa por dia.
  Widget _intervalTab(List<Transaction> txs) {
    final filtered = (_startDate != null && _endDate != null)
        ? txs.where((t) {
            return !t.date.isBefore(_startDate!) && !t.date.isAfter(_endDate!);
          }).toList()
        : <Transaction>[];
    final data = _groupByDay(filtered, includeMonth: true);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(context, true),
                  child: Text(_startDate == null
                      ? 'Data Início'
                      : '${_startDate!.day.toString().padLeft(2,'0')}/${_startDate!.month.toString().padLeft(2,'0')}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickDate(context, false),
                  child: Text(_endDate == null
                      ? 'Data Fim'
                      : '${_endDate!.day.toString().padLeft(2,'0')}/${_endDate!.month.toString().padLeft(2,'0')}'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Selecione um intervalo válido'))
              : _periodView(data),
        ),
      ],
    );
  }

  /// Aba Mensal: select mês/ano e agrupa por dia.
  Widget _monthlyTab(List<Transaction> txs) {
    final years = txs.map((t) => t.date.year).toSet().toList()..sort();
    final filtered = txs.where((t) =>
        t.date.month == _selectedMonth && t.date.year == _selectedYear).toList();
    final data = _groupByDay(filtered, includeMonth: true);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  items: List.generate(12, (i) => i + 1)
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(_monthName(m)),
                          ))
                      .toList(),
                  onChanged: (m) => setState(() => _selectedMonth = m!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<int>(
                  value: _selectedYear,
                  isExpanded: true,
                  items: years
                      .map((y) => DropdownMenuItem(
                            value: y,
                            child: Text('$y'),
                          ))
                      .toList(),
                  onChanged: (y) => setState(() => _selectedYear = y!),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _periodView(data)),
      ],
    );
  }

  /// Aba Anual: select ano e agrupa por mês.
  Widget _annualTab(List<Transaction> txs) {
    final years = txs.map((t) => t.date.year).toSet().toList()..sort();
    final filtered = txs.where((t) => t.date.year == _selectedYear).toList();
    final data = _groupByMonth(filtered);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButton<int>(
            value: _selectedYear,
            isExpanded: true,
            items: years
                .map((y) => DropdownMenuItem(
                      value: y,
                      child: Text('$y'),
                    ))
                .toList(),
            onChanged: (y) => setState(() => _selectedYear = y!),
          ),
        ),
        Expanded(child: _periodView(data)),
      ],
    );
  }

  /// Combina Saldo, Gráfico de Pizza + Barras
  Widget _periodView(List<_ChartData> data) {
    final totalR = data.fold(0.0, (s, d) => s + d.receipts);
    final totalD = data.fold(0.0, (s, d) => s + d.expenses);
    final balance = totalR - totalD;
    final balanceColor = balance >= 0 ? Colors.green : Colors.red;

    return Column(
      children: [
        const SizedBox(height: 16),
        // Saldo
        Text(
          'Saldo: R\$${balance.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: balanceColor,
          ),
        ),
        const SizedBox(height: 16),
        // Pizza
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: totalR,
                  color: Colors.blue,
                  title: 'R\$${totalR.toStringAsFixed(0)}',
                  radius: 60,
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                PieChartSectionData(
                  value: totalD,
                  color: Colors.red,
                  title: 'R\$${totalD.toStringAsFixed(0)}',
                  radius: 60,
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
              centerSpaceRadius: 30,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            LegendDot(color: Colors.blue, text: 'Receita'),
            SizedBox(width: 16),
            LegendDot(color: Colors.red, text: 'Despesa'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildBarChart(data)),
      ],
    );
  }

  /// Gráfico de Barras colorido
  Widget _buildBarChart(List<_ChartData> data) {
    final maxV = data.isEmpty
        ? 1.0
        : data.map((d) => max(d.receipts, d.expenses)).reduce(max);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const Text('');
                  return Text(data[i].label,
                      style: const TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxV / 5,
                getTitlesWidget: (v, _) =>
                    Text('R\$${v.toInt()}', style: const TextStyle(fontSize: 10)),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: data.asMap().entries.map((e) {
            final d = e.value;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(toY: d.receipts, width: 8, color: Colors.blue),
                BarChartRodData(toY: d.expenses, width: 8, color: Colors.red),
              ],
            );
          }).toList(),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  // ─── Agrupamentos ───────────────────────────────────────────

  List<_ChartData> _groupByDay(List<Transaction> txs,
      {bool includeMonth = false}) {
    final byDay = groupBy<Transaction, int>(txs, (t) => t.date.day);
    return byDay.entries.map((e) {
      final day = e.key;
      final receipts = e.value
          .where((t) => t.type == TransactionType.receipt)
          .fold(0.0, (s, t) => s + t.amount);
      final expenses = e.value
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (s, t) => s + t.amount);
      final label = includeMonth
          ? '${day.toString().padLeft(2,'0')}/${_selectedMonth.toString().padLeft(2,'0')}'
          : '$day';
      return _ChartData(label, receipts, expenses);
    }).toList();
  }

  List<_ChartData> _groupByMonth(List<Transaction> txs) {
    final byMonth = groupBy<Transaction, int>(txs, (t) => t.date.month);
    return byMonth.entries.map((e) {
      final m = e.key;
      final receipts = e.value
          .where((t) => t.type == TransactionType.receipt)
          .fold(0.0, (s, t) => s + t.amount);
      final expenses = e.value
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (s, t) => s + t.amount);
      return _ChartData(_monthName(m), receipts, expenses);
    }).toList();
  }

  String _monthName(int m) {
    const names = [
      '', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return names[m];
  }
}

/// Modelo auxiliar para dados de gráfico
class _ChartData {
  final String label;
  final double receipts;
  final double expenses;
  _ChartData(this.label, this.receipts, this.expenses);
}

/// Legenda de cor
class LegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const LegendDot({required this.color, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
