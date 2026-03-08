import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../view_model/support_view_model.dart';
import '../models/support_ticket_model.dart';

class TicketDetailsPage extends StatefulWidget {
  final int ticketId;
  const TicketDetailsPage({super.key, required this.ticketId});

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportViewModel>().loadTicketDetails(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final success = await context.read<SupportViewModel>().replyTicket(message);
    if (success) {
      _messageController.clear();
      // Scroll to bottom after rebuild
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      if (mounted) {
        final error = context.read<SupportViewModel>().detailsError ?? 'Failed to send reply';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Consumer<SupportViewModel>(
          builder: (context, viewModel, child) {
            final ticket = viewModel.selectedTicket;
            return Text(
              ticket?.subject.toUpperCase() ?? 'TICKET DETAILS',
              style: AppTextStyles.titleMedium,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        centerTitle: true,
      ),
      body: Consumer<SupportViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingDetails) {
            return const Center(child: CircularProgressIndicator(color: AppColors.luxuryGold));
          }

          if (viewModel.detailsError != null && viewModel.messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.detailsError!, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadTicketDetails(widget.ticketId),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.luxuryGold),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final message = viewModel.messages[index];
                    final isUser = message.sender.toLowerCase() == 'user';
                    return _buildMessageBubble(message, isUser);
                  },
                ),
              ),
              _buildMessageInput(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(SupportTicketMessage message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.luxuryGold.withOpacity(0.9) : AppColors.darkGray,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          border: isUser ? null : Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isUser ? Colors.black : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.createdAt.toString().split('.')[0].substring(11, 16),
              style: TextStyle(
                color: isUser ? Colors.black54 : Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(SupportViewModel viewModel) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 10,
        top: 10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: Colors.white24),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          viewModel.isReplying
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.luxuryGold),
                )
              : IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded, color: AppColors.luxuryGold),
                ),
        ],
      ),
    );
  }
}
