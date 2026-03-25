import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../data/kyc_detail_model.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<KycViewModel>();
      vm.fetchKycStatus();
      vm.fetchBankList();
    });
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    _accNoController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<KycViewModel>();

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      appBar: AppBar(
        backgroundColor: AppColors.matteBlack,
        title: const Text('KYC VERIFICATION'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(viewModel),
    );
  }

  // ─────────────────────────────────────────
  // BODY ROUTER
  // ─────────────────────────────────────────
  Widget _buildBody(KycViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.luxuryGold),
      );
    }

    final detail = viewModel.kycDetail;

    // No data at all → fresh submission form
    if (detail == null || detail.isFirstSubmission) {
      return _buildFullForm(viewModel);
    }

    // Has data → smart section-level view
    return _buildSmartView(viewModel, detail);
  }

  // ─────────────────────────────────────────
  // SMART VIEW (data already submitted)
  // ─────────────────────────────────────────
  Widget _buildSmartView(KycViewModel viewModel, KycDetailModel detail) {
    // Pre-fill text fields for rejected sections so user can edit
    if (detail.isAadhaarRejected && _aadhaarController.text.isEmpty) {
      _aadhaarController.text = detail.aadhaarNumber ?? '';
    }
    if (detail.isPanRejected && _panController.text.isEmpty) {
      _panController.text = detail.panNumber ?? '';
    }
    if (detail.isBankRejected) {
      if (_accNoController.text.isEmpty) {
        _accNoController.text = detail.accNo ?? '';
      }
      if (_ifscController.text.isEmpty) {
        _ifscController.text = detail.ifscCode ?? '';
      }
    }

    final needsResubmit = detail.hasAnyRejection;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top status banner
          _buildOverallBanner(detail),
          const SizedBox(height: 24),

          // AADHAAR section
          _buildSectionHeader('1. AADHAAR CARD'),
          const SizedBox(height: 12),
          _buildAadhaarSection(viewModel, detail),
          const SizedBox(height: 28),

          // PAN section
          _buildSectionHeader('2. PAN CARD'),
          const SizedBox(height: 12),
          _buildPanSection(viewModel, detail),
          const SizedBox(height: 28),

          // BANK section
          _buildSectionHeader('3. BANK DETAILS'),
          const SizedBox(height: 12),
          _buildBankSection(viewModel, detail),
          const SizedBox(height: 40),

          // Submit button — only when resubmission needed
          if (needsResubmit)
            _buildResubmitButton(viewModel, detail),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // OVERALL BANNER
  // ─────────────────────────────────────────
  Widget _buildOverallBanner(KycDetailModel detail) {
    if (detail.isFullyVerified) {
      return _buildBanner(
        icon: Icons.verified,
        title: 'KYC Complete',
        subtitle: 'Your identity has been fully verified.',
        color: AppColors.successGreen,
      );
    } else if (detail.hasAnyRejection) {
      return _buildBanner(
        icon: Icons.error_outline,
        title: 'Action Required',
        subtitle: 'One or more documents were rejected. Please re-upload below.',
        color: AppColors.dangerRed,
      );
    } else {
      return _buildBanner(
        icon: Icons.hourglass_top_rounded,
        title: 'Verification in Progress',
        subtitle: 'Your documents are being reviewed. This usually takes 24 hours.',
        color: Colors.amber,
      );
    }
  }

  Widget _buildBanner({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: color, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style:
                        AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // AADHAAR SECTION
  // ─────────────────────────────────────────
  Widget _buildAadhaarSection(KycViewModel viewModel, KycDetailModel detail) {
    final status = detail.aadhaarStatus;
    final hasData = detail.hasAadhaarData;

    if (!hasData) {
      // No data — show upload UI
      return _buildAadhaarUploadUI(viewModel);
    }

    if (status == 1) {
      // Verified
      return _buildVerifiedSection(children: [
        _buildInfoRow('Aadhaar Number', _maskAadhaar(detail.aadhaarNumber)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _buildNetworkImageTile(
                  'Front', detail.aadhaarFrontImage)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildNetworkImageTile(
                  'Back', detail.aadhaarBackImage)),
        ]),
      ]);
    }

    if (status == 2) {
      // Rejected — show reason + re-upload
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRejectionBanner(detail.aadhaarRejectReason),
          const SizedBox(height: 12),
          _buildAadhaarUploadUI(viewModel),
        ],
      );
    }

    // Pending (status == 0 with data)
    return _buildPendingSection(children: [
      _buildInfoRow('Aadhaar Number', _maskAadhaar(detail.aadhaarNumber)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: _buildNetworkImageTile(
                'Front', detail.aadhaarFrontImage)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildNetworkImageTile(
                'Back', detail.aadhaarBackImage)),
      ]),
    ]);
  }

  Widget _buildAadhaarUploadUI(KycViewModel viewModel) {
    return Column(
      children: [
        CustomTextField(
          controller: _aadhaarController,
          labelText: 'Aadhaar Number',
          hintText: '12-digit Aadhaar Number',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildUploadBox(
                    'Front Photo', viewModel.aadhaarFront,
                    () => viewModel.pickImage('aadhaarFront'))),
            const SizedBox(width: 16),
            Expanded(
                child: _buildUploadBox(
                    'Back Photo', viewModel.aadhaarBack,
                    () => viewModel.pickImage('aadhaarBack'))),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // PAN SECTION
  // ─────────────────────────────────────────
  Widget _buildPanSection(KycViewModel viewModel, KycDetailModel detail) {
    final status = detail.panStatus;
    final hasData = detail.hasPanData;

    if (!hasData) {
      return _buildPanUploadUI(viewModel);
    }

    if (status == 1) {
      return _buildVerifiedSection(children: [
        _buildInfoRow('PAN Number', (detail.panNumber ?? '').toUpperCase()),
        const SizedBox(height: 12),
        _buildNetworkImageTile('PAN Card', detail.panImage),
      ]);
    }

    if (status == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRejectionBanner(detail.panRejectReason),
          const SizedBox(height: 12),
          _buildPanUploadUI(viewModel),
        ],
      );
    }

    // Pending
    return _buildPendingSection(children: [
      _buildInfoRow('PAN Number', (detail.panNumber ?? '').toUpperCase()),
      const SizedBox(height: 12),
      _buildNetworkImageTile('PAN Card', detail.panImage),
    ]);
  }

  Widget _buildPanUploadUI(KycViewModel viewModel) {
    return Column(
      children: [
        CustomTextField(
          controller: _panController,
          labelText: 'PAN Number',
          hintText: '10-character PAN',
        ),
        const SizedBox(height: 16),
        _buildUploadBox('Upload PAN Card Photo', viewModel.panImage,
            () => viewModel.pickImage('pan')),
      ],
    );
  }

  // ─────────────────────────────────────────
  // BANK SECTION
  // ─────────────────────────────────────────
  Widget _buildBankSection(KycViewModel viewModel, KycDetailModel detail) {
    final status = detail.bankStatus;
    final hasData = detail.hasBankData;

    if (!hasData) {
      return _buildBankUploadUI(viewModel);
    }

    if (status == 1) {
      return _buildVerifiedSection(children: [
        _buildInfoRow('Bank Name', detail.bankName ?? viewModel.selectedBankName ?? ''),
        _buildInfoRow('Account Number', _maskAccount(detail.accNo)),
        const SizedBox(height: 8),
        _buildInfoRow('IFSC Code', detail.ifscCode ?? ''),
        const SizedBox(height: 12),
        _buildNetworkImageTile('Passbook / Cheque', detail.bankImage),
      ]);
    }

    if (status == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRejectionBanner(detail.bankRejectReason),
          const SizedBox(height: 12),
          _buildBankUploadUI(viewModel),
        ],
      );
    }

    // Pending
    return _buildPendingSection(children: [
      _buildInfoRow('Bank Name', detail.bankName ?? viewModel.selectedBankName ?? ''),
      _buildInfoRow('Account Number', _maskAccount(detail.accNo)),
      const SizedBox(height: 8),
      _buildInfoRow('IFSC Code', detail.ifscCode ?? ''),
      const SizedBox(height: 12),
      _buildNetworkImageTile('Passbook / Cheque', detail.bankImage),
    ]);
  }

  Widget _buildBankUploadUI(KycViewModel viewModel) {
    return Column(
      children: [
        // Bank Name Dropdown
        if (viewModel.bankList.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BANK NAME',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.softWhite.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: viewModel.selectedBankName,
                dropdownColor: AppColors.darkGray,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Select Bank',
                  filled: true,
                  fillColor: AppColors.darkGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF333333)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF333333)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.luxuryGold),
                  ),
                ),
                style: AppTextStyles.bodyLarge,
                items: viewModel.bankList.map((bank) {
                  return DropdownMenuItem<String>(
                    value: bank,
                    child: Text(bank, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) => viewModel.setSelectedBankName(value),
              ),
              const SizedBox(height: 16),
            ],
          ),
        CustomTextField(
          controller: _accNoController,
          labelText: 'Account Number',
          hintText: 'Bank Account Number',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _ifscController,
          labelText: 'IFSC Code',
          hintText: 'Bank IFSC Code',
        ),

        const SizedBox(height: 16),
        _buildUploadBox('Upload Passbook / Cheque', viewModel.bankImage,
                () => viewModel.pickImage('bank')),
      ],
    );
  }

  // ─────────────────────────────────────────
  // RESUBMIT BUTTON
  // ─────────────────────────────────────────
  Widget _buildResubmitButton(KycViewModel viewModel, KycDetailModel detail) {
    if (viewModel.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.luxuryGold));
    }

    return GradientButton(
      text: 'RESUBMIT DOCUMENTS',
      onPressed: () async {
        // Determine what to send — rejected sections
        final aadhaarNum = detail.isAadhaarRejected
            ? _aadhaarController.text.trim()
            : detail.aadhaarNumber ?? '';
        final panNum = detail.isPanRejected
            ? _panController.text.trim()
            : detail.panNumber ?? '';
        final accNum = detail.isBankRejected
            ? _accNoController.text.trim()
            : detail.accNo ?? '';
        final ifsc = detail.isBankRejected
            ? _ifscController.text.trim()
            : detail.ifscCode ?? '';

        // For rejected sections, ensure files are picked
        if (detail.isAadhaarRejected &&
            (viewModel.aadhaarFront == null || viewModel.aadhaarBack == null)) {
          _showSnack('Please upload Aadhaar front and back photos.', isError: true);
          return;
        }
        if (detail.isBankRejected && viewModel.selectedBankName == null) {
          _showSnack('Please select a bank name.', isError: true);
          return;
        }

        final success = await viewModel.submitKycAndBankDetails(
          aadhaarNumber: aadhaarNum,
          panNumber: panNum,
          accNo: accNum,
          ifscCode: ifsc,
          bankName: viewModel.selectedBankName ?? '',
        );

        if (mounted) {
          _showSnack(
            success
                ? (viewModel.successMessage ??
                    'Documents resubmitted successfully!')
                : (viewModel.error ?? 'Resubmission failed'),
            isError: !success,
          );
        }
      },
    );
  }

  // ─────────────────────────────────────────
  // FULL FORM (first submission)
  // ─────────────────────────────────────────
  Widget _buildFullForm(KycViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Complete your KYC', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Submit your official documents to unlock full features.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 32),

          _buildSectionHeader('1. AADHAAR CARD'),
          const SizedBox(height: 16),
          _buildAadhaarUploadUI(viewModel),

          const SizedBox(height: 32),
          _buildSectionHeader('2. PAN CARD'),
          const SizedBox(height: 16),
          _buildPanUploadUI(viewModel),

          const SizedBox(height: 32),
          _buildSectionHeader('3. BANK DETAILS'),
          const SizedBox(height: 16),
          _buildBankUploadUI(viewModel),

          const SizedBox(height: 40),

          if (viewModel.isLoading)
            const Center(
                child: CircularProgressIndicator(color: AppColors.luxuryGold))
          else
            GradientButton(
              text: 'SUBMIT VERIFICATION',
              onPressed: () async {
                final success = await viewModel.submitKycAndBankDetails(
                  aadhaarNumber: _aadhaarController.text.trim(),
                  panNumber: _panController.text.trim(),
                  accNo: _accNoController.text.trim(),
                  ifscCode: _ifscController.text.trim(),
                  bankName: viewModel.selectedBankName ?? '',
                );
                if (mounted) {
                  _showSnack(
                    success
                        ? (viewModel.successMessage ??
                            'KYC Submitted Successfully!')
                        : (viewModel.error ?? 'Submission Failed'),
                    isError: !success,
                  );
                }
              },
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.luxuryGold, fontWeight: FontWeight.bold)),
        const Divider(color: Colors.white12),
      ],
    );
  }

  Widget _buildVerifiedSection({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.check_circle,
                color: AppColors.successGreen, size: 16),
            const SizedBox(width: 6),
            Text('VERIFIED',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPendingSection({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.hourglass_top_rounded,
                color: Colors.amber, size: 16),
            const SizedBox(width: 6),
            Text('PENDING REVIEW',
                style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ]),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRejectionBanner(String? reason) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dangerRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel, color: AppColors.dangerRed, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Document Rejected',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.dangerRed,
                        fontWeight: FontWeight.bold)),
                if (reason != null &&
                    reason.isNotEmpty &&
                    reason.toLowerCase() != 'null') ...[
                  const SizedBox(height: 4),
                  Text('Reason: $reason',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70)),
                ],
                const SizedBox(height: 4),
                Text('Please upload corrected document below.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
        Expanded(
          child: Text(
            value?.isNotEmpty == true ? value! : '—',
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImageTile(String label, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
        const SizedBox(height: 6),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkGray,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: url != null && url.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, obj, stack) => const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white24, size: 32),
                    ),
                  ),
                )
              : const Center(
                  child: Icon(Icons.image_not_supported,
                      color: Colors.white24, size: 32),
                ),
        ),
      ],
    );
  }

  Widget _buildUploadBox(String label, File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: image != null
                  ? AppColors.luxuryGold.withValues(alpha: 0.5)
                  : Colors.white12),
          image: image != null
              ? DecorationImage(image: FileImage(image), fit: BoxFit.cover)
              : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined,
                      color: AppColors.luxuryGold, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white54),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : null,
      ),
    );
  }

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────
  String _maskAadhaar(String? number) {
    if (number == null || number.length < 4) return number ?? '—';
    return 'XXXX XXXX ${number.substring(number.length - 4)}';
  }

  String _maskAccount(String? number) {
    if (number == null || number.length < 4) return number ?? '—';
    return 'XXXXXXXX${number.substring(number.length - 4)}';
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.dangerRed : AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
