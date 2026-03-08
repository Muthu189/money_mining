import '../../../core/api/api_client.dart';
import '../../../core/api/api_config.dart';
import '../models/support_ticket_model.dart';

class TicketListPageResult {
  final List<SupportTicket> tickets;
  final int totalRecords;
  final int totalPages;

  TicketListPageResult({
    required this.tickets,
    required this.totalRecords,
    required this.totalPages,
  });
}

class TicketDetailsResult {
  final SupportTicket ticket;
  final List<SupportTicketMessage> messages;

  TicketDetailsResult({
    required this.ticket,
    required this.messages,
  });
}

class SupportRepository {
  final ApiClient _apiClient;

  SupportRepository(this._apiClient);

  Future<TicketListPageResult> fetchTickets(int pageNo, {int pageSize = 10}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.userTicketList,
        data: {
          'pageNo': pageNo.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final data = response.data;
      if (data['status'] == 1) {
        final items = (data['data'] as List<dynamic>?) ?? [];
        final tickets = items.map((item) => SupportTicket.fromJson(item)).toList();
        return TicketListPageResult(
          tickets: tickets,
          totalRecords: data['totalRecords'] ?? 0,
          totalPages: data['totalPages'] ?? 1,
        );
      } else {
        throw Exception(data['message'] ?? 'Failed to load tickets');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<TicketDetailsResult> fetchTicketDetails(String ticketId) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.ticketDetails,
        data: {
          'ticket_id': ticketId,
        },
      );

      final data = response.data;
      if (data['status'] == 1) {
        final ticket = SupportTicket.fromJson(data['ticket']);
        final messages = (data['messages'] as List<dynamic>?)
                ?.map((m) => SupportTicketMessage.fromJson(m))
                .toList() ??
            [];
        return TicketDetailsResult(ticket: ticket, messages: messages);
      } else {
        throw Exception(data['message'] ?? 'Failed to load ticket details');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<int> createTicket(String subject, String message) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.createTicket,
        data: {
          'subject': subject,
          'message': message,
        },
      );

      final data = response.data;
      if (data['status'] == 1) {
        return data['ticketId'];
      } else {
        throw Exception(data['message'] ?? 'Failed to create ticket');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> replyTicket(String ticketId, String message) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.replyTicket,
        data: {
          'ticket_id': ticketId,
          'message': message,
        },
      );

      final data = response.data;
      if (data['status'] != 1) {
        throw Exception(data['message'] ?? 'Failed to send reply');
      }
    } catch (e) {
      rethrow;
    }
  }
}
