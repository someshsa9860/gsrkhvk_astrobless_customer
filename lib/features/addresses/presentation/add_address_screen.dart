import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../data/addresses_repository.dart';
import '../domain/address_models.dart';

const _kLabels = ['Home', 'Work', 'Other'];

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key, this.existing});
  final CustomerAddress? existing;

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _line2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late String _label;
  late bool _isDefault;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _label = e?.label ?? 'Home';
    _line1Ctrl = TextEditingController(text: e?.line1 ?? '');
    _line2Ctrl = TextEditingController(text: e?.line2 ?? '');
    _cityCtrl = TextEditingController(text: e?.city ?? '');
    _stateCtrl = TextEditingController(text: e?.state ?? '');
    _pincodeCtrl = TextEditingController(text: e?.pincode ?? '');
    _isDefault = e?.isDefault ?? false;
  }

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existing != null;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await ref.read(addressesRepositoryProvider).updateAddress(
          widget.existing!.id,
          {
            'label': _label,
            'line1': _line1Ctrl.text.trim(),
            'line2': _line2Ctrl.text.trim().isEmpty ? null : _line2Ctrl.text.trim(),
            'city': _cityCtrl.text.trim(),
            'state': _stateCtrl.text.trim(),
            'pincode': _pincodeCtrl.text.trim(),
            'isDefault': _isDefault,
          },
        );
      } else {
        await ref.read(addressesNotifierProvider.notifier).add(
              label: _label,
              line1: _line1Ctrl.text.trim(),
              line2: _line2Ctrl.text.trim().isEmpty
                  ? null
                  : _line2Ctrl.text.trim(),
              city: _cityCtrl.text.trim(),
              state: _stateCtrl.text.trim(),
              pincode: _pincodeCtrl.text.trim(),
              isDefault: _isDefault,
            );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditing ? 'Address updated' : 'Address saved'),
          backgroundColor: context.colors.success,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: context.colors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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
        title: Text(_isEditing ? 'Edit Address' : 'New Address'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Label selector
            Text('Label', style: tt.labelLarge?.copyWith(color: c.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: _kLabels.map((l) {
                final selected = _label == l;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _label = l),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      child: Text(l,
                          style: tt.labelMedium?.copyWith(
                            color: selected ? c.primary : c.textSecondary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            _Field(
              label: 'Address Line 1',
              controller: _line1Ctrl,
              hint: 'Flat / House No, Street',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              c: c,
            ),
            const SizedBox(height: 14),
            _Field(
              label: 'Address Line 2 (optional)',
              controller: _line2Ctrl,
              hint: 'Landmark, Area',
              c: c,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    label: 'City',
                    controller: _cityCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    c: c,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    label: 'State',
                    controller: _stateCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    c: c,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _Field(
              label: 'Pincode',
              controller: _pincodeCtrl,
              hint: '6-digit PIN',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length != 6) return '6 digits required';
                return null;
              },
              c: c,
            ),

            const SizedBox(height: 20),

            // Default toggle
            Row(
              children: [
                Switch(
                  value: _isDefault,
                  onChanged: (v) => setState(() => _isDefault = v),
                  activeColor: c.primary,
                ),
                const SizedBox(width: 8),
                Text('Set as default address',
                    style: tt.bodyMedium?.copyWith(color: c.textPrimary)),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Save Changes' : 'Save Address',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    required this.c,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final AppThemeColors c;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.labelMedium?.copyWith(color: c.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: tt.bodyMedium?.copyWith(color: c.textPrimary),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: c.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.error),
            ),
          ),
        ),
      ],
    );
  }
}
