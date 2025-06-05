// lib/views/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:gestao_salao/views/client/client_form_view.dart';
import 'package:gestao_salao/views/client/client_list_view.dart';
import 'package:gestao_salao/views/expense/expense_form_view.dart';
import 'package:gestao_salao/views/receipts/receipt_form_view.dart';
import 'package:gestao_salao/views/appointments/schedule_form_view.dart';
import 'package:gestao_salao/views/appointments/schedule_list_view.dart';
import '../../widgets/app_header.dart';
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


  void _goToProductForm() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ProductFormView()),
  );

  void _goToProductList() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ProductListView()),
  );

  void _goToServiceForm() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ServiceFormView()),
  );

  void _goToServiceList() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ServiceListView()),
  );

  void _goToScheduleForm() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ScheduleFormView()),
  );

  void _goToScheduleList() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ScheduleListView()),
  );

  void _goToClientForm() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ClientFormView()),
  );

  void _goToClientList() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ClientListView()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Início'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O que deseja fazer?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                childAspectRatio: 0.7,
                children: [
                  GestureDetector(
                    onTap: _goToProductForm,
                    child: const _GridItem(
                      icon: Icons.add_shopping_cart,
                      label: 'Cadastrar\nProduto',
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToServiceForm,
                    child: const _GridItem(
                      icon: Icons.build,
                      label: 'Cadastrar\nServiço',
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToScheduleForm,
                    child: const _GridItem(
                      icon: Icons.schedule,
                      label: 'Agendar\nServiço',
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToClientForm,
                    child: const _GridItem(
                      icon: Icons.person_add,
                      label: 'Cadastrar\nClientes',
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToProductList,
                    child: const _GridItem(
                      icon: Icons.list,
                      label: 'Listar\nProduto',
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToServiceList,
                    child: const _GridItem(
                      icon: Icons.list_alt,
                      label: 'Listar\nServiço',
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToScheduleList,
                    child: const _GridItem(
                      icon: Icons.event_note,
                      label: 'Listar\nAgendamentos',
                    ),
                  ),
                  GestureDetector(
                    onTap: _goToClientList,
                    child: const _GridItem(
                      icon: Icons.people,
                      label: 'Listar\nClientes',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReceiptFormView()),
                  );
                },
                child: const Text('Nova Receita'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExpenseFormView()),
                  );
                },
                child: const Text('Nova Despesa'),
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
  const _GridItem({Key? key, required this.icon, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[300],
          child: Icon(icon, size: 28, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }
}
