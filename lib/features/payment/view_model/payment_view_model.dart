import 'package:flutter/material.dart';
import '../data/payment_repository.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentRepository _paymentRepository;

  bool _isLoading = false;
  String? _error;

  // Manual deposit result
  ManualOrderModel? _lastOrder;

  // Deposit list
  bool _isListLoading = false;
  DepositListResponse? _depositListResponse;
  List<DepositRecord> _depositRecords = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  ManualOrderModel? get lastOrder => _lastOrder;

  bool get isListLoading => _isListLoading;
  DepositListResponse? get depositListResponse => _depositListResponse;
  List<DepositRecord> get depositRecords => _depositRecords;

  PaymentViewModel(this._paymentRepository);

  /// Submits a manual deposit via /payments/createOrder.
  /// Returns true on success, false on failure (check [error]).
  Future<bool> createManualDeposit({
    required int amount,
    required String utrId,
    required dynamic screenshot, // File or path String
  }) async {
    _isLoading = true;
    _error = null;
    _lastOrder = null;
    notifyListeners();
    try {
      final String imagePath =
          screenshot is String ? screenshot : screenshot.path;
      _lastOrder = await _paymentRepository.createManualDeposit(
        amount: amount,
        utrId: utrId,
        imagePath: imagePath,
      );
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches user deposit history. Pass [reset]=true to reload from page 1.
  Future<void> fetchDepositList({
    int pageNo = 1,
    int pageSize = 6,
    int? statusFilter,
    String? search,
    bool reset = false,
  }) async {
    if (reset) {
      _depositRecords = [];
      _depositListResponse = null;
    }
    _isListLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _paymentRepository.getUserDepositList(
        pageNo: pageNo,
        pageSize: pageSize,
        statusFilter: statusFilter,
        search: search,
      );
      _depositListResponse = result;
      if (reset || pageNo == 1) {
        _depositRecords = result.data;
      } else {
        _depositRecords = [..._depositRecords, ...result.data];
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
