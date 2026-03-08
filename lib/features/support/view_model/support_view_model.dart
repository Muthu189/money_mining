import 'package:flutter/material.dart';
import '../data/support_repository.dart';
import '../models/support_ticket_model.dart';

class SupportViewModel extends ChangeNotifier {
  final SupportRepository _repository;

  SupportViewModel(this._repository);

  // Ticket List State
  List<SupportTicket> _tickets = [];
  List<SupportTicket> get tickets => _tickets;

  int _pageNo = 1;
  bool _isLoadingTickets = false;
  bool get isLoadingTickets => _isLoadingTickets;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  bool _hasReachedMax = false;
  bool get hasReachedMax => _hasReachedMax;

  String? _listError;
  String? get listError => _listError;

  // Ticket Details State
  SupportTicket? _selectedTicket;
  SupportTicket? get selectedTicket => _selectedTicket;

  List<SupportTicketMessage> _messages = [];
  List<SupportTicketMessage> get messages => _messages;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  String? _detailsError;
  String? get detailsError => _detailsError;

  // Actions State
  bool _isCreatingTicket = false;
  bool get isCreatingTicket => _isCreatingTicket;

  bool _isReplying = false;
  bool get isReplying => _isReplying;

  Future<void> loadInitialTickets() async {
    _isLoadingTickets = true;
    _listError = null;
    _pageNo = 1;
    _hasReachedMax = false;
    notifyListeners();

    try {
      final result = await _repository.fetchTickets(_pageNo);
      _tickets = result.tickets;
      _hasReachedMax = _pageNo >= result.totalPages || result.tickets.isEmpty;
    } catch (e) {
      _listError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingTickets = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreTickets() async {
    if (_isLoadingTickets || _isFetchingMore || _hasReachedMax) return;

    _isFetchingMore = true;
    _listError = null;
    notifyListeners();

    try {
      final nextPage = _pageNo + 1;
      final result = await _repository.fetchTickets(nextPage);

      if (result.tickets.isNotEmpty) {
        _tickets.addAll(result.tickets);
        _pageNo = nextPage;
        _hasReachedMax = nextPage >= result.totalPages;
      } else {
        _hasReachedMax = true;
      }
    } catch (e) {
      _listError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadTicketDetails(int ticketId) async {
    _isLoadingDetails = true;
    _detailsError = null;
    _messages = [];
    notifyListeners();

    try {
      final result = await _repository.fetchTicketDetails(ticketId.toString());
      _selectedTicket = result.ticket;
      _messages = result.messages;
    } catch (e) {
      _detailsError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<bool> createTicket(String subject, String message) async {
    _isCreatingTicket = true;
    notifyListeners();

    try {
      await _repository.createTicket(subject, message);
      await loadInitialTickets(); // Refresh list
      return true;
    } catch (e) {
      _listError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isCreatingTicket = false;
      notifyListeners();
    }
  }

  Future<bool> replyTicket(String message) async {
    if (_selectedTicket == null) return false;

    _isReplying = true;
    notifyListeners();

    try {
      await _repository.replyTicket(_selectedTicket!.id.toString(), message);
      await loadTicketDetails(_selectedTicket!.id); // Refresh messages
      return true;
    } catch (e) {
      _detailsError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isReplying = false;
      notifyListeners();
    }
  }
}
