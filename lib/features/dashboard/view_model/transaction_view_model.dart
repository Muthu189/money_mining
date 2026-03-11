import 'package:flutter/material.dart';
import '../data/transaction_repository.dart';
import '../data/transaction_model.dart';

class TransactionCategoryState {
  final int apiType;
  int pageNo = 1;
  bool isLoading = false;
  bool isFetchingMore = false;
  bool hasReachedMax = false;
  List<TransactionModel> transactions = [];
  String? error;

  TransactionCategoryState(this.apiType);
}

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;

  // Track state for the 5 categories
  // 1: Deposit, 2: Withdraw, 3: ROI, 4: Refer, 5: Wallet
  final Map<int, TransactionCategoryState> _categories = {
    1: TransactionCategoryState(1), // Deposit
    2: TransactionCategoryState(2), // Withdraw (Vault)
    3: TransactionCategoryState(3), // ROI (Daily)
    4: TransactionCategoryState(4), // Refer (Bonus)
    5: TransactionCategoryState(5), // Wallet (Withdraw)
  };

  TransactionViewModel(this._repository);

  TransactionCategoryState getCategoryState(int type) => _categories[type]!;

  Future<void> loadInitialData(int type) async {
    final state = _categories[type]!;
    state.isLoading = true;
    state.error = null;
    state.pageNo = 1;
    state.hasReachedMax = false;
    notifyListeners();

    try {
      final result = await _repository.fetchTransactions(type, state.pageNo);
      state.transactions = result.transactions;
      state.hasReachedMax = state.pageNo >= result.totalPages || result.transactions.isEmpty;
    } catch (e) {
      state.error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      state.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshData(int type) async {
    final state = _categories[type]!;
    state.pageNo = 1;
    state.hasReachedMax = false;
    state.error = null;
    
    // Don't show full loading spinner for pull-to-refresh
    
    try {
      final result = await _repository.fetchTransactions(type, state.pageNo);
      state.transactions = result.transactions;
      state.hasReachedMax = state.pageNo >= result.totalPages || result.transactions.isEmpty;
    } catch (e) {
      state.error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMore(int type) async {
    final state = _categories[type]!;
    if (state.isLoading || state.isFetchingMore || state.hasReachedMax) return;

    state.isFetchingMore = true;
    state.error = null;
    notifyListeners();

    try {
      final nextPage = state.pageNo + 1;
      final result = await _repository.fetchTransactions(type, nextPage);
      
      if (result.transactions.isNotEmpty) {
        state.transactions.addAll(result.transactions);
        state.pageNo = nextPage;
        state.hasReachedMax = nextPage >= result.totalPages;
      } else {
        state.hasReachedMax = true;
      }
    } catch (e) {
      state.error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      state.isFetchingMore = false;
      notifyListeners();
    }
  }
}
