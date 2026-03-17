import 'package:flutter/material.dart';
import '../../../core/api/api_exception.dart';
import '../data/auth_repository.dart';
import '../../../core/storage/storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final StorageService _storageService;
  
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  String? _tempToken; // Token received from login to be used for OTP

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  String? get tempToken => _tempToken;

  AuthViewModel(this._authRepository, this._storageService);

  bool _isEmailVerified = false;
  bool _isMobileVerified = false;
  bool _emailOtpSent = false;
  bool _mobileOtpSent = false;

  bool get isEmailVerified => _isEmailVerified;
  bool get isMobileVerified => _isMobileVerified;
  bool get emailOtpSent => _emailOtpSent;
  bool get mobileOtpSent => _mobileOtpSent;

  /// Clear messages after they've been shown
  void clearMessages() {
    _error = null;
    _successMessage = null;
  }

  // Registration with OTPs
  Future<bool> createAccount({
    required String username,
    required String email,
    required String mobile,
    required String password,
    required String mailOtp,
    required String mobOtp,
  }) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _authRepository.createAccount(
        username: username,
        email: email,
        mobile: mobile,
        password: password,
        mailOtp: mailOtp,
        mobOtp: mobOtp,
      );
      _successMessage = response.message.isNotEmpty ? response.message : 'Account created successfully!';
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

  Future<bool> sendEmailOtp(String email) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _authRepository.sendEmailOtp(email);
      _emailOtpSent = true;
      _successMessage = response.message.isNotEmpty ? response.message : 'Email OTP sent successfully!';
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

  Future<bool> sendMobileOtp(String mobile) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _authRepository.sendMobileOtp(mobile);
      _mobileOtpSent = true;
      _successMessage = response.message.isNotEmpty ? response.message : 'Mobile OTP sent successfully!';
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

  Future<bool> verifyEmailOtp(String email, String otp) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _authRepository.verifyEmailOtp(email, otp);
      _isEmailVerified = true;
      _successMessage = response.message.isNotEmpty ? response.message : 'Email verified successfully!';
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

  Future<bool> verifyMobileOtp(String mobile, String otp) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _authRepository.verifyMobileOtp(mobile, otp);
      _isMobileVerified = true;
      _successMessage = response.message.isNotEmpty ? response.message : 'Mobile verified successfully!';
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

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      _tempToken = response.raw?['token']?.toString() ?? '';

      print("Success token: $_tempToken");

      _successMessage = response.message.isNotEmpty
          ? response.message
          : 'Login successful!';

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

  // OTP Verification for Login (2FA)
  Future<bool> verifyLoginOtp(String otp) async {
    return verifyOtp(otp);
  }

  Future<bool> verifyOtp(String otp) async {
    if (_tempToken == null) {
      _error = "Session expired. Please login again.";
      notifyListeners();
      return false;
    }
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _authRepository.verifyOtp(token: _tempToken!, otp: otp);
      _successMessage = response.message.isNotEmpty ? response.message : 'OTP verified successfully!';
      
      // Save PIN locally if it exists in the response
      if (response.data is Map<String, dynamic>) {
        final data = response.data;
        if (data['login_pin_status'] == 1 && data['login_pin'] != null) {
          await _storageService.setAppPin(data['login_pin'].toString());
        } else {
          await _storageService.removeAppPin();
        }
      }

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

  // ─── Forgot Password ───

  /// Step 1: Send OTP to email
  Future<bool> sendForgotPasswordOtp(String email) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _authRepository.forgotPassword(email: email, type: 1);
      _successMessage = response.message.isNotEmpty ? response.message : 'OTP sent to email';
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

  /// Step 2: Verify OTP and reset password
  Future<bool> verifyAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      final response = await _authRepository.forgotPassword(
        email: email,
        type: 2,
        otp: otp,
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

