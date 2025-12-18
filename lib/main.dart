import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/amount_entry_screen.dart';
import 'providers/cash_balance_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CashBalanceProvider(),
      child: const PaymentApp(),
    ),
  );
}

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: const AmountEntryScreen(),
    );
  }
}
