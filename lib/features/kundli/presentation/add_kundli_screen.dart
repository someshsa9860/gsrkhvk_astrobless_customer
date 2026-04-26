import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../data/kundli_repository.dart';
import '../domain/kundli_models.dart';

class AddKundliScreen extends ConsumerStatefulWidget {
  const AddKundliScreen({super.key, this.profile});

  /// When non-null, the screen is in edit mode and pre-fills with existing data.
  final KundliProfile? profile;

  @override
  ConsumerState<AddKundliScreen> createState() => _AddKundliScreenState();
}

class _AddKundliScreenState extends ConsumerState<AddKundliScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  DateTime? _dob;
  double _lat = 20.5937;
  double _lng = 78.9629;
  bool _loading = false;

  bool get _isEdit => widget.profile != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.profile!;
      _nameCtrl.text = p.name;
      _placeCtrl.text = p.placeOfBirth;
      _timeCtrl.text = p.timeOfBirth ?? '';
      _dob = DateFormat('yyyy-MM-dd').parse(p.dateOfBirth);
      _lat = p.lat;
      _lng = p.lng;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _placeCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final c = context.colors;
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: c.primary,
            surface: c.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickTime() async {
    final c = context.colors;
    final parts = _timeCtrl.text.split(':');
    final initial = parts.length == 2
        ? TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0)
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: c.primary,
            surface: c.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _timeCtrl.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please select date of birth'),
        backgroundColor: context.colors.error,
      ));
      return;
    }

    setState(() => _loading = true);
    try {
      final KundliProfile saved;
      if (_isEdit) {
        saved = await ref.read(kundliRepositoryProvider).updateProfile(
              id: widget.profile!.id,
              name: _nameCtrl.text.trim(),
              dateOfBirth: DateFormat('yyyy-MM-dd').format(_dob!),
              timeOfBirth: _timeCtrl.text.trim().isEmpty ? null : _timeCtrl.text.trim(),
              placeOfBirth: _placeCtrl.text.trim(),
              lat: _lat,
              lng: _lng,
            );
      } else {
        saved = await ref.read(kundliRepositoryProvider).createProfile(
              name: _nameCtrl.text.trim(),
              dateOfBirth: DateFormat('yyyy-MM-dd').format(_dob!),
              timeOfBirth: _timeCtrl.text.trim().isEmpty ? null : _timeCtrl.text.trim(),
              placeOfBirth: _placeCtrl.text.trim(),
              lat: _lat,
              lng: _lng,
            );
      }

      // Invalidate list + any cached report so fresh data is fetched
      ref.invalidate(kundliProfilesProvider);
      ref.invalidate(kundliReportProvider(saved.id));

      if (mounted) {
        // Replace current screen with the report so Back goes straight to list
        context.pushReplacement(AppRoutes.kundliReport(saved.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: context.colors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Kundli Profile' : 'Add Kundli Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile Details', style: tt.titleMedium),
              const SizedBox(height: 4),
              Text(
                _isEdit
                    ? 'Update birth details — a new chart will be generated'
                    : 'Enter birth details to generate an accurate birth chart',
                style: tt.bodySmall?.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: 24),

              _label('Name *', tt, c),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
                decoration: const InputDecoration(
                  hintText: 'e.g. Myself, Spouse, Child',
                  prefixIcon: Icon(Icons.person_outline, size: 18),
                ),
              ),
              const SizedBox(height: 16),

              _label('Date of Birth *', tt, c),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Select date',
                      prefixIcon:
                          const Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                    controller: TextEditingController(
                      text: _dob != null
                          ? DateFormat('dd MMM yyyy').format(_dob!)
                          : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _label('Time of Birth (optional)', tt, c),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickTime,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _timeCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'Select time (for accurate chart)',
                      prefixIcon: Icon(Icons.access_time_outlined, size: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _label('Place of Birth *', tt, c),
              const SizedBox(height: 6),
              TextFormField(
                controller: _placeCtrl,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Place is required' : null,
                decoration: const InputDecoration(
                  hintText: 'City, Country',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                ),
              ),

              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  // TODO: open location picker map
                },
                icon: const Icon(Icons.map_outlined, size: 16),
                label: const Text('Pick on Map', style: TextStyle(fontSize: 13)),
                style: TextButton.styleFrom(foregroundColor: c.primary),
              ),

              const SizedBox(height: 32),
              AppButton(
                label: _isEdit ? 'Save Changes' : 'Save Kundli Profile',
                onPressed: _submit,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, TextTheme tt, AppThemeColors c) =>
      Text(text, style: tt.labelMedium?.copyWith(color: c.textSecondary));
}
