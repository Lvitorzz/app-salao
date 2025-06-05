// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gestao_salao/views/reports/reports_view.dart';
import 'package:gestao_salao/views/transaction/transaction_list_view.dart';
import 'config/firebase_config.dart';
import 'views/home/home_page.dart';
import 'views/products/product_list_view.dart';
import 'views/products/product_form_view.dart';
import 'views/servicos/service_list_view.dart';
import 'views/servicos/service_form_view.dart';
import 'views/client/client_list_view.dart';
import 'views/client/client_form_view.dart';
import 'views/receipts/receipt_form_view.dart';
import 'views/expense/expense_form_view.dart';
import 'views/appointments/schedule_form_view.dart';
import 'views/appointments/schedule_list_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciar Estoque',
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/home',
      routes: {
        '/home': (_) => const HomePage(),
        '/products': (_) => const ProductListView(),
        '/products/form': (_) => const ProductFormView(),
        '/services': (_) => const ServiceListView(),
        '/services/form': (_) => const ServiceFormView(),
        '/clients': (_) => const ClientListView(),
        '/clients/form': (_) => const ClientFormView(),
        '/receipts/form': (_) => const ReceiptFormView(),
        '/expenses/form': (_) => const ExpenseFormView(),
        '/appointments/form': (_) => const ScheduleFormView(),
        '/appointments/list': (_) => const ScheduleListView(),
        '/transactions': (_) => const TransactionListView(),
        '/reports':     (_) => ReportsView(),
      },
    );
  }
}
