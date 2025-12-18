import 'package:flutter/material.dart';

class CashBalanceProvider extends ChangeNotifier {
  double _balance = 100000.0; // Initial balance $100,000

  double get balance => _balance;

  String get formattedBalance {
    return '\$${_balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  bool canAfford(double amount) {
    return amount <= _balance;
  }

  void deductPayment(double amount) {
    if (canAfford(amount)) {
      _balance -= amount;
      notifyListeners();
    }
  }
}
