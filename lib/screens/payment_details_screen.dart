import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_successful_screen.dart';
import '../data/users_data.dart';
import '../providers/cash_balance_provider.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String amount;

  const PaymentDetailsScreen({super.key, required this.amount});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late final List<Map<String, dynamic>> allUsers;
  List<Map<String, dynamic>> filteredUsers = [];

  // Recipient state management
  Map<String, dynamic>? _selectedRecipient;
  bool _hasManualSelection = false;

  // Debouncing
  Timer? _debounceTimer;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    allUsers = generateAllUsers(); // Generate 5000 users
    filteredUsers = allUsers.take(10).toList(); // Show top 10 initially
    _toController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear manual selection when user types
    if (_hasManualSelection) {
      setState(() {
        _hasManualSelection = false;
        _selectedRecipient = null;
      });
    }

    // Debounce filtering by 250ms
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _filterUsers();
    });
  }

  void _filterUsers() {
    final query = _toController.text.toLowerCase().trim();

    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        filteredUsers = allUsers.take(10).toList();
      } else {
        filteredUsers = allUsers.where((user) {
          return user['name'].toLowerCase().contains(query) ||
              user['cashtag'].toLowerCase().contains(query);
        }).toList();

        // If no matches found, create a suggestion with the typed name
        if (filteredUsers.isEmpty && query.isNotEmpty) {
          filteredUsers = [
            {
              'name': _toController.text.trim(),
              'cashtag': '',
              'initial': _toController.text.isNotEmpty
                  ? _toController.text[0].toUpperCase()
                  : '?',
              'color': const Color(0xFF00D632),
              'hasStar': false,
              'isNewContact': true,
            },
          ];
        }
      }
    });
  }

  void _selectUserFromSuggestion(int index) {
    final user = filteredUsers[index];
    setState(() {
      _selectedRecipient = user;
      _hasManualSelection = true;
      // Auto-fill the To field with selected user's name
      _toController.removeListener(_onTextChanged);
      _toController.text = user['name'];
      _toController.addListener(_onTextChanged);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _toController.removeListener(_onTextChanged);
    _toController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showPaymentMethodBottomSheet() {
    final paymentAmount = double.tryParse(widget.amount) ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<CashBalanceProvider>(
        builder: (context, balanceProvider, child) {
          final canAfford = balanceProvider.canAfford(paymentAmount);

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'How would you like to fund this payment?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 24),

                // Cash balance option
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00D632),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '\$',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cash balance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${balanceProvider.formattedBalance} available',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF00D632),
                            width: 2,
                          ),
                          color: const Color(0xFF00D632),
                        ),
                        child: const Icon(
                          Icons.circle,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Warning message (only if insufficient balance)
                if (!canAfford)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Your Cash Balance can't cover the full amount. Choose another payment method.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!canAfford) const SizedBox(height: 16),

                // Disabled Debit Card button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Debit Card',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Disabled Continue button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handlePayment() async {
    // Determine the recipient
    final String recipientName;
    final String recipientCashtag;

    if (_hasManualSelection && _selectedRecipient != null) {
      // Use manually selected recipient
      recipientName = _selectedRecipient!['name'];
      recipientCashtag = _selectedRecipient!['cashtag'] ?? '';
    } else if (_toController.text.trim().isNotEmpty) {
      // Use typed name if no selection made
      recipientName = _toController.text.trim();
      recipientCashtag = '';
    } else {
      // No recipient specified
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a recipient name'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final balanceProvider = Provider.of<CashBalanceProvider>(
      context,
      listen: false,
    );
    final paymentAmount = double.tryParse(widget.amount) ?? 0;

    // Check if balance is sufficient
    if (!balanceProvider.canAfford(paymentAmount)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Insufficient balance. Please choose another payment method.',
          ),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Show processing for 4 seconds
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    // Deduct payment from balance
    balanceProvider.deductPayment(paymentAmount);

    // Navigate to success screen with the correct recipient
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessfulScreen(
          amount: widget.amount,
          recipientName: recipientName,
          recipientCashtag: recipientCashtag,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top bar
                _buildTopBar(),

                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // To input field
                              _buildInputField(
                                controller: _toController,
                                label: 'To',
                                hint: 'Name, \$Cashtag, Phone, Email',
                              ),

                              const SizedBox(height: 16),

                              // For input field with plus icon
                              _buildInputFieldWithIcon(
                                controller: _noteController,
                                label: 'For',
                                hint: 'Note (required)',
                              ),

                              const SizedBox(height: 24),

                              // Use section header
                              const Text(
                                'Use',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Cash balance row
                              _buildCashBalanceRow(),

                              const SizedBox(height: 24),

                              // Suggested section
                              const Text(
                                'Suggested',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),

                      // Vertical list of suggested users (Efficient Render)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildUserRow(index),
                            childCount: filteredUsers.length,
                          ),
                        ),
                      ),

                      // Bottom padding for safe area
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    ],
                  ),
                ),

                // Bottom navigation
                _buildBottomNavigation(),
              ],
            ),
          ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF00D632),
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Processing payment...',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, size: 28, color: Colors.black),
          ),

          // Amount
          Text(
            '\$${widget.amount}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // Pay button (enabled when user selected or name typed)
          GestureDetector(
            onTap: (_hasManualSelection || _toController.text.trim().isNotEmpty)
                ? _handlePayment
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color:
                    (_hasManualSelection ||
                        _toController.text.trim().isNotEmpty)
                    ? Colors.black
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Pay',
                style: TextStyle(
                  color:
                      (_hasManualSelection ||
                          _toController.text.trim().isNotEmpty)
                      ? Colors.white
                      : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFieldWithIcon({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Icon(Icons.add_circle_outline, color: Colors.grey[600], size: 22),
        ],
      ),
    );
  }

  Widget _buildCashBalanceRow() {
    return Consumer<CashBalanceProvider>(
      builder: (context, balanceProvider, child) {
        return GestureDetector(
          onTap: _showPaymentMethodBottomSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D632),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cash balance: ${balanceProvider.formattedBalance}',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserRow(int index) {
    final user = filteredUsers[index];
    final isSelected =
        _hasManualSelection &&
        _selectedRecipient != null &&
        _selectedRecipient!['cashtag'] == user['cashtag'];

    // Random accent color for cashtag text (Blue, Purple, Teal, Orange)
    final List<Color> accentColors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.orange,
    ];
    final cashtagColor = accentColors[index % accentColors.length];

    return GestureDetector(
      onTap: () => _selectUserFromSuggestion(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16), // Increased spacing
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[100]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            // Circular Avatar (Random Color Background, White Text)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: user['color'], // Already random from generateAllUsers
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user['initial'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Name and Cashtag Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: const TextStyle(
                      fontSize: 17, // Slightly larger
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user['cashtag'].isNotEmpty)
                    Text(
                      user['cashtag'],
                      style: TextStyle(
                        fontSize: 15,
                        color: cashtagColor, // Random accent color
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            // Radio Select Circle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00D632)
                      : Colors.grey[300]!,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFF00D632)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.attach_money, color: Colors.grey, size: 28),
          const SizedBox(width: 60),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF00D632),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.attach_money,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 60),
          const Icon(Icons.access_time, color: Colors.grey, size: 28),
        ],
      ),
    );
  }
}
