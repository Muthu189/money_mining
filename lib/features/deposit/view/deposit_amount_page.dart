import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import 'package:provider/provider.dart';
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
  final TextEditingController _transactionIdController = TextEditingController();
  File? _screenshot;
  final ImagePicker _picker = ImagePicker();
  bool _isSuccess = false;

  final List<Map<String, dynamic>> _methods = [
    {'name': 'UPI Transfer', 'icon': Icons.qr_code_scanner},
    {'name': 'Bank Transfer (IMPS)', 'icon': Icons.account_balance},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _screenshot = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('$label copied to clipboard');
  }

  void _submitDepositRequest() async {
    final amountString = _amountController.text.trim();
    final utrId = _transactionIdController.text.trim();

    if (amountString.isEmpty) {
      _showSnackBar('Please enter an amount', isError: true);
      return;
    }

    final amount = double.tryParse(amountString);
    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount', isError: true);
      return;
    }

    if (utrId.isEmpty) {
      _showSnackBar('Please enter the UTR / Transaction ID', isError: true);
      return;
    }

    if (_screenshot == null) {
      _showSnackBar('Please upload a screenshot of your payment', isError: true);
      return;
    }

    final viewModel = context.read<PaymentViewModel>();

    final success = await viewModel.createManualDeposit(
      amount: amount.toInt(),
      utrId: utrId,
      screenshot: _screenshot!,
    );

    if (success && mounted) {
      setState(() {
        _isSuccess = true;
      });
      context.read<ProfileViewModel>().fetchUserInfo();
    } else if (mounted) {
      _showSnackBar(viewModel.error ?? 'Failed to submit deposit request', isError: true);
    }
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
        
        const SizedBox(height: 24),
        _buildPaymentDetails(),
        
        const SizedBox(height: 24),
        const Text(
          'UTR ID / Transaction ID',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: '',
          hintText: 'Enter UTR ID or Transaction ID',
          controller: _transactionIdController,
        ),

        const SizedBox(height: 24),
        const Text(
          'Upload Screenshot',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, style: BorderStyle.solid),
            ),
            child: _screenshot != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_screenshot!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload, size: 40, color: AppColors.luxuryGold),
                      const SizedBox(height: 8),
                      Text('Tap to upload payment proof', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
                    ],
                  ),
          ),
        ),
        
        const SizedBox(height: 40),
        
        GradientButton(
          text: 'PROCEED TO PAYMENT',
          onPressed: _submitDepositRequest,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    if (_selectedMethodIndex == 0) {
      // UPI
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UPI ID', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MONEYMINING@KVB', style: AppTextStyles.titleMedium),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.luxuryGold, size: 20),
                  onPressed: () => _copyToClipboard('MONEYMINING@KVB', 'UPI ID'),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // IMPS Placeholder Details
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCopyableDetailRow('Account Number', '1966135000000242'),
            const Divider(color: Colors.white10, height: 24),
            _buildCopyableDetailRow('Beneficiary Name', 'MONEY MINING'),
            const Divider(color: Colors.white10, height: 24),
            _buildCopyableDetailRow('Bank Name', 'Karur Vysya Bank'),
            const Divider(color: Colors.white10, height: 24),
            _buildCopyableDetailRow('IFSC Code', 'KVBL0001966'),
          ],
        ),
      );
    }
  }

  Widget _buildCopyableDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
            const SizedBox(height: 4),
            Text(value, style: AppTextStyles.bodyLarge),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.copy, color: AppColors.luxuryGold, size: 20),
          onPressed: () => _copyToClipboard(value, label),
        ),
      ],
    );
  }

  Widget _buildSuccessInvoice(PaymentViewModel viewModel) {
    final orderId = viewModel.lastOrder?.orderId ?? '';
    final serverMessage = viewModel.lastOrder?.message ?? 'Your deposit request is under review.';
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.check_circle, color: AppColors.successGreen, size: 80),
        const SizedBox(height: 24),
        const Text('Deposit Request Submitted!', style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          serverMessage,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
          textAlign: TextAlign.center,
        ),

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
              if (orderId.isNotEmpty) ...[
                _buildInvoiceRow('Order ID', orderId),
                const Divider(color: Colors.white12, height: 32),
              ],
              _buildInvoiceRow('UTR ID', _transactionIdController.text),
              const Divider(color: Colors.white12, height: 32),
              _buildInvoiceRow('Payment Method', _methods[_selectedMethodIndex]['name']),
              const Divider(color: Colors.white12, height: 32),
              _buildInvoiceRow('Amount Deposited', '₹ ${_amountController.text}', isBold: true),
            ],
          ),
        ),

        const SizedBox(height: 40),

        GradientButton(
          text: 'GO TO DASHBOARD',
          onPressed: () => Navigator.pop(context),
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
