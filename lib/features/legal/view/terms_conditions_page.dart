import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';

class TermsConditionsPage extends StatefulWidget {
  const TermsConditionsPage({super.key});

  @override
  State<TermsConditionsPage> createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Agreement'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Terms & Conditions', style: AppTextStyles.headlineMedium),
                    Text('Effective Date: October 24, 2023', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                    const SizedBox(height: 8),
                    Container(height: 3, width: 40, color: AppColors.luxuryGold),
                    const SizedBox(height: 24),
                    
                    _buildSection('Welcome to MoneyMining', 
                      'These terms and conditions outline the rules and regulations for the use of the MoneyMining Luxury Investment Platform. By accessing this application, we assume you accept these terms and conditions in full.'
                    ),
                    _buildSection('1. Investment Advisory Disclaimer', 
                      'MoneyMining provides a platform for high-net-worth individuals to manage digital assets. All investments carry risks, and past performance is not indicative of future results. We recommend consulting with a certified financial advisor before making significant allocations.'
                    ),
                    _buildSection('2. User Eligibility', 
                      'By using this service, you represent and warrant that you are at least 18 years of age and possess the legal authority to enter into this agreement.'
                    ),
                    _buildSection('3. Intellectual Property', 
                      'The interface, branding, proprietary algorithms, and "Gold-Standard" investment models are the exclusive property of MoneyMining. Any unauthorized replication or reverse engineering of the platform\'s architecture is strictly prohibited.'
                    ),
                     _buildSection('4. Limitation of Liability', 
                      'In no event shall MoneyMining, nor any of its officers, directors, and employees, be held liable for anything arising out of or in any way connected with your use of this Website whether such liability is under contract.'
                    ),
                     _buildSection('5. Data Privacy & Security', 
                      'Your security is our priority. We employ military-grade encryption to protect your assets and personal information. By using the platform, you agree to our data processing policies as outlined in the Privacy Policy section.'
                    ),
                    
                    const SizedBox(height: 100), // Space for bottom sheet
                  ],
                ),
              ),
            ),
            
            // Fixed Bottom Sheet
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.matteBlack,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _accepted, 
                        onChanged: (v) => setState(() => _accepted = v!),
                        activeColor: AppColors.luxuryGold,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      Expanded(
                        child: Text(
                          'I have read and agree to the MoneyMining Master Service Agreement and Risk Disclosure Statement.',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Accept & Continue',
                    onPressed: _accepted ? () {
                      Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard, (route) => false);
                    } : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.luxuryGold, fontWeight: FontWeight.bold),
              children: [
                if (!title.startsWith('Welcome')) 
                   TextSpan(text: '${title.split('. ')[0]}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: title.startsWith('Welcome') ? title : title.split('. ')[1]),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body.replaceAll('MoneyMining', ''), // Just a trick to avoid highlighting if not needed, but here we want normal text
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}
