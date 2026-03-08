import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../payment/view_model/payment_view_model.dart';
import '../../profile/view_model/profile_view_model.dart';

class DepositAmountPage extends StatefulWidget {
  const DepositAmountPage({super.key});

  @override
  State<DepositAmountPage> createState() => _DepositAmountPageState();
}

class _DepositAmountPageState extends State<DepositAmountPage> {
  int _selectedMethodIndex = 0;
  final TextEditingController _amountController = TextEditingController();
  bool _isSuccess = false;
  late Razorpay _razorpay;

  // Placeholder key - replace with your actual Razorpay Key ID
  final String _razorpayKey = 'rzp_test_SE3VsHmaMwY3AE';

  final List<Map<String, dynamic>> _methods = [
    {'name': 'Razorpay (UPI, Cards)', 'icon': Icons.payment},
    {'name': 'Bank Transfer (NEFT/IMPS)', 'icon': Icons.account_balance},
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    _amountController.dispose();
    super.dispose();
  }

  void _startRazorpayPayment() {
    final amountString = _amountController.text.trim();
    if (amountString.isEmpty) {
      _showSnackBar('Please enter an amount', isError: true);
      return;
    }

    final amount = double.tryParse(amountString);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount', isError: true);
      return;
    }

    // Razorpay amount is in paise (₹1 = 100 paise)
    final amountInPaise = (amount * 100).toInt();
    
    // Get user details for prefill if available
    final user = context.read<ProfileViewModel>().user;

    var options = {
      'key': _razorpayKey,
      'amount': amountInPaise,
      'name': 'Money Mining',
      'description': 'Deposit to Mining Vault',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': user?.mblno ?? '',
        'email': user?.email ?? ''
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      _showSnackBar('Could not open payment gateway', isError: true);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Payment succeeded on Razorpay.
    // Now call our backend API to create the order and record it.
    
    final amountString = _amountController.text.trim();
    final amount = double.tryParse(amountString) ?? 0.0;
    final amountInPaise = (amount * 100).toInt(); // API expects paise
    
    final viewModel = context.read<PaymentViewModel>();
    final success = await viewModel.createOrder(amount.toInt());

    if (success && mounted) {
      setState(() {
        _isSuccess = true;
      });
      // Refresh user profile to fetch updated balances
      context.read<ProfileViewModel>().fetchUserInfo();
    } else if (mounted) {
      _showSnackBar(viewModel.error ?? 'Failed to record payment on server', isError: true);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showSnackBar('Payment failed: ${response.message ?? 'Unknown error'}', isError: true);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar('External Wallet Selected: ${response.walletName}');
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DEPOSIT FUNDS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<PaymentViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: _isSuccess ? _buildSuccessInvoice(viewModel) : _buildDepositForm(),
                ),
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.luxuryGold),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDepositForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Amount',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: '',
          hintText: '0.00',
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          suffixIcon: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('INR', style: TextStyle(color: AppColors.luxuryGold, fontWeight: FontWeight.bold)),
          ),
        ),
        
        const SizedBox(height: 32),
        
        const Text(
          'Payment Method',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 16),
        ...List.generate(_methods.length, (index) {
          final method = _methods[index];
          final isSelected = _selectedMethodIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedMethodIndex = index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.luxuryGold.withOpacity(0.1) : AppColors.darkGray,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.luxuryGold : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(method['icon'], color: isSelected ? AppColors.luxuryGold : Colors.white54),
                  const SizedBox(width: 16),
                  Text(
                    method['name'],
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.luxuryGold, size: 20),
                ],
              ),
            ),
          );
        }),
        
        const SizedBox(height: 40),
        
        GradientButton(
          text: 'PROCEED TO PAYMENT',
          onPressed: _selectedMethodIndex == 0 ? _startRazorpayPayment : () {
            _showSnackBar('Bank transfer selected - coming soon', isError: true);
          },
        ),
      ],
    );
  }

  Widget _buildSuccessInvoice(PaymentViewModel viewModel) {
    final order = viewModel.order;
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.check_circle, color: AppColors.successGreen, size: 80),
        const SizedBox(height: 24),
        const Text('Deposit Successful!', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 8),
        Text('Your funds have been added to your vault.', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
        
        const SizedBox(height: 40),
        
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              if (order != null) ...[
                _buildInvoiceRow('Order ID', order.id),
                const Divider(color: Colors.white12, height: 32),
              ],
              _buildInvoiceRow('Payment Method', 'Razorpay'),
              const Divider(color: Colors.white12, height: 32),
              _buildInvoiceRow('Amount Deposited', '₹ ${_amountController.text}', isBold: true),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        GradientButton(
          text: 'GO TO DASHBOARD',
          onPressed: () => Navigator.pop(context), // Back to Home
        ),
      ],
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
        Text(
          value, 
          style: AppTextStyles.bodyLarge.copyWith(
            color: isBold ? AppColors.luxuryGold : Colors.white,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}
