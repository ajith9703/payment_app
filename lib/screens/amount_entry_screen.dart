import 'package:flutter/material.dart';
import 'payment_details_screen.dart';

class AmountEntryScreen extends StatefulWidget {
  const AmountEntryScreen({super.key});

  @override
  State<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends State<AmountEntryScreen> {
  String amount = '0';

  void _onNumberPressed(String number) {
    setState(() {
      if (amount == '0') {
        amount = number;
      } else {
        if (amount.length < 12) {
          amount += number;
        }
      }
    });
  }

  void _onDecimalPressed() {
    setState(() {
      if (!amount.contains('.')) {
        amount += '.';
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
      } else {
        amount = '0';
      }
    });
  }

  void _onPayPressed() {
    if (amount != '0') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentDetailsScreen(amount: amount),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D632),
      body: Container(
        // Removed gradient to match reference image flat look
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Top Section ---
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 40), // Balance layout
                              Row(
                                children: [
                                  const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      color: Colors.grey[300],
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/profile.jpg',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // --- Amount Section ---
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '\$$amount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 100,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // --- Keypad Section ---
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildKeypadRow(['1', '2', '3']),
                                _buildKeypadRow(['4', '5', '6']),
                                _buildKeypadRow(['7', '8', '9']),
                                _buildKeypadRow(['.', '0', '<']),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- Bottom Action Buttons ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // Pool & Request Buttons Row
                              Row(
                                children: [
                                  // Pool Button
                                  Expanded(
                                    child: _buildActionButton(
                                      label: 'Pool',
                                      color: Colors.white.withOpacity(0.2),
                                      textColor: Colors.white,
                                      onTap: () {}, // Pool logic placeholder
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Request Button
                                  Expanded(
                                    child: _buildActionButton(
                                      label: 'Request',
                                      color: Colors.white.withOpacity(0.2),
                                      textColor: Colors.white,
                                      onTap: () {}, // Request logic placeholder
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Pay Button (Full Width)
                              _buildActionButton(
                                label: 'Pay',
                                color: Colors.black,
                                textColor: Colors.white,
                                onTap: _onPayPressed,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- Bottom Navigation ---
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.attach_money,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.attach_money,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) {
          if (key == '<') {
            return _buildKeypadButton(
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 24,
              ),
              onTap: _onBackspace,
            );
          } else if (key == '.') {
            return _buildKeypadButton(
              child: const Text(
                '.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _onDecimalPressed,
            );
          } else {
            return _buildKeypadButton(
              child: Text(
                key,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => _onNumberPressed(key),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Container(alignment: Alignment.center, child: child),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
