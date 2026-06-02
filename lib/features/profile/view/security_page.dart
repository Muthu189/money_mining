import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../auth/view/create_pin_page.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  @override
  void initState() {
    super.initState();
    // Ensure user info is loaded (for PIN status)
    Future.microtask(() => context.read<ProfileViewModel>().fetchUserInfo());
    _enableSecureScreen();
  }

  Future<void> _enableSecureScreen() async {
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManagerPlus.addFlags(FlutterWindowManagerPlus.FLAG_SECURE);
      }
    } catch (e) {
      debugPrint('Failed to set secure flag: $e');
    }
  }

  @override
  void dispose() {
    _disableSecureScreen();
    super.dispose();
  }

  Future<void> _disableSecureScreen() async {
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
      }
    } catch (e) {
      debugPrint('Failed to clear secure flag: $e');
    }
  }


  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.dangerRed : AppColors.successGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  /// Show PIN entry dialog and return the entered PIN (or null if cancelled)
  Future<String?> _showPinDialog({required String title, required String subtitle}) async {
    final pinController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: Colors.white54)),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(letterSpacing: 12),
              decoration: InputDecoration(
                hintText: '••••',
                hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 12),
                counterText: '',
                filled: true,
                fillColor: AppColors.matteBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.luxuryGold),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.luxuryGold, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final pin = pinController.text.trim();
              if (pin.length == 4) {
                Navigator.pop(ctx, pin);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.luxuryGold,
              foregroundColor: AppColors.matteBlack,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, _) {
        final user = profileVM.user;
        final isPinEnabled = (user?.loginPinStatus ?? 0) == 1;
        final isFingerprintEnabled = profileVM.fingerprintEnabled;

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
            child: profileVM.isLoading && user == null
                ? const Center(child: CircularProgressIndicator(color: AppColors.luxuryGold))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(Icons.security, size: 80, color: AppColors.luxuryGold),
                        const SizedBox(height: 24),
                        const Text('MoneyMining', style: AppTextStyles.headlineMedium),
                        Text('Ultra-Secure Asset Management', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54)),

                        const SizedBox(height: 40),

                        // ─── BIOMETRICS ───
                        Align(alignment: Alignment.centerLeft, child: Text('BIOMETRICS', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildToggleItem(
                                Icons.fingerprint,
                                'Fingerprint Login',
                                profileVM.canCheckBiometrics
                                    ? 'Use biometric to login'
                                    : 'Not available on this device',
                                isFingerprintEnabled,
                                profileVM.canCheckBiometrics
                                    ? (value) async {
                                        if (!value) {
                                          final pin = await _showPinDialog(
                                            title: 'Disable Fingerprint',
                                            subtitle: 'Enter your PIN to disable fingerprint login',
                                          );
                                          if (pin == null) return;
                                          final localPin = await context.read<StorageService>().getAppPin();
                                          if (pin != localPin) {
                                            if (mounted) {
                                              _showSnack('Incorrect PIN. Cannot disable fingerprint.', isError: true);
                                            }
                                            return;
                                          }
                                        }
                                        final success = await profileVM.toggleFingerprint(value);
                                        if (mounted) {
                                          _showSnack(
                                            success
                                                ? (profileVM.successMessage ?? (value ? 'Fingerprint enabled' : 'Fingerprint disabled'))
                                                : (profileVM.error ?? 'Failed'),
                                            isError: !success,
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ─── ACCESS CONTROL ───
                        Align(alignment: Alignment.centerLeft, child: Text('ACCESS CONTROL', style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold))),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.darkGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Transaction PIN toggle
                              _buildToggleItem(
                                Icons.password,
                                'Transaction PIN',
                                isPinEnabled ? 'PIN is active' : 'Set a 4 or 6-digit PIN',
                                isPinEnabled,
                                (value) async {
                                  if (value) {
                                    // Navigate to CreatePinPage to configure PIN
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const CreatePinPage(isReset: true),
                                      ),
                                    );
                                  } else {
                                    // Disable PIN → ask user to enter current PIN
                                    final pin = await _showPinDialog(
                                      title: 'Disable PIN',
                                      subtitle: 'Enter your current PIN to disable',
                                    );
                                    if (pin == null) return;
                                    final success = await profileVM.disablePin(pin);
                                    if (mounted) {
                                      _showSnack(
                                        success
                                            ? (profileVM.successMessage ?? 'PIN disabled')
                                            : (profileVM.error ?? 'Failed'),
                                        isError: !success,
                                      );
                                    }
                                  }
                                },
                              ),
                              const Divider(color: Colors.white12, height: 1),
                              // Change PIN
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.pin, color: AppColors.luxuryGold, size: 20),
                                ),
                                title: const Text('Change Security PIN', style: AppTextStyles.bodyMedium),
                                subtitle: const Text('Update your access code', style: AppTextStyles.bodySmall),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.luxuryGold),
                                onTap: isPinEnabled
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const CreatePinPage(isReset: true),
                                          ),
                                        );
                                      }
                                    : () {
                                        _showSnack('Please enable PIN first', isError: true);
                                      },
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool value, ValueChanged<bool>? onChanged) {
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
