import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../data/support_repository.dart';

const _kCategories = [
  ('payment', 'Payment / Wallet'),
  ('consultation', 'Consultation Issue'),
  ('kyc', 'KYC / Verification'),
  ('puja', 'Puja Booking'),
  ('order', 'Order / Delivery'),
  ('general', 'General Query'),
];

class NewTicketScreen extends ConsumerStatefulWidget {
  const NewTicketScreen({super.key});

  @override
  ConsumerState<NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends ConsumerState<NewTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'general';
  bool _submitting = false;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(ticketsNotifierProvider.notifier).createTicket(
            category: _category,
            subject: _subjectCtrl.text.trim(),
            description: _descCtrl.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Ticket submitted! We\'ll respond within 2 hours.'),
          backgroundColor: context.colors.success,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to submit: $e'),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('New Support Ticket'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Category ────────────────────────────────────────────────
            Text('Category', style: tt.labelLarge?.copyWith(color: c.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kCategories.map((cat) {
                final selected = _category == cat.$1;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? c.primary.withValues(alpha: 0.15)
                          : c.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? c.primary : c.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      cat.$2,
                      style: tt.labelMedium?.copyWith(
                        color: selected ? c.primary : c.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Subject ─────────────────────────────────────────────────
            Text('Subject', style: tt.labelLarge?.copyWith(color: c.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectCtrl,
              maxLength: 200,
              style: tt.bodyMedium?.copyWith(color: c.textPrimary),
              decoration: _inputDecoration(c, 'Brief description of your issue'),
              validator: (v) {
                if (v == null || v.trim().length < 5) return 'Please enter at least 5 characters';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Description ─────────────────────────────────────────────
            Text('Description', style: tt.labelLarge?.copyWith(color: c.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 6,
              maxLength: 2000,
              style: tt.bodyMedium?.copyWith(color: c.textPrimary),
              decoration: _inputDecoration(c, 'Describe the issue in detail…'),
              validator: (v) {
                if (v == null || v.trim().length < 10) return 'Please enter at least 10 characters';
                return null;
              },
            ),

            const SizedBox(height: 32),

            // ── Submit ──────────────────────────────────────────────────
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Ticket',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(AppThemeColors c, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: c.textSecondary.withValues(alpha: 0.6)),
      filled: true,
      fillColor: c.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.error),
      ),
    );
  }
}
