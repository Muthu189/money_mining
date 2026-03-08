class SupportTicket {
  final int id;
  final int userId;
  final String subject;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupportTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      subject: json['subject'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class SupportTicketMessage {
  final int id;
  final int ticketId;
  final String sender;
  final String message;
  final DateTime createdAt;

  SupportTicketMessage({
    required this.id,
    required this.ticketId,
    required this.sender,
    required this.message,
    required this.createdAt,
  });

  factory SupportTicketMessage.fromJson(Map<String, dynamic> json) {
    return SupportTicketMessage(
      id: json['id'] ?? 0,
      ticketId: json['ticket_id'] ?? 0,
      sender: json['sender'] ?? '',
      message: json['message'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
