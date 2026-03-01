import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  bool _isLoading = false;
  String? _error;
  String? _tempToken; // Token received from login to be used for OTP

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get tempToken => _tempToken;

  AuthViewModel(this._authRepository);

  bool _isEmailVerified = false;
  bool _isMobileVerified = false;
  bool _emailOtpSent = false;
  bool _mobileOtpSent = false;

  bool get isEmailVerified => _isEmailVerified;
  bool get isMobileVerified => _isMobileVerified;
  bool get emailOtpSent => _emailOtpSent;
  bool get mobileOtpSent => _mobileOtpSent;

  // New: Registration with OTPs
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
    try {
      await _authRepository.createAccount(
        username: username,
        email: email,
        mobile: mobile,
        password: password,
        mailOtp: mailOtp,
        mobOtp: mobOtp,
      );
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Signup failed. Please check OTPs.';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendEmailOtp(String email) async {
    _setLoading(true);
    _error = null;
    try {
      await _authRepository.sendEmailOtp(email);
      _emailOtpSent = true;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to send Email OTP';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> sendMobileOtp(String mobile) async {
    _setLoading(true);
    _error = null;
    try {
      await _authRepository.sendMobileOtp(mobile);
      _mobileOtpSent = true;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to send Mobile OTP';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyEmailOtp(String email, String otp) async {
    _setLoading(true);
    _error = null;
    try {
      await _authRepository.verifyEmailOtp(email, otp);
      _isEmailVerified = true;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Invalid Email OTP';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> verifyMobileOtp(String mobile, String otp) async {
    _setLoading(true);
    _error = null;
    try {
      await _authRepository.verifyMobileOtp(mobile, otp);
      _isMobileVerified = true;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Invalid Mobile OTP';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Existing Login Logic
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final token = await _authRepository.login(email: email, password: password);
      _tempToken = token;
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Login failed';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // Existing OTP Verification for Login (2FA)
  Future<bool> verifyLoginOtp(String otp) async {
      return verifyOtp(otp);
  }

  Future<bool> verifyOtp(String otp) async {
     // ... existing implementation
    if (_tempToken == null) {
      _error = "Session expired. Please login again.";
      return false;
    }
    _setLoading(true);
    _error = null;
    try {
      await _authRepository.verifyOtp(token: _tempToken!, otp: otp);
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Invalid OTP';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
