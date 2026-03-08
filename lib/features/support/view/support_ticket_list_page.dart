import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../view_model/support_view_model.dart';
import 'create_ticket_page.dart';
import 'ticket_details_page.dart';

class SupportTicketListPage extends StatefulWidget {
  const SupportTicketListPage({super.key});

  @override
  State<SupportTicketListPage> createState() => _SupportTicketListPageState();
}

class _SupportTicketListPageState extends State<SupportTicketListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportViewModel>().loadInitialTickets();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<SupportViewModel>().fetchMoreTickets();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        title: const Text('MY TICKETS', style: AppTextStyles.titleMedium),
        centerTitle: true,
      ),
      body: Consumer<SupportViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoadingTickets) {
            return const Center(child: CircularProgressIndicator(color: AppColors.luxuryGold));
          }

          if (viewModel.listError != null && viewModel.tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.listError!, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadInitialTickets(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.luxuryGold),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text('No tickets found', style: AppTextStyles.bodyLarge.copyWith(color: Colors.white54)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.loadInitialTickets(),
            color: AppColors.luxuryGold,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: viewModel.tickets.length + (viewModel.isFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == viewModel.tickets.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator(color: AppColors.luxuryGold)),
                  );
                }

                final ticket = viewModel.tickets[index];
                return _buildTicketCard(context, ticket);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTicketPage()),
          );
        },
        backgroundColor: AppColors.luxuryGold,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, dynamic ticket) {
    Color statusColor;
    switch (ticket.status.toLowerCase()) {
      case 'open':
        statusColor = Colors.green;
        break;
      case 'closed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = AppColors.luxuryGold;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailsPage(ticketId: ticket.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkGray,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ticket #${ticket.id}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.luxuryGold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.status.toUpperCase(),
                    style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ticket.subject, style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Created on: ${ticket.createdAt.toString().split(' ')[0]}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
