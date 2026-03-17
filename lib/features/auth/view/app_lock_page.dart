import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../routes.dart';

class AppLockPage extends StatefulWidget {
  const AppLockPage({super.key});

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isFingerprintEnabled = false;
  String? _expectedPin;
  String _enteredPin = '';
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadLockSettings();
  }

  Future<void> _loadLockSettings() async {
    final storageService = context.read<StorageService>();
    _isFingerprintEnabled = await storageService.isFingerprintEnabled();
    _expectedPin = await storageService.getAppPin();
    
    // Auto-prompt fingerprint if enabled
    if (_isFingerprintEnabled && mounted) {
      _promptFingerprint();
    }
  }

  Future<void> _promptFingerprint() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access MoneyMining',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated && mounted) {
        _unlock();
      }
    } catch (e) {
      // Ignore errors, allow them to use PIN if biometrics fail or cancel
    }
  }

  void _onKeyPress(String key) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += key;
        _isError = false;
      });
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  void _verifyPin() {
    if (_enteredPin == _expectedPin) {
      _unlock();
    } else {
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
      // Small vibrate could be added here
    }
  }

  void _unlock() {
    Navigator.pushReplacementNamed(context, Routes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    // If no lock is set, skip to dashboard immediately
    if (!_isFingerprintEnabled && (_expectedPin == null || _expectedPin!.isEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _unlock();
      });
      return const Scaffold(backgroundColor: AppColors.matteBlack);
    }

    return Scaffold(
      backgroundColor: AppColors.matteBlack,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Icon(Icons.lock_outline, size: 48, color: AppColors.luxuryGold),
            const SizedBox(height: 16),
            const Text('Enter App PIN', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              _isError ? 'Incorrect PIN, try again' : 'Enter your 4-digit PIN',
              style: AppTextStyles.bodyMedium.copyWith(
                color: _isError ? AppColors.dangerRed : Colors.white54,
              ),
            ),
            const SizedBox(height: 40),
            
            // PIN Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index < _enteredPin.length 
                        ? AppColors.luxuryGold 
                        : AppColors.darkGray,
                    border: Border.all(
                      color: index < _enteredPin.length 
                          ? AppColors.luxuryGold 
                          : Colors.white24,
                    ),
                  ),
                );
              }),
            ),
            
            const Spacer(),
            
            // Keypad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (var j = 1; j <= 3; j++)
                            _buildKey((i * 3 + j).toString(), () => _onKeyPress((i * 3 + j).toString())),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _isFingerprintEnabled
                        ? _buildActionKey(Icons.fingerprint, _promptFingerprint)
                        : const SizedBox(width: 72, height: 72),
                      _buildKey('0', () => _onKeyPress('0')),
                      _buildActionKey(Icons.backspace_outlined, _onBackspace),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
        ),
        child: Text(value, style: AppTextStyles.displayLarge.copyWith(fontSize: 28)),
      ),
    );
  }

  Widget _buildActionKey(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
