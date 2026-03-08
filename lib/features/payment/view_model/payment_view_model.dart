import 'package:flutter/material.dart';
import '../data/payment_repository.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentRepository _paymentRepository;

  bool _isLoading = false;
  String? _error;
  OrderModel? _order;

  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderModel? get order => _order;

  PaymentViewModel(this._paymentRepository);

  Future<bool> createOrder(int amountInRupees) async {
    _isLoading = true;
    _error = null;
    _order = null;
    notifyListeners();
    try {
      _order = await _paymentRepository.createOrder(amountInRupees);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
