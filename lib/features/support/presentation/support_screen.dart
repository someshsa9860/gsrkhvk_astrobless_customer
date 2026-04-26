import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.primary.withValues(alpha: 0.15), c.accent.withValues(alpha: 0.08)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Text('🛎️', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('We\'re here to help',
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Avg response time: under 2 hours',
                          style: tt.labelSmall?.copyWith(color: c.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Quick Actions', style: tt.titleSmall?.copyWith(color: c.textSecondary)),
          const SizedBox(height: 10),

          _SupportTile(
            icon: Icons.add_comment_outlined,
            label: 'Raise a Ticket',
            subtitle: 'Create a new support request',
            color: c.primary,
            onTap: () => _showNewTicketSheet(context, c, tt),
          ).animate().fadeIn(delay: 50.ms),

          _SupportTile(
            icon: Icons.list_alt_outlined,
            label: 'My Tickets',
            subtitle: 'Track your open requests',
            color: c.accent,
            onTap: () => _showTicketList(context, c, tt),
          ).animate().fadeIn(delay: 100.ms),

          _SupportTile(
            icon: Icons.chat_outlined,
            label: 'Live Chat Support',
            subtitle: 'Chat with our support team',
            color: c.success,
            onTap: () {},
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 20),
          Text('FAQ', style: tt.titleSmall?.copyWith(color: c.textSecondary)),
          const SizedBox(height: 10),

          ..._faqs.asMap().entries.map((e) => _FaqTile(
                question: e.value.$1,
                answer: e.value.$2,
              ).animate().fadeIn(delay: Duration(milliseconds: 200 + 50 * e.key))),
        ],
      ),
    );
  }

  void _showNewTicketSheet(BuildContext ctx, AppThemeColors c, TextTheme tt) {
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: c.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Support Ticket', style: tt.titleMedium),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Subject',
                filled: true,
                fillColor: c.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Describe your issue',
                filled: true,
                fillColor: c.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: const Text('Ticket submitted! We\'ll respond within 2 hours.'),
                    backgroundColor: c.success,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: c.primary, foregroundColor: Colors.white),
                child: const Text('Submit Ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketList(BuildContext ctx, AppThemeColors c, TextTheme tt) {
    showModalBottomSheet<void>(
      context: ctx,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Tickets', style: tt.titleMedium),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48, color: c.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 12),
                  Text('No open tickets',
                      style: tt.bodyMedium?.copyWith(color: c.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static const _faqs = [
    ('How do I add money to my wallet?', 'Go to Profile → Wallet → Add Money. We support Razorpay, PhonePe, and UPI.'),
    ('Can I get a refund for a consultation?', 'Yes. If an astrologer disconnects early, the unused balance is refunded within 24 hours.'),
    ('How are astrologers verified?', 'All astrologers undergo KYC verification and a skills test before being listed.'),
    ('What if my call drops during consultation?', 'The billing pauses automatically. You can reconnect within 5 minutes.'),
  ];
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: tt.labelSmall?.copyWith(color: c.textSecondary)),
        trailing: Icon(Icons.chevron_right,
            color: c.textSecondary.withValues(alpha: 0.5), size: 18),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.question,
                        style: tt.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: c.textSecondary,
                    size: 20,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 8),
                Text(widget.answer,
                    style: tt.bodySmall?.copyWith(color: c.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
