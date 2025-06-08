// lib/views/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:gestao_salao/views/client/client_form_view.dart';
import 'package:gestao_salao/views/client/client_list_view.dart';
import 'package:gestao_salao/views/expense/expense_form_view.dart';
import 'package:gestao_salao/views/receipts/receipt_form_view.dart';
import 'package:gestao_salao/views/appointments/schedule_form_view.dart';
import 'package:gestao_salao/views/appointments/schedule_list_view.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../products/product_list_view.dart';
import '../products/product_form_view.dart';
import '../servicos/service_list_view.dart';
import '../servicos/service_form_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;

  void _goToProductForm()   => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormView()));
  void _goToProductList()   => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListView()));
  void _goToServiceForm()   => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceFormView()));
  void _goToServiceList()   => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceListView()));
  void _goToScheduleForm()  => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleFormView()));
  void _goToScheduleList()  => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScheduleListView()));
  void _goToClientForm()    => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientFormView()));
  void _goToClientList()    => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientListView()));
  void _goToReceiptForm()   => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReceiptFormView()));
  void _goToExpenseForm()   => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseFormView()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E7C4),
      appBar: AppBar(
        automaticallyImplyLeading: false,  // ← remove o botão de voltar
        backgroundColor: const Color(0xFF732027),
        centerTitle: true,
        title: const Text(
          'Início',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O que deseja fazer?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF591E18),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                childAspectRatio: 0.7,
                children: [
                  _GridItem(
                    icon: Icons.add_shopping_cart,
                    label: 'Cadastrar\nProduto',
                    onTap: _goToProductForm,
                  ),
                  _GridItem(
                    icon: Icons.build,
                    label: 'Cadastrar\nServiço',
                    onTap: _goToServiceForm,
                  ),
                  _GridItem(
                    icon: Icons.schedule,
                    label: 'Agendar\nServiço',
                    onTap: _goToScheduleForm,
                  ),
                  _GridItem(
                    icon: Icons.person_add,
                    label: 'Cadastrar\nClientes',
                    onTap: _goToClientForm,
                  ),
                  _GridItem(
                    icon: Icons.list,
                    label: 'Listar\nProduto',
                    onTap: _goToProductList,
                  ),
                  _GridItem(
                    icon: Icons.list_alt,
                    label: 'Listar\nServiço',
                    onTap: _goToServiceList,
                  ),
                  _GridItem(
                    icon: Icons.event_note,
                    label: 'Listar\nAgendamentos',
                    onTap: _goToScheduleList,
                  ),
                  _GridItem(
                    icon: Icons.people,
                    label: 'Listar\nClientes',
                    onTap: _goToClientList,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
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
                onPressed: _goToReceiptForm,
                child: const Text(
                  'Nova Receita',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA67C6D),
                  foregroundColor: const Color(0xFFF2E7C4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _goToExpenseForm,
                child: const Text(
                  'Nova Despesa',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GridItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: const Color(0xFF732027).withOpacity(0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF2D4C2),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 28, color: const Color(0xFF732027)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF591E18),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
