import 'package:flutter/material.dart';
import 'amount_entry_screen.dart';

class PaymentSuccessfulScreen extends StatelessWidget {
  final String amount;
  final String recipientName;
  final String recipientCashtag;

  const PaymentSuccessfulScreen({
    super.key,
    required this.amount,
    required this.recipientName,
    required this.recipientCashtag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Content
            Column(
              children: [
                const SizedBox(height: 16),

                // Top Bar: Profile Pill & Close Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Spacer to push Close button to the right
                      const Spacer(),

                      // Close Button
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AmountEntryScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Top Content
                const SizedBox(height: 60),

                Padding(
                  // Asymmetric padding to shift the whole block left
                  padding: const EdgeInsets.only(left: 20, right: 60),
                  child: Column(
                    // Left align the checkmark with the text
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Green Checkmark
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00D632),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Success Message
                      Text(
                        'You sent \$$amount to $recipientName',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Spacer to push content up
                const Spacer(),

                // Bottom Spacer to push content up slightly from the very bottom if needed
                const SizedBox(height: 100),
              ],
            ),

            // Bottom "Done" Button
            Positioned(
              left: 24,
              right: 24,
              bottom: 32,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AmountEntryScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
