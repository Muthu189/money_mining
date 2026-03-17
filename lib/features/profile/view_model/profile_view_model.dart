import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/storage/storage_service.dart';
import '../data/profile_repository.dart';
import '../data/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final StorageService _storageService;
  final LocalAuthentication _localAuth = LocalAuthentication();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Fingerprint
  bool _fingerprintEnabled = false;
  bool _canCheckBiometrics = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get fingerprintEnabled => _fingerprintEnabled;
  bool get canCheckBiometrics => _canCheckBiometrics;

  ProfileViewModel(this._profileRepository, this._storageService);

  /// Clear messages after they've been shown
  void clearMessages() {
    _error = null;
    _successMessage = null;
  }

  Future<void> fetchUserInfo() async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _profileRepository.fetchUserInfo();
      // Also load fingerprint preference
      await _loadFingerprintStatus();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  // ─── Change Password ───

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _profileRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _successMessage = response.message.isNotEmpty ? response.message : 'Password updated successfully';
      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Profile Image Upload ───

  Future<bool> pickAndUploadProfileImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile == null) return false;

      final file = File(pickedFile.path);

      // Check file size (2MB limit)
      if (file.lengthSync() > 2 * 1024 * 1024) {
        _error = 'Image size exceeds 2MB limit.';
        notifyListeners();
        return false;
      }

      _setLoading(true);
      _error = null;
      _successMessage = null;

      // 1. Upload image file
      final imageUrl = await _profileRepository.uploadImage(file);

      // 2. Update profile image
      final response = await _profileRepository.updateProfileImage(imageUrl);
      _successMessage = response.message.isNotEmpty ? response.message : 'Profile image updated successfully';

      // 3. Refresh user info to get updated image
      await fetchUserInfo();

      _setLoading(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Security PIN ───

  Future<bool> enablePin(String pin) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _profileRepository.updatePin(type: 1, pin: pin);
      _successMessage = response.message.isNotEmpty ? response.message : 'PIN enabled successfully';
      await _storageService.setAppPin(pin); // Save locally for app lock
      await fetchUserInfo(); // Refresh
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> disablePin(String pin) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _profileRepository.updatePin(type: 2, pin: pin);
      _successMessage = response.message.isNotEmpty ? response.message : 'PIN disabled successfully';
      await _storageService.removeAppPin(); // Remove locally for app lock
      await fetchUserInfo(); // Refresh
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ─── Fingerprint / Biometric ───

  Future<void> _loadFingerprintStatus() async {
    _canCheckBiometrics = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    _fingerprintEnabled = await _storageService.isFingerprintEnabled();
  }

  Future<bool> toggleFingerprint(bool enable) async {
    if (!_canCheckBiometrics) {
      _error = 'Biometric authentication is not available on this device.';
      notifyListeners();
      return false;
    }

    if (enable) {
      // Authenticate first before enabling
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to enable fingerprint login',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );
        if (!authenticated) {
          _error = 'Biometric authentication failed.';
          notifyListeners();
          return false;
        }
      } catch (e) {
        _error = 'Biometric authentication error.';
        notifyListeners();
        return false;
      }
    }

    await _storageService.setFingerprintEnabled(enable);
    _fingerprintEnabled = enable;
    _successMessage = enable ? 'Fingerprint login enabled' : 'Fingerprint login disabled';
    notifyListeners();
    return true;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
