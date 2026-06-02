import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../view_model/auth_view_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../../routes.dart';
import 'create_pin_page.dart';

class AppLockPage extends StatefulWidget {
  const AppLockPage({super.key});

  @override
  State<AppLockPage> createState() => _AppLockPageState();
}

class _AppLockPageState extends State<AppLockPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isFingerprintEnabled = false;
  String? _expectedPin;
  int _pinLength = 4;
  String _enteredPin = '';
  bool _isError = false;

  // Lockout State
  int _failedAttempts = 0;
  bool _isLockedOut = false;
  int _lockoutSecondsRemaining = 0;
  Timer? _lockoutTimer;

  static const String _keyFailedAttempts = 'lock_failed_attempts';
  static const String _keyLockoutUntil = 'lock_lockout_until';

  @override
  void initState() {
    super.initState();
    _loadLockSettings();
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

  Future<void> _disableSecureScreen() async {
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManagerPlus.clearFlags(FlutterWindowManagerPlus.FLAG_SECURE);
      }
    } catch (e) {
      debugPrint('Failed to clear secure flag: $e');
    }
  }


  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _disableSecureScreen();
    super.dispose();
  }

  bool _isLoadingSettings = true;

  Future<void> _loadLockSettings() async {
    final storageService = context.read<StorageService>();
    _isFingerprintEnabled = await storageService.isFingerprintEnabled();
    _expectedPin = await storageService.getAppPin();
    _pinLength = _expectedPin?.length ?? 4;

    await _loadLockoutState();

    if (mounted) {
      setState(() {
        _isLoadingSettings = false;
      });
    }

    // Auto-prompt fingerprint if enabled and not locked out
    if (_isFingerprintEnabled && !_isLockedOut && mounted) {
      _promptFingerprint();
    }
  }

  Future<void> _loadLockoutState() async {
    final prefs = await SharedPreferences.getInstance();
    _failedAttempts = prefs.getInt(_keyFailedAttempts) ?? 0;
    final lockoutUntil = prefs.getInt(_keyLockoutUntil) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    if (lockoutUntil > now) {
      _startLockout((lockoutUntil - now) ~/ 1000);
    }
  }

  Future<void> _recordFailedAttempt() async {
    _failedAttempts++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyFailedAttempts, _failedAttempts);

    if (_failedAttempts >= 5) {
      const lockoutDuration = 30; // lock out for 30s
      final lockoutUntil = DateTime.now().millisecondsSinceEpoch + (lockoutDuration * 1000);
      await prefs.setInt(_keyLockoutUntil, lockoutUntil);
      _startLockout(lockoutDuration);
    }
  }

  Future<void> _clearFailedAttempts() async {
    _failedAttempts = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFailedAttempts);
    await prefs.remove(_keyLockoutUntil);
  }

  void _startLockout(int seconds) {
    setState(() {
      _isLockedOut = true;
      _lockoutSecondsRemaining = seconds;
      _enteredPin = '';
    });
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_lockoutSecondsRemaining > 1) {
          _lockoutSecondsRemaining--;
        } else {
          _isLockedOut = false;
          _failedAttempts = 0;
          _lockoutTimer?.cancel();
          _clearFailedAttempts();
          // Auto-prompt fingerprint on unlock if enabled
          if (_isFingerprintEnabled) {
            _promptFingerprint();
          }
        }
      });
    });
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
      // Ignore errors, allow they to use PIN if biometrics fail or cancel
    }
  }

  void _onKeyPress(String key) {
    if (_isLockedOut) return;

    if (_enteredPin.length < _pinLength) {
      setState(() {
        _enteredPin += key;
        _isError = false;
      });
      if (_enteredPin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_isLockedOut) return;

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
      _recordFailedAttempt();
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
    }
  }

  void _unlock() {
    _clearFailedAttempts();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.pushReplacementNamed(context, Routes.dashboard);
    }
  }

  void _handleForgotPin() {
    final profileVM = context.read<ProfileViewModel>();
    final email = profileVM.user?.email;

    if (email == null || email.isEmpty) {
      _showReauthDialog(askEmail: true);
    } else {
      _showReauthDialog(askEmail: false, email: email);
    }
  }

  void _showReauthDialog({required bool askEmail, String? email}) {
    final emailController = TextEditingController(text: email);
    final passwordController = TextEditingController();
    bool dialogLoading = false;
    String? dialogError;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.darkGray,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Verify Identity', style: AppTextStyles.headlineMedium),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter your account password to verify your identity and reset your PIN.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (askEmail) ...[
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.luxuryGold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.luxuryGold)),
                  ),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    dialogError!,
                    style: const TextStyle(color: AppColors.dangerRed, fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: dialogLoading ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: dialogLoading
                    ? null
                    : () async {
                        final enteredEmail = emailController.text.trim();
                        final enteredPassword = passwordController.text.trim();

                        if (enteredEmail.isEmpty || enteredPassword.isEmpty) {
                          setDialogState(() {
                            dialogError = 'Please fill all fields';
                          });
                          return;
                        }

                        setDialogState(() {
                          dialogLoading = true;
                          dialogError = null;
                        });

                        final authVM = context.read<AuthViewModel>();
                        final success = await authVM.login(email: enteredEmail, password: enteredPassword);

                        if (!mounted) return;

                        if (success) {
                          Navigator.pop(ctx); // Close dialog
                          // Redirect to CreatePinPage to reset PIN
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreatePinPage(isReset: true),
                            ),
                          );
                        } else {
                          setDialogState(() {
                            dialogLoading = false;
                            dialogError = authVM.error ?? 'Invalid password or verification failed.';
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.luxuryGold,
                  foregroundColor: AppColors.matteBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: dialogLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Verify'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSettings) {
      return const Scaffold(
        backgroundColor: AppColors.matteBlack,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.luxuryGold),
        ),
      );
    }

    // If no PIN is set, redirect to CreatePinPage immediately
    if (_expectedPin == null || _expectedPin!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, Routes.createPin);
      });
      return const Scaffold(backgroundColor: AppColors.matteBlack);
    }

    String message = 'Enter your $_pinLength-digit PIN';
    if (_isLockedOut) {
      message = 'Too many attempts. Wait $_lockoutSecondsRemaining seconds';
    } else if (_isError) {
      message = 'Incorrect PIN, try again';
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: (_isError || _isLockedOut) ? AppColors.dangerRed : Colors.white54,
                ),
              ),
              const SizedBox(height: 40),

              // PIN Dots (dynamic size)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
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
                              _buildKey(
                                (i * 3 + j).toString(),
                                _isLockedOut ? null : () => _onKeyPress((i * 3 + j).toString()),
                              ),
                          ],
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _isFingerprintEnabled
                            ? _buildActionKey(Icons.fingerprint, _isLockedOut ? null : _promptFingerprint)
                            : const SizedBox(width: 72, height: 72),
                        _buildKey('0', _isLockedOut ? null : () => _onKeyPress('0')),
                        _buildActionKey(Icons.backspace_outlined, _isLockedOut ? null : _onBackspace),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),
              TextButton(
                onPressed: _handleForgotPin,
                child: const Text(
                  'Forgot PIN?',
                  style: TextStyle(
                    color: AppColors.luxuryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String value, VoidCallback? onTap) {
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
        child: Text(
          value,
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 28,
            color: onTap == null ? Colors.white24 : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 72,
        height: 72,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: onTap == null ? Colors.white24 : Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
