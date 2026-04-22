import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => context.push('/wallet'),
            tooltip: 'Wallet',
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Consultations'),
            Tab(text: 'Kundli Reports'),
            Tab(text: 'Wallet'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _ConsultationHistory(),
          _KundliReportHistory(),
          _WalletHistory(),
        ],
      ),
    );
  }
}

class _ConsultationHistory extends StatelessWidget {
  const _ConsultationHistory();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💬', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No Consultations Yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Your chat and call consultation history\nwill appear here',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/astrologers'),
            icon: const Icon(Icons.search, size: 16),
            label: const Text('Find Astrologers'),
          ),
        ],
      ),
    );
  }
}

class _KundliReportHistory extends StatelessWidget {
  const _KundliReportHistory();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔮', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No Kundli Reports Yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Create a Kundli profile to generate\nyour personalized birth chart report',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/kundli'),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Create Kundli'),
          ),
        ],
      ),
    );
  }
}

class _WalletHistory extends StatelessWidget {
  const _WalletHistory();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💳', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No Transactions Yet', style: tt.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Add money to your wallet to start\nconsulting with astrologers',
            style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/wallet'),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Money'),
          ),
        ],
      ),
    );
  }
}
