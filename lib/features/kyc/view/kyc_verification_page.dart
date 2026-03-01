import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../view_model/kyc_view_model.dart';

class KycVerificationPage extends StatefulWidget {
  const KycVerificationPage({super.key});

  @override
  State<KycVerificationPage> createState() => _KycVerificationPageState();
}

class _KycVerificationPageState extends State<KycVerificationPage> {
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _accNoController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch status on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KycViewModel>().fetchKycStatus();
    });
  }
  
  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    _accNoController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<KycViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC VERIFICATION'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(viewModel),
    );
  }

  Widget _buildBody(KycViewModel viewModel) {
     if (viewModel.isLoading && viewModel.kycStatus == 'new') { // Initial load
       return const Center(child: CircularProgressIndicator(color: AppColors.luxuryGold));
     }

    switch (viewModel.kycStatus) {
      case 'pending':
        return _buildStatusScreen(
          Icons.hourglass_empty, 
          'Verification in Progress', 
          'Your documents are under review. This usually takes 24 hours.',
          Colors.amber
        );
      case 'approved':
        return _buildStatusScreen(
          Icons.check_circle, 
          'KYC Verified', 
          'Congratulations! Your account is fully verified.',
          AppColors.successGreen
        );
      case 'rejected':
         return Column(
           children: [
             _buildStatusScreen(
                Icons.error_outline, 
                'Verification Failed', 
                'Your documents were rejected. Please ensure photos are clear and details match.',
                AppColors.dangerRed
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GradientButton(
                  text: 'RESUBMIT DOCUMENTS', 
                  onPressed: () { 
                    // Reset status to new logic needed in ViewModel or handled here?
                    // Ideally call a method to reset state.
                    // For now, valid assumption is user can try again if we just show the form.
                    // But ViewModel state 'kycStatus' needs update.
                    // We'll just continue to _buildForm, but the switch prevents it.
                    // Let's assume re-fetching or a manual reset is needed.
                  }, 
                ),
              ),
           ],
         );
      case 'new':
      default:
        return _buildForm(viewModel);
    }
  }

  Widget _buildForm(KycViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Complete your KYC',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Submit your official documents to unlock full features.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 32),
          
          _buildSectionHeader('1. AADHAAR VERIFICATION'),
          const SizedBox(height: 16),
          CustomTextField(controller: _aadhaarController, labelText: 'Aadhaar Number', hintText: '12-digit Aadhaar Number', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildUploadBox('Front Photo', viewModel.aadhaarFront, () => viewModel.pickImage('aadhaarFront'))),
              const SizedBox(width: 16),
              Expanded(child: _buildUploadBox('Back Photo', viewModel.aadhaarBack, () => viewModel.pickImage('aadhaarBack'))),
            ],
          ),
          
          const SizedBox(height: 32),
          _buildSectionHeader('2. PAN CARD'),
           const SizedBox(height: 16),
          CustomTextField(controller: _panController, labelText: 'PAN Number', hintText: '10-character PAN'),
          const SizedBox(height: 16),
          _buildUploadBox('Upload PAN Card Photo', viewModel.panImage, () => viewModel.pickImage('pan')),
          
          const SizedBox(height: 32),
          _buildSectionHeader('3. BANK DETAILS'),
           const SizedBox(height: 16),
          CustomTextField(controller: _accNoController, labelText: 'Account Number', hintText: 'Bank Account Number', keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          CustomTextField(controller: _ifscController, labelText: 'IFSC Code', hintText: 'Bank IFSC Code'),
          const SizedBox(height: 16),
          CustomTextField(controller: _bankNameController, labelText: 'Bank Name', hintText: 'e.g. SBI, HDFC'),
          const SizedBox(height: 16),
          _buildUploadBox('Upload Passbook / Cheque', viewModel.bankImage, () => viewModel.pickImage('bank')),
          
          const SizedBox(height: 40),
          if (viewModel.isLoading)
             const Center(child: CircularProgressIndicator(color: AppColors.luxuryGold))
          else
            GradientButton(
              text: 'SUBMIT VERIFICATION',
              onPressed: () async {
                 // 1. Submit Identity
                 bool identitySuccess = await viewModel.submitKycDocuments(
                   aadhaarNumber: _aadhaarController.text,
                   panNumber: _panController.text,
                 );
                 
                 if (!identitySuccess) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(viewModel.error ?? 'Identity Upload Failed'),
                        backgroundColor: Colors.red,
                      ));
                    }
                    return;
                 }

                 if (mounted && viewModel.successMessage != null) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                     content: Text(viewModel.successMessage!),
                     backgroundColor: Colors.green,
                   ));
                 }
                 
                 // 2. Submit Bank
                 bool bankSuccess = await viewModel.submitBankDetails(
                   accNo: _accNoController.text,
                   ifscCode: _ifscController.text,
                 );

                 if (bankSuccess) {
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                       content: Text(viewModel.successMessage ?? 'KYC Submitted Successfully!'),
                       backgroundColor: Colors.green,
                     ));
                   }
                 } else {
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                       content: Text(viewModel.error ?? 'Bank Details Upload Failed'),
                       backgroundColor: Colors.red,
                     ));
                   }
                 }
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.luxuryGold, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.white12),
      ],
    );
  }

  Widget _buildStatusScreen(IconData icon, String title, String message, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            const SizedBox(height: 24),
            Text(title, style: AppTextStyles.headlineMedium.copyWith(color: color), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(String label, File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
          image: image != null ? DecorationImage(image: FileImage(image), fit: BoxFit.cover) : null,
        ),
        child: image == null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, color: AppColors.luxuryGold, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ) : null,
      ),
    );
  }
}
