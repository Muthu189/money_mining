import 'package:flutter/material.dart';
import '../data/withdrawal_repository.dart';

class WithdrawalViewModel extends ChangeNotifier {
  final WithdrawalRepository _withdrawalRepository;

  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  String? _referenceId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  String? get referenceId => _referenceId;

  WithdrawalViewModel(this._withdrawalRepository);

  /// Withdraw Capital — requestMoveWalletAmount
  Future<bool> moveWalletAmount(String amount) async {
    _setLoadingState(true);
    try {
      _successMessage = await _withdrawalRepository.requestMoveWalletAmount(amount);
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
