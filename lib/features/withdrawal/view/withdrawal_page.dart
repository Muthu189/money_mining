import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';
import 'package:provider/provider.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../view_model/withdrawal_view_model.dart';


class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedBank;
  bool _isWalletWithdraw = false;
  bool _isSubmitted = false;
  
  final List<String> _bankAccounts = [
    'Goldman Sachs Premium •••• 8824',
    'Chase Sapphire Checking •••• 4290',
    'HDFC Bank Priority •••• 1122',
  ];

  @override
  void initState() {
    super.initState();
    _selectedBank = _bankAccounts[0];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['type'] == 'wallet') {
      _isWalletWithdraw = true;
    }
  }

  void _submitWithdrawal() async {
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

    final user = context.read<ProfileViewModel>().user;
    if (user == null) {
      _showSnackBar('Unable to get user balance', isError: true);
      return;
    }

    final maxBalance = _isWalletWithdraw ? user.wallet : user.mainWallet;
    if (amount > maxBalance) {
      _showSnackBar('Insufficient balance', isError: true);
      return;
    }

    final viewModel = context.read<WithdrawalViewModel>();
    bool success;

    if (_isWalletWithdraw) {
      success = await viewModel.withdrawRequest(amountString);
    } else {
      success = await viewModel.moveWalletAmount(amountString);
    }

    if (success && mounted) {
      setState(() {
        _isSubmitted = true;
      });
      // Refresh balance across app
      context.read<ProfileViewModel>().fetchUserInfo();
    } else if (mounted) {
      _showSnackBar(viewModel.error ?? 'Failed to submit request', isError: true);
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
    final title = _isWalletWithdraw ? 'WALLET WITHDRAWAL' : 'DEPOSIT WITHDRAWAL';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: AppColors.luxuryGold, letterSpacing: 1.2)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<WithdrawalViewModel>(
          builder: (context, viewModel, child) {
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: _isSubmitted ? _buildSuccessView(viewModel) : _buildWithdrawForm(),
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

  Widget _buildWithdrawForm() {
    final user = context.watch<ProfileViewModel>().user;
    final balance = user != null 
        ? (_isWalletWithdraw ? user.wallet : user.mainWallet)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isWalletWithdraw ? 'Wallet Balance' : 'Vault Balance', style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 8),
              Text(
                '₹ ${balance.toStringAsFixed(2)}', 
                style: AppTextStyles.displayLarge.copyWith(fontSize: 36, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                   const Icon(Icons.verified, size: 14, color: AppColors.luxuryGold),
                   const SizedBox(width: 8),
                   Text(
                     _isWalletWithdraw ? 'VERIFIED WALLET' : 'VERIFIED MINING ASSETS',
                     style: AppTextStyles.bodySmall.copyWith(
                       color: AppColors.luxuryGold,
                       fontWeight: FontWeight.bold,
                       letterSpacing: 1.5,
                     ),
                   ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Withdrawal Amount
        const Text(
          'Withdrawal Amount',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              const Text('₹', style: TextStyle(color: AppColors.luxuryGold, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _amountController.text = balance.toStringAsFixed(2);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.luxuryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.luxuryGold.withOpacity(0.3)),
                  ),
                  child: const Text('MAX', style: TextStyle(color: AppColors.luxuryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Destination Account
        const Text(
          'Destination Account',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.luxuryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.luxuryGold.withOpacity(0.2)),
              ),
              child: const Icon(Icons.account_balance, color: AppColors.luxuryGold),
            ),
            title: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBank,
                dropdownColor: AppColors.darkGray,
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                isExpanded: true,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBank = newValue;
                  });
                },
                items: _bankAccounts.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            subtitle: const Text('•••• 8824', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ),
        
        const SizedBox(height: 40),
        GradientButton(
          text: _isWalletWithdraw ? 'WITHDRAW NOW' : 'SUBMIT REQUEST',
          onPressed: _submitWithdrawal,
        ),
      ],
    );
  }

  Widget _buildSuccessView(WithdrawalViewModel viewModel) {
    if (_isWalletWithdraw) {
      // Wallet Withdraw Success
      return Column(
        children: [
           const SizedBox(height: 40),
           const Icon(Icons.check_circle, color: AppColors.successGreen, size: 80),
           const SizedBox(height: 24),
           const Text('Withdrawal Successful', style: AppTextStyles.headlineMedium),
           const SizedBox(height: 8),
           Text(viewModel.successMessage ?? 'Your funds have been transferred to your bank account.', style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
           if (viewModel.referenceId != null && viewModel.referenceId!.isNotEmpty) ...[
             const SizedBox(height: 16),
             Text('Ref ID: ${viewModel.referenceId}', style: const TextStyle(color: AppColors.luxuryGold, fontSize: 16)),
           ],
           const SizedBox(height: 40),
           _buildTransactionDetails(isSuccess: true),
           const SizedBox(height: 40),
           GradientButton(text: 'DONE', onPressed: () => Navigator.pop(context)),
        ],
      );
    } else {
      // Deposit Withdraw Request Submitted
      return Column(
        children: [
           const SizedBox(height: 40),
           const Icon(Icons.hourglass_bottom, color: Colors.amber, size: 80),
           const SizedBox(height: 24),
           const Text('Request Submitted', style: AppTextStyles.headlineMedium),
           const SizedBox(height: 8),
           Text(viewModel.successMessage ?? 'Your withdrawal request is under review. Admin approval typically takes 24 hours.', style: const TextStyle(color: Colors.white54), textAlign: TextAlign.center),
           const SizedBox(height: 40),
           _buildTransactionDetails(isSuccess: false),
            const SizedBox(height: 40),
           GradientButton(text: 'BACK TO DASHBOARD', onPressed: () => Navigator.pop(context)),
        ],
      );
    }
  }

  Widget _buildTransactionDetails({required bool isSuccess}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text('Amount', style: TextStyle(color: Colors.white54)),
               Text('₹ ${_amountController.text}', style: const TextStyle(color: AppColors.luxuryGold, fontWeight: FontWeight.bold, fontSize: 18)),
             ],
           ),
           const SizedBox(height: 16),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text('Status', style: TextStyle(color: Colors.white54)),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(
                   color: (isSuccess ? AppColors.successGreen : Colors.amber).withOpacity(0.1),
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: Text(
                   isSuccess ? 'COMPLETED' : 'PENDING',
                   style: TextStyle(
                     color: isSuccess ? AppColors.successGreen : Colors.amber,
                     fontWeight: FontWeight.bold,
                     fontSize: 12
                   ),
                 ),
               ),
             ],
           ),
        ],
      ),
    );
  }
}
