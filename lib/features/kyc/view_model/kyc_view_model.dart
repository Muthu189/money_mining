import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_exception.dart';
import '../data/kyc_repository.dart';
import '../data/kyc_detail_model.dart';

class KycViewModel extends ChangeNotifier {
  final KycRepository _kycRepository;

  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // KYC Files — used for new uploads / re-uploads
  File? _aadhaarFront;
  File? _aadhaarBack;
  File? _panImage;

  // Parsed KYC data from API
  KycDetailModel? _kycDetail;

  // Overall page status: 'new' | 'pending' | 'approved' | 'rejected'
  String _kycStatus = 'new';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  File? get aadhaarFront => _aadhaarFront;
  File? get aadhaarBack => _aadhaarBack;
  File? get panImage => _panImage;

  String get kycStatus => _kycStatus;
  KycDetailModel? get kycDetail => _kycDetail;

  // Bank list for spinner
  List<String> _bankList = [];
  String? _selectedBankName;

  List<String> get bankList => _bankList;
  String? get selectedBankName => _selectedBankName;

  void setSelectedBankName(String? name) {
    _selectedBankName = name;
    notifyListeners();
  }

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
      switch (type) {
        case 'aadhaarFront':
          _aadhaarFront = file;
          break;
        case 'aadhaarBack':
          _aadhaarBack = file;
          break;
        case 'pan':
          _panImage = file;
          break;
      }
      notifyListeners();
    }
  }

  Future<bool> submitKycAndBankDetails({
    required String aadhaarNumber,
    required String panNumber,
    required String accNo,
    required String ifscCode,
    required String bankName,
  }) async {
    if (_aadhaarFront == null ||
        _aadhaarBack == null ||
        _panImage == null) {
      _error = 'Please upload all required documents';
      notifyListeners();
      return false;
    }

    // Check file sizes (2MB limit)
    if (!_isFileSizeValid(_aadhaarFront!) ||
        !_isFileSizeValid(_aadhaarBack!) ||
        !_isFileSizeValid(_panImage!)) {
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

      // 2. Submit all Data together
      final response = await _kycRepository.saveKycAndBankDetails(
        aadhaarNumber: aadhaarNumber,
        aadhaarFrontUrl: aadhaarFrontUrl,
        aadhaarBackUrl: aadhaarBackUrl,
        panNumber: panNumber,
        panUrl: panUrl,
        accNo: accNo,
        ifscCode: ifscCode,
        bankName: bankName,
      );

      _successMessage = response.message.isNotEmpty
          ? response.message
          : 'KYC and Bank details submitted successfully!';
      _setLoading(false);
      await fetchKycStatus(); // Refresh status
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

  Future<void> fetchKycStatus() async {
    _setLoading(true);
    try {
      final response = await _kycRepository.getKycStatus();

      if (response.status == 1 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        _kycDetail = KycDetailModel.fromMap(data);

        // Determine overall page status
        if (_kycDetail!.isFullyVerified) {
          _kycStatus = 'approved';
        } else if (_kycDetail!.hasAnyRejection) {
          _kycStatus = 'rejected';
        } else if (_kycDetail!.isFirstSubmission) {
          _kycStatus = 'new';
        } else {
          _kycStatus = 'pending';
        }
      } else {
        // No KYC record found → fresh submission
        _kycDetail = null;
        _kycStatus = 'new';
      }
    } on ApiException catch (e) {
      debugPrint('Error fetching KYC status: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching KYC status: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch bank list for dropdown spinner
  Future<void> fetchBankList() async {
    try {
      _bankList = await _kycRepository.fetchBankList();
      notifyListeners();
    } on ApiException catch (e) {
      debugPrint('Error fetching bank list: ${e.message}');
    } catch (e) {
      debugPrint('Error fetching bank list: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

