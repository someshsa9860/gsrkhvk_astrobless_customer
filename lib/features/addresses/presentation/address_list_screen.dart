import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../data/addresses_repository.dart';
import '../domain/address_models.dart';
import 'add_address_screen.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;
    final asyncAddresses = ref.watch(addressesNotifierProvider);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        title: const Text('Saved Addresses'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: c.primary),
            onPressed: () => _openAdd(context, ref),
          ),
        ],
      ),
      body: asyncAddresses.when(
        loading: () => Center(child: CircularProgressIndicator(color: c.primary)),
        error: (_, __) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: c.error),
              const SizedBox(height: 12),
              Text('Could not load addresses', style: tt.bodyLarge),
              TextButton(
                onPressed: () => ref.refresh(addressesNotifierProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('📍', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 20),
                  Text('No saved addresses',
                      style: tt.titleMedium?.copyWith(color: c.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Add an address for faster checkout.',
                      style: tt.bodySmall?.copyWith(color: c.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _openAdd(context, ref),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: c.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Address'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _AddressCard(
              address: addresses[i],
              index: i,
              onSetDefault: () => ref
                  .read(addressesNotifierProvider.notifier)
                  .setDefault(addresses[i].id),
              onDelete: () => _confirmDelete(context, ref, addresses[i]),
              onEdit: () => _openEdit(context, ref, addresses[i]),
            ),
          );
        },
      ),
    );
  }

  void _openAdd(BuildContext context, WidgetRef ref) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddAddressScreen()),
    );
    if (added == true) ref.refresh(addressesNotifierProvider);
  }

  void _openEdit(BuildContext context, WidgetRef ref, CustomerAddress address) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => AddAddressScreen(existing: address)),
    );
    if (updated == true) ref.refresh(addressesNotifierProvider);
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, CustomerAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text('Remove "${address.label}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(addressesNotifierProvider.notifier).remove(address.id);
    }
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.index,
    required this.onSetDefault,
    required this.onDelete,
    required this.onEdit,
  });

  final CustomerAddress address;
  final int index;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: address.isDefault
              ? c.primary.withValues(alpha: 0.5)
              : c.border,
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: address.isDefault ? c.primary : c.accent),
              const SizedBox(width: 6),
              Text(address.label,
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: address.isDefault ? c.primary : c.textPrimary,
                  )),
              if (address.isDefault) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Default',
                      style: TextStyle(
                          fontSize: 10,
                          color: c.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'default') onSetDefault();
                  if (v == 'delete') onDelete();
                },
                color: c.card,
                icon: Icon(Icons.more_vert, color: c.textSecondary, size: 18),
                itemBuilder: (_) => [
                  if (!address.isDefault)
                    const PopupMenuItem(
                        value: 'default', child: Text('Set as default')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(address.fullAddress,
              style: tt.bodySmall?.copyWith(color: c.textSecondary)),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 60)).fadeIn().slideY(begin: 0.08);
  }
}
