import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../view_model/transaction_view_model.dart';
import 'package:intl/intl.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _selectedYear;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon:
                const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                onPressed: () {},
              ),
              const Text(
                'Transaction History',
                style: AppTextStyles.headlineMedium,
              ),
              // IconButton(
              //   icon: const Icon(Icons.filter_list,
              //       size: 24, color: AppColors.luxuryGold),
              //   onPressed: _showFilterDialog,
              // ),
            ],
          ),
        ),

        /// TAB BAR
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.luxuryGold,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.luxuryGold,
            unselectedLabelColor: Colors.white54,
            dividerColor: Colors.transparent,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Deposit'),
              Tab(text: 'Withdraw'),
              Tab(text: 'ROI'),
              Tab(text: 'Refer'),
              Tab(text: 'Wallet'),
            ],
          ),
        ),

        if (_selectedMonth != null || _selectedYear != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                if (_selectedYear != null)
                  _buildFilterChip(
                      _selectedYear!, () => setState(() => _selectedYear = null)),
                if (_selectedMonth != null) ...[
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      _selectedMonth!, () => setState(() => _selectedMonth = null)),
                ]
              ],
            ),
          ),

        const SizedBox(height: 10),

        /// TAB VIEW
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _TransactionList(apiType: 1),
              _TransactionList(apiType: 2),
              _TransactionList(apiType: 3),
              _TransactionList(apiType: 4),
              _TransactionList(apiType: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.luxuryGold.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.luxuryGold),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.luxuryGold, fontSize: 12)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child:
            const Icon(Icons.close, size: 14, color: AppColors.luxuryGold),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGray,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter Transactions',
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 24),
            const Text('Year', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['2023', '2024', '2025']
                  .map(
                    (year) => ChoiceChip(
                  label: Text(year),
                  selected: _selectedYear == year,
                  selectedColor: AppColors.luxuryGold,
                  onSelected: (selected) {
                    setState(() => _selectedYear = selected ? year : null);
                    Navigator.pop(context);
                  },
                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatefulWidget {
  final int apiType;

  const _TransactionList({required this.apiType});

  @override
  State<_TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<_TransactionList> {
  final ScrollController _scrollController = ScrollController();

  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstLoad) {
        context.read<TransactionViewModel>().loadInitialData(widget.apiType);
        _isFirstLoad = false;
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionViewModel>().fetchMore(widget.apiType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        final state = viewModel.getCategoryState(widget.apiType);

        /// LOADING
        if (state.isLoading && state.transactions.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.luxuryGold));
        }

        /// ERROR
        if (state.error != null && state.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                const Text('Oops! Something went wrong', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Text(state.error!,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54), textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => viewModel.loadInitialData(widget.apiType),
                  icon: const Icon(Icons.refresh, color: AppColors.matteBlack, size: 18),
                  label: const Text('Try Again', style: TextStyle(color: AppColors.matteBlack, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.luxuryGold,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                )
              ],
            ),
          );
        }

        /// EMPTY
        if (state.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 64),
                const SizedBox(height: 16),
                Text(
                  'No transactions found',
                  style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your transaction history will appear here',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                ),
              ],
            )
          );
        }

        return RefreshIndicator(
          color: AppColors.luxuryGold,
          onRefresh: () => viewModel.refreshData(widget.apiType),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount:
            state.transactions.length + (state.isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.transactions.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.luxuryGold),
                  ),
                );
              }

              final transaction = state.transactions[index];

              return _buildTransactionItem(transaction);
            },
          ),
        );
      },
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  Widget _buildTransactionItem(transaction) {
    final isCredit = transaction.isCredit;

    final amountPrefix = isCredit ? '+' : '-';

    final amountString =
        '$amountPrefix₹ ${transaction.amount.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(
            isCredit ? Icons.call_received : Icons.call_made,
            color: isCredit ? AppColors.successGreen : Colors.redAccent,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amountString,
                    style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(transaction.title,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white70)),
                Text(_formatDate(transaction.date),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: Colors.white38, fontSize: 10)),
              ],
            ),
          )
        ],
      ),
    );
  }
}