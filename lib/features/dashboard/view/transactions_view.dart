import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedYear;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Added ROI tab
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
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                onPressed: () {}, // Handled by dashboard or navigation
              ),
              const Text('Transaction History', style: AppTextStyles.headlineMedium),
              IconButton(
                icon: const Icon(Icons.filter_list, size: 24, color: AppColors.luxuryGold),
                onPressed: _showFilterDialog,
              ),
            ],
          ),
        ),
        
        // Tab Bar
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
              Tab(text: 'All'),
              Tab(text: 'Deposits'),
              Tab(text: 'Withdrawals'),
              Tab(text: 'ROI'), // New Tab
            ],
          ),
        ),
        
        // Filter Chips (Visual Indication)
        if (_selectedMonth != null || _selectedYear != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                if (_selectedYear != null) _buildFilterChip(_selectedYear!, () => setState(() => _selectedYear = null)),
                if (_selectedMonth != null) ...[
                   const SizedBox(width: 8),
                   _buildFilterChip(_selectedMonth!, () => setState(() => _selectedMonth = null)),
                ],
              ],
            ),
          ),
        
        const SizedBox(height: 10),
        
        // List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _TransactionList(year: _selectedYear, month: _selectedMonth),
              _TransactionList(filter: 'Deposit', year: _selectedYear, month: _selectedMonth),
              _TransactionList(filter: 'Withdrawal', year: _selectedYear, month: _selectedMonth),
              _TransactionList(filter: 'ROI', year: _selectedYear, month: _selectedMonth), // ROI View
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
          Text(label, style: const TextStyle(color: AppColors.luxuryGold, fontSize: 12)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.luxuryGold),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Transactions', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 24),
            const Text('Year', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['2023', '2024', '2025'].map((year) => ChoiceChip(
                label: Text(year),
                selected: _selectedYear == year,
                selectedColor: AppColors.luxuryGold,
                onSelected: (selected) {
                  setState(() => _selectedYear = selected ? year : null);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Month', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Jan', 'Feb', 'Aug', 'Sep', 'Oct'].map((month) => ChoiceChip(
                label: Text(month),
                selected: _selectedMonth == month,
                selectedColor: AppColors.luxuryGold,
                onSelected: (selected) {
                  setState(() => _selectedMonth = selected ? month : null);
                  Navigator.pop(context);
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  final String? filter;
  final String? year;
  final String? month;
  
  const _TransactionList({this.filter, this.year, this.month});

  @override
  Widget build(BuildContext context) {
    // Mock Data based on screenshot + New ROI items
    // In real app, date parsing logic would be here. Filter logic simulated below.
    final List<Map<String, dynamic>> allTransactions = [
      {
        'header': 'OCTOBER 2023',
        'year': '2023', 'month': 'Oct',
        'items': [
          {'amount': '+₹ 5,000.00', 'title': 'External Bank Transfer', 'date': 'Oct 24, 2023 • 10:30 AM', 'status': 'COMPLETED', 'type': 'Deposit'},
          {'amount': '-₹ 1,200.00', 'title': 'Vault Withdrawal', 'date': 'Oct 23, 2023 • 02:15 PM', 'status': 'PENDING', 'type': 'Withdrawal'},
          {'amount': '+₹ 25,000.00', 'title': 'Gold Liquidation', 'date': 'Oct 20, 2023 • 09:00 AM', 'status': 'APPROVED', 'type': 'Deposit'},
          {'amount': '+₹ 50.00', 'title': 'Daily Interest', 'date': 'Oct 19, 2023 • 12:00 PM', 'status': 'COMPLETED', 'type': 'ROI'}, // ROI Type
          {'amount': '-₹ 500.00', 'title': 'Service Fee', 'date': 'Oct 15, 2023 • 09:30 AM', 'status': 'COMPLETED', 'type': 'Withdrawal'},
        ]
      },
      {
        'header': 'SEPTEMBER 2023',
        'year': '2023', 'month': 'Sep',
        'items': [
           {'amount': '+₹ 450.00', 'title': 'Daily Interest (ROI)', 'date': 'Sep 29, 2023 • 12:00 PM', 'status': 'COMPLETED', 'type': 'ROI'},
          {'amount': '+₹ 1,000.00', 'title': 'Referral Bonus', 'date': 'Sep 28, 2023 • 04:20 PM', 'status': 'COMPLETED', 'type': 'Deposit'},
          {'amount': '+₹ 100,000.00', 'title': 'Initial Capital', 'date': 'Sep 01, 2023 • 09:00 AM', 'status': 'COMPLETED', 'type': 'Deposit'},
          {'amount': '-₹ 8,450.00', 'title': 'Luxury Asset Purchase', 'date': 'Sep 15, 2023 • 11:45 AM', 'status': 'COMPLETED', 'type': 'Withdrawal'},
        ]
      },
      {
        'header': 'AUGUST 2023',
        'year': '2023', 'month': 'Aug',
        'items': [
          {'amount': '-₹ 1,500.00', 'title': 'Vault Withdrawal', 'date': 'Aug 20, 2023 • 02:22 PM', 'status': 'REJECTED', 'type': 'Withdrawal'},
        ]
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: allTransactions.length + 1, // +1 for placeholder bottom
      itemBuilder: (context, index) {
        if (index == allTransactions.length) {
          // Bottom placeholder icon from screenshot
           return Container(
             padding: const EdgeInsets.only(top: 40, bottom: 20),
             alignment: Alignment.center,
             child: Column(
               children: [
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     border: Border.all(color: AppColors.luxuryGold.withOpacity(0.3)),
                     color: AppColors.luxuryGold.withOpacity(0.1),
                   ),
                   child: const Icon(Icons.account_balance_wallet, color: AppColors.luxuryGold, size: 32),
                 ),
                 const SizedBox(height: 12),
                 Text(
                   'Your gold is waiting to move.',
                   style: AppTextStyles.bodyMedium.copyWith(
                     color: Colors.white24,
                     fontStyle: FontStyle.italic,
                   ),
                 ),
               ],
             ),
           );
        }

        final section = allTransactions[index];
        final sectionYear = section['year'] as String;
        final sectionMonth = section['month'] as String;
        
        // Date Filtering Logic
        if (year != null && sectionYear != year) return const SizedBox.shrink();
        if (month != null && sectionMonth != month) return const SizedBox.shrink();

        final header = section['header'] as String;
        final items = section['items'] as List<Map<String, String>>;
        
        final filteredItems = filter == null ? items : items.where((i) => i['type'] == filter).toList();
        
        if (filteredItems.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                header,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white54,
                ),
              ),
            ),
            ...filteredItems.map((item) => _buildTransactionItem(item)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Map<String, String> item) {
    final type = item['type'];
    final isDeposit = type == 'Deposit';
    final isRoi = type == 'ROI';
    
    Color statusColor;
    Color iconColor;
    IconData iconData;

    switch(item['status']) {
      case 'COMPLETED': 
        statusColor = AppColors.successGreen; 
        break;
      case 'PENDING': 
        statusColor = Colors.amber; 
        break;
      case 'APPROVED': 
        statusColor = Colors.blue; 
        break;
      default: 
        statusColor = Colors.white;
    }
    
    // Icon Logic
    if (isRoi) {
       iconColor = AppColors.luxuryGold;
       iconData = Icons.auto_graph; // Graph for ROI
    } else if (isDeposit) {
      iconColor = AppColors.successGreen;
      iconData = Icons.call_received; // Arrow In
    } else {
      iconColor = Colors.redAccent;
      iconData = Icons.call_made; // Arrow Out
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
         crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['amount']!,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        item['status']!,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['title']!,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
                Text(
                  item['date']!,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
