import 'package:flutter/material.dart';
import '../data/withdrawal_repository.dart';

class WithdrawalViewModel extends ChangeNotifier {
  final WithdrawalRepository _withdrawalRepository;

  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  String? _referenceId;

  // Withdrawal list
  bool _isListLoading = false;
  WithdrawListResponse? _withdrawListResponse;
  List<WithdrawRecord> _withdrawRecords = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  String? get referenceId => _referenceId;

  bool get isListLoading => _isListLoading;
  WithdrawListResponse? get withdrawListResponse => _withdrawListResponse;
  List<WithdrawRecord> get withdrawRecords => _withdrawRecords;

  WithdrawalViewModel(this._withdrawalRepository);

  /// Withdraw Capital — requestMoveWalletAmount
  Future<bool> moveWalletAmount(String amount) async {
    _setLoadingState(true);
    try {
      _successMessage =
          await _withdrawalRepository.requestMoveWalletAmount(amount);
      _referenceId = null;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  /// Wallet Withdrawal — userWithdrawRequest
  Future<bool> withdrawRequest(String amount) async {
    _setLoadingState(true);
    try {
      final result = await _withdrawalRepository.userWithdrawRequest(amount);
      _successMessage = result['message'];
      _referenceId = result['reference_id'];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  /// Fetches paginated withdrawal history. Pass [reset]=true to reload from page 1.
  Future<void> fetchWithdrawList({
    int pageNo = 1,
    int pageSize = 10,
    bool reset = false,
  }) async {
    if (reset) {
      _withdrawRecords = [];
      _withdrawListResponse = null;
    }
    _isListLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _withdrawalRepository.getUserWithdrawList(
        pageNo: pageNo,
        pageSize: pageSize,
      );
      _withdrawListResponse = result;
      if (reset || pageNo == 1) {
        _withdrawRecords = result.data;
      } else {
        _withdrawRecords = [..._withdrawRecords, ...result.data];
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isListLoading = false;
      notifyListeners();
    }
  }

  void clearState() {
    _error = null;
    _successMessage = null;
    _referenceId = null;
    notifyListeners();
  }

  void _setLoadingState(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }
}
