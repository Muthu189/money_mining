import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../data/kyc_repository.dart';

class KycViewModel extends ChangeNotifier {
  final KycRepository _kycRepository;
  
  bool _isLoading = false;
  String? _error;
  
  // KYC Files
  File? _aadhaarFront;
  File? _aadhaarBack;
  File? _panImage;
  File? _bankImage;

  // Status
  String _kycStatus = 'new'; // new, pending, approved, rejected
  Map<String, dynamic>? _kycData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  
  File? get aadhaarFront => _aadhaarFront;
  File? get aadhaarBack => _aadhaarBack;
  File? get panImage => _panImage;
  File? get bankImage => _bankImage;
  
  String get kycStatus => _kycStatus;
  Map<String, dynamic>? get kycData => _kycData;

  KycViewModel(this._kycRepository);

  Future<void> pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      switch(type) {
        case 'aadhaarFront': _aadhaarFront = file; break;
        case 'aadhaarBack': _aadhaarBack = file; break;
        case 'pan': _panImage = file; break;
        case 'bank': _bankImage = file; break;
      }
      notifyListeners();
    }
  }

  Future<bool> submitKycDocuments({
    required String aadhaarNumber,
    required String panNumber,
  }) async {
    if (_aadhaarFront == null || _aadhaarBack == null || _panImage == null) {
      _error = 'Please upload all Identity documents';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;
    try {
      // 1. Upload Images
      final aadhaarFrontUrl = await _kycRepository.uploadImage(_aadhaarFront!);
      final aadhaarBackUrl = await _kycRepository.uploadImage(_aadhaarBack!);
      final panUrl = await _kycRepository.uploadImage(_panImage!);

      // 2. Submit Data
      await _kycRepository.uploadKycDetails(
        aadhaarNumber: aadhaarNumber,
        aadhaarFrontUrl: aadhaarFrontUrl,
        aadhaarBackUrl: aadhaarBackUrl,
        panNumber: panNumber,
        panUrl: panUrl,
      );
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'KYC Upload Failed';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> submitBankDetails({
    required String accNo,
    required String ifscCode,
  }) async {
    if (_bankImage == null) {
      _error = 'Please upload Bank Passbook/Cheque';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;
    try {
      // 1. Upload Image
      final bankImageUrl = await _kycRepository.uploadImage(_bankImage!);

      // 2. Submit Data
      await _kycRepository.addBankDetails(
        accNo: accNo,
        ifscCode: ifscCode,
        bankImageUrl: bankImageUrl,
      );
      // After success -> status = pending verification
      _fetchKycStatus(); // Refresh status
      _kycStatus = 'pending';
      _setLoading(false);
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Bank Details Upload Failed';
      _setLoading(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> _fetchKycStatus() async {
      await fetchKycStatus();
  }

  Future<void> fetchKycStatus() async {
    _setLoading(true);
    try {
      final data = await _kycRepository.getKycStatus();
      _kycData = data;
      // Parse status from data. Assuming 'status' field exists.
      // Adjust based on actual API response structure.
      if (data['status'] != null) {
        _kycStatus = data['status'].toString().toLowerCase();
      }
    } catch (e) {
      // If error (e.g. 404 not found), maybe status is 'new'
      print("Error fetching KYC status: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
