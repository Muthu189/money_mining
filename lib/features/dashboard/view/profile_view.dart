import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes.dart';
import '../../profile/view_model/profile_view_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ProfileViewModel>().fetchUserInfo());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, model, child) {
        if (model.isLoading && model.user == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.luxuryGold));
        }

        final user = model.user;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, color: AppColors.luxuryGold, size: 64),
                const SizedBox(height: 24),
                const Text('Profile Unavailable', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Text('Could not load your profile details.',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: buildGradientButton(
                    text: 'Tap to Retry',
                    onPressed: () => model.fetchUserInfo(),
                    icon: Icons.refresh,
                  ),
                ),
              ],
            ),
          );
        }

        final bool isKycVerified = user.isKycVerified == 1;
        final bool isBankVerified = user.isBankVerified == 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back_ios, size: 20)),
                  const Spacer(),
                  const Text('PROFILE', style: AppTextStyles.titleMedium),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar with Edit
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.luxuryGold, width: 2),
                      boxShadow: [
                        BoxShadow(color: AppColors.luxuryGold.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: (user.profileImg != null && user.profileImg!.isNotEmpty)
                          ? NetworkImage(user.profileImg!)
                          : const NetworkImage('https://i.pravatar.cc/150?img=11'),
                      backgroundColor: Colors.grey,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImagePickerBottomSheet(context, model),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.luxuryGold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: AppColors.matteBlack, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(user.username, style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isKycVerified && isBankVerified ? Icons.verified_user : Icons.gpp_maybe,
                    color: isKycVerified && isBankVerified ? AppColors.luxuryGold : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isKycVerified && isBankVerified ? 'VERIFIED PLATFORM' : 'UNVERIFIED PROFILE',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isKycVerified && isBankVerified ? AppColors.luxuryGold : Colors.orange,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // KYC & Bank Badges
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, Routes.kycVerification),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatusBadge(
                      icon: isKycVerified ? Icons.shield : Icons.shield_outlined,
                      label: isKycVerified ? 'KYC VERIFIED' : 'VERIFY KYC',
                      isVerified: isKycVerified,
                    ),
                    const SizedBox(width: 12),
                    _buildStatusBadge(
                      icon: isBankVerified ? Icons.account_balance : Icons.account_balance_outlined,
                      label: isBankVerified ? 'BANK VERIFIED' : 'VERIFY BANK',
                      isVerified: isBankVerified,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Align(alignment: Alignment.centerLeft, child: Text('PERSONAL INFORMATION', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildListItem(Icons.email, 'EMAIL ADDRESS', user.email),
                    const Divider(color: Colors.white12, height: 1),
                    _buildListItem(Icons.phone_android, 'MOBILE NUMBER', user.mblno),
                    const Divider(color: Colors.white12, height: 1),
                    _buildListItem(Icons.verified_user, 'KYC VERIFICATION', 'Check or update your status', showArrow: true, onTap: () => Navigator.pushNamed(context, Routes.kycVerification)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Align(alignment: Alignment.centerLeft, child: Text('SECURITY & SETTINGS', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkGray,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Refer & Earn Dropdown
                    _buildExpansionItem(
                      Icons.card_giftcard,
                      'Refer & Earn',
                      'Get Gold Bonuses',
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.qr_code_2, size: 150, color: Colors.black),
                          ),
                          const SizedBox(height: 16),
                          Text('Your Promo Code', style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.luxuryGold),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(user.referralCode, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.luxuryGold, fontSize: 18)),
                                const SizedBox(width: 16),
                                const Icon(Icons.copy, color: AppColors.luxuryGold, size: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.share, size: 16),
                                label: const Text('Share Code'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.luxuryGold,
                                  foregroundColor: AppColors.matteBlack,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.white12, height: 1),
                    _buildListItem(Icons.history, 'Change Password', '', showArrow: true, onTap: () => Navigator.pushNamed(context, Routes.changePassword)),
                    const Divider(color: Colors.white12, height: 1),

                    // Security Dropdown
                    _buildListItem(Icons.security, 'Security & Biometrics', 'PIN, Fingerprint', showArrow: true, onTap: () => Navigator.pushNamed(context, Routes.security)),

                    const Divider(color: Colors.white12, height: 1),
                    _buildListItem(Icons.privacy_tip, 'Privacy Policy', '', showArrow: true, onTap: () => Navigator.pushNamed(context, Routes.terms)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Align(alignment: Alignment.centerLeft, child: Text('LOGIN ACTIVITY', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
              // const SizedBox(height: 16),
              // Container(
              //   padding: const EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: AppColors.darkGray,
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: Row(
              //     children: [
              //       const Icon(Icons.smartphone, color: Colors.white54),
              //       const SizedBox(width: 16),
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           const Text('iPhone 14 Pro Max', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              //           Text('Today, 08:30 AM • Mumbai, IN', style: AppTextStyles.bodySmall.copyWith(color: Colors.white38)),
              //         ],
              //       ),
              //       const Spacer(),
              //       const Text('Active', style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 32),

              GradientButton(
                text: 'Logout from Account',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, Routes.auth, (route) => false);
                },
                icon: Icons.logout,
              ),

              const SizedBox(height: 16),

              // OutlinedButton.icon(
              //   onPressed: () {},
              //   icon: const Icon(Icons.delete_forever, color: AppColors.dangerRed),
              //   label: const Text('Delete Account', style: TextStyle(color: AppColors.dangerRed)),
              //   style: OutlinedButton.styleFrom(
              //     side: const BorderSide(color: Colors.white12),
              //     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              //     minimumSize: const Size(double.infinity, 50),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              //   ),
              // ),

              const SizedBox(height: 24),

              Text('MONEYMINING FINTECH V2.4.0', style: AppTextStyles.bodySmall.copyWith(color: Colors.white24)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge({required IconData icon, required String label, required bool isVerified}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isVerified ? AppColors.luxuryGold.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isVerified ? AppColors.luxuryGold.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isVerified ? AppColors.luxuryGold : Colors.orange, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isVerified ? AppColors.luxuryGold : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, String subtitle, {bool showArrow = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Hit test behavior
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.luxuryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.luxuryGold, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
                  if (subtitle.isNotEmpty) Text(subtitle, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            if (showArrow) const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionItem(IconData icon, String title, String subtitle, Widget child) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.luxuryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.luxuryGold, size: 20),
        ),
        title: Text(title, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: AppTextStyles.bodyMedium) : null,
        children: [child],
      ),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, bool value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.luxuryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.luxuryGold, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: AppColors.luxuryGold,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }

  Widget buildGradientButton({required String text, required VoidCallback onPressed, required IconData icon}) {
    return GradientButton(text: text, onPressed: onPressed, icon: icon);
  }

  void _showImagePickerBottomSheet(BuildContext context, ProfileViewModel model) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Update Profile Photo', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 8),
              Text('Choose a source', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await model.pickAndUploadProfileImage(ImageSource.camera);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success
                              ? (model.successMessage ?? 'Profile image updated')
                              : (model.error ?? 'Upload failed')),
                          backgroundColor: success ? AppColors.successGreen : AppColors.dangerRed,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    },
                  ),
                  _buildPickerOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(ctx);
                      final success = await model.pickAndUploadProfileImage(ImageSource.gallery);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success
                              ? (model.successMessage ?? 'Profile image updated')
                              : (model.error ?? 'Upload failed')),
                          backgroundColor: success ? AppColors.successGreen : AppColors.dangerRed,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.luxuryGold.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.luxuryGold.withOpacity(0.3)),
            ),
            child: Icon(icon, color: AppColors.luxuryGold, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

