import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  // Toggle states
  bool _fingerprint = false;
  bool _twoFactor = true;
  bool _pin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SECURITY'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
               const Icon(Icons.security, size: 80, color: AppColors.luxuryGold), // Icon instead of shield image
               const SizedBox(height: 24),
               const Text('MoneyMining', style: AppTextStyles.headlineMedium),
               Text('Ultra-Secure Asset Management', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
               
               const SizedBox(height: 40),
               
               Align(alignment: Alignment.centerLeft, child: Text('BIOMETRICS', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
               const SizedBox(height: 16),
               
               Container(
                 decoration: BoxDecoration(
                   color: AppColors.darkGray,
                   borderRadius: BorderRadius.circular(16),
                 ),
                 child: Column(
                   children: [
                     _buildToggleItem(Icons.fingerprint, 'Fingerprint Login', 'Secondary biometric entry', _fingerprint, (v) => setState(() => _fingerprint = v)),
                   ],
                 ),
               ),
               
               const SizedBox(height: 32),
               
               Align(alignment: Alignment.centerLeft, child: Text('ACCESS CONTROL', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
               const SizedBox(height: 16),
               
                Container(
                 decoration: BoxDecoration(
                   color: AppColors.darkGray,
                   borderRadius: BorderRadius.circular(16),
                 ),
                 child: Column(
                   children: [
                     _buildToggleItem(Icons.shield, 'Two-Factor Authentication', 'Secondary verification code required', _twoFactor, (v) => setState(() => _twoFactor = v)),
                     const Divider(color: Colors.white12, height: 1),
                      _buildToggleItem(Icons.password, 'Transaction PIN', 'Always ask PIN before transfers', _pin, (v) => setState(() => _pin = v)),
                     const Divider(color: Colors.white12, height: 1),
                     ListTile(
                       leading: Container(
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                         child: const Icon(Icons.pin, color: AppColors.luxuryGold, size: 20),
                       ),
                       title: const Text('Change Security PIN', style: AppTextStyles.bodyMedium),
                       subtitle: const Text('Update your 6-digit access code', style: AppTextStyles.bodySmall),
                       trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.luxuryGold),
                       onTap: (){},
                     ),
                   ],
                 ),
               ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
             child: Icon(icon, color: AppColors.luxuryGold, size: 20),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: AppTextStyles.bodyMedium),
                 Text(subtitle, style: AppTextStyles.bodySmall),
               ],
             ),
           ),
           Switch(
             value: value, 
             onChanged: onChanged,
             activeColor: AppColors.luxuryGold,
             inactiveTrackColor: Colors.white10,
           ),
        ],
      ),
    );
  }
}
