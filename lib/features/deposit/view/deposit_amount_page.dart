import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';

class DepositAmountPage extends StatefulWidget {
  const DepositAmountPage({super.key});

  @override
  State<DepositAmountPage> createState() => _DepositAmountPageState();
}

class _DepositAmountPageState extends State<DepositAmountPage> {
  int _selectedMethodIndex = 0;
  final TextEditingController _amountController = TextEditingController();
  bool _isSuccess = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _methods = [
    {'name': 'Razorpay (UPI, Cards)', 'icon': Icons.payment},
    {'name': 'Bank Transfer (NEFT/IMPS)', 'icon': Icons.account_balance},
  ];

  void _processDeposit() async {
    setState(() => _isLoading = true);
    // Simulate Razorpay Delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isSuccess ? _buildSuccessInvoice() : _buildDepositForm(),
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
          text: _isLoading ? 'PROCESSING...' : 'DEPOSIT + CONTINUE',
          onPressed: _isLoading ? () {} : _processDeposit,
        ),
      ],
    );
  }

  Widget _buildSuccessInvoice() {
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
              _buildInvoiceRow('Transaction ID', 'TXN55998822'),
              const Divider(color: Colors.white12, height: 32),
              _buildInvoiceRow('Date', 'Oct 25, 2023, 10:30 AM'),
              const Divider(color: Colors.white12, height: 32),
              _buildInvoiceRow('Payment Method', 'Razorpay UPI'),
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
