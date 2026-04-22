import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../data/kundli_repository.dart';

class AddKundliScreen extends ConsumerStatefulWidget {
  const AddKundliScreen({super.key});

  @override
  ConsumerState<AddKundliScreen> createState() => _AddKundliScreenState();
}

class _AddKundliScreenState extends ConsumerState<AddKundliScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  DateTime? _dob;
  final double _lat = 20.5937;
  final double _lng = 78.9629;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _placeCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.cardDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.cardDark,
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select date of birth'),
        backgroundColor: AppColors.error,
      ));
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(kundliRepositoryProvider).createProfile(
            name: _nameCtrl.text.trim(),
            dateOfBirth: DateFormat('yyyy-MM-dd').format(_dob!),
            timeOfBirth: _timeCtrl.text.trim().isEmpty ? null : _timeCtrl.text.trim(),
            placeOfBirth: _placeCtrl.text.trim(),
            lat: _lat,
            lng: _lng,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception:', '').trim()),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('Add Kundli Profile')),
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
                'Enter birth details to generate an accurate birth chart',
                style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              _label('Name *', tt),
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

              _label('Date of Birth *', tt),
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
                      suffixText: _dob != null
                          ? DateFormat('dd MMM yyyy').format(_dob!)
                          : null,
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

              _label('Time of Birth (optional)', tt),
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

              _label('Place of Birth *', tt),
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
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),

              const SizedBox(height: 32),
              AppButton(
                label: 'Save Kundli Profile',
                onPressed: _submit,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, TextTheme tt) =>
      Text(text, style: tt.labelMedium?.copyWith(color: AppColors.textSecondary));
}
