import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_exception.dart';
import '../data/kyc_repository.dart';

class KycViewModel extends ChangeNotifier {
  final KycRepository _kycRepository;
  
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  
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
  String? get successMessage => _successMessage;
  
  File? get aadhaarFront => _aadhaarFront;
  File? get aadhaarBack => _aadhaarBack;
  File? get panImage => _panImage;
  File? get bankImage => _bankImage;
  
  String get kycStatus => _kycStatus;
  Map<String, dynamic>? get kycData => _kycData;

  KycViewModel(this._kycRepository);

  /// Clear messages after they've been shown
  void clearMessages() {
    _error = null;
    _successMessage = null;
  }

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


  Future<bool> submitKycAndBankDetails({
    required String aadhaarNumber,
    required String panNumber,
    required String accNo,
    required String ifscCode,
  }) async {
    if (_aadhaarFront == null || _aadhaarBack == null || _panImage == null || _bankImage == null) {
      _error = 'Please upload all required documents';
      notifyListeners();
      return false;
    }

    // Check file sizes (2MB limit)
    if (!_isFileSizeValid(_aadhaarFront!) || !_isFileSizeValid(_aadhaarBack!) || 
        !_isFileSizeValid(_panImage!) || !_isFileSizeValid(_bankImage!)) {
      _error = 'One or more files exceed the 2MB size limit.';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _error = null;
    _successMessage = null;
    try {
      // 1. Upload all Images
      final aadhaarFrontUrl = await _kycRepository.uploadImage(_aadhaarFront!);
      final aadhaarBackUrl = await _kycRepository.uploadImage(_aadhaarBack!);
      final panUrl = await _kycRepository.uploadImage(_panImage!);
      final bankImageUrl = await _kycRepository.uploadImage(_bankImage!);

      // 2. Submit all Data together
      final response = await _kycRepository.saveKycAndBankDetails(
        aadhaarNumber: aadhaarNumber,
        aadhaarFrontUrl: aadhaarFrontUrl,
        aadhaarBackUrl: aadhaarBackUrl,
        panNumber: panNumber,
        panUrl: panUrl,
        accNo: accNo,
        ifscCode: ifscCode,
        bankImageUrl: bankImageUrl,
      );
      
      _successMessage = response.message.isNotEmpty ? response.message : 'KYC and Bank details submitted successfully!';
      _kycStatus = 'pending';
      _fetchKycStatus(); // Refresh status
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

  bool _isFileSizeValid(File file) {
    const int maxBytes = 2 * 1024 * 1024; // 2MB
    return file.lengthSync() <= maxBytes;
  }

  Future<void> _fetchKycStatus() async {
    await fetchKycStatus();
  }

  Future<void> fetchKycStatus() async {
    _setLoading(true);
    try {
      final response = await _kycRepository.getKycStatus();
      if (response.status == 1 && response.data is Map<String, dynamic>) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          _kycData = data;
          
          // Map API status to local status
          // is_kyc_verified: 0=pending/new, 1=verified, 2=rejected? 
          // Based on typical logic: 
          // If both verified -> approved
          // If any is 0 but has data -> pending
          // If no data -> new
          
          final isKycVerified = data['is_kyc_verified'] == 1;
          final isBankVerified = data['is_bank_verified'] == 1;
          
          if (isKycVerified && isBankVerified) {
            _kycStatus = 'approved';
          } else if (data['aadhaar_number'] != null || data['pan_number'] != null) {
            _kycStatus = 'pending';
          } else {
            _kycStatus = 'new';
          }
        }
      }
    } on ApiException catch (e) {
      debugPrint("Error fetching KYC status: ${e.message}");
    } catch (e) {
      debugPrint("Error fetching KYC status: $e");
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
