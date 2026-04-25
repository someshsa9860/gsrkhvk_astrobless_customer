import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/theme/app_colors.dart';
import '../data/profile_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _isSaving = false;
  bool _loaded = false;

  File? _pickedPhoto;
  String? _uploadedTempKey;
  bool _isUploadingPhoto = false;
  double _uploadProgress = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      final profile = ref.read(profileNotifierProvider).valueOrNull;
      if (profile != null) {
        _nameCtrl.text = profile.name ?? '';
        _emailCtrl.text = profile.email ?? '';
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    setState(() {
      _pickedPhoto = file;
      _isUploadingPhoto = true;
      _uploadProgress = 0;
      _uploadedTempKey = null;
    });

    try {
      final tempKey = await ref.read(uploadServiceProvider).presignAndUpload(
        file: file,
        category: 'profiles',
        contentType: 'image/jpeg',
        onProgress: (sent, total) {
          if (total > 0 && mounted) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );
      if (mounted) {
        setState(() {
          _uploadedTempKey = tempKey;
          _isUploadingPhoto = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _pickedPhoto = null;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo upload failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final profile = ref.watch(profileNotifierProvider).valueOrNull;

    // Seed fields once data arrives if not yet loaded manually
    if (profile != null && !_loaded) {
      _nameCtrl.text = profile.name ?? '';
      _emailCtrl.text = profile.email ?? '';
      _loaded = true;
    }

    final existingImageUrl = profile?.profileImageUrl;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: (_isSaving || _isUploadingPhoto) ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  backgroundImage: _pickedPhoto != null
                      ? FileImage(_pickedPhoto!) as ImageProvider
                      : (existingImageUrl != null
                          ? NetworkImage(existingImageUrl)
                          : null),
                  child: (_pickedPhoto == null && existingImageUrl == null)
                      ? const Icon(Icons.person, size: 44, color: AppColors.primary)
                      : null,
                ),
                if (_isUploadingPhoto)
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                  ),
                if (_uploadedTempKey != null && !_isUploadingPhoto)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 11, color: Colors.white),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : _pickAndUploadPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _isUploadingPhoto
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.bgDark, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          _buildLabel(tt, 'Full Name'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _nameCtrl,
            hint: 'Enter your name',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 20),

          _buildLabel(tt, 'Email'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _emailCtrl,
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (_isSaving || _isUploadingPhoto) ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Changes',
                      style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildLabel(TextTheme tt, String text) => Text(
        text,
        style: tt.labelMedium?.copyWith(color: AppColors.textSecondary),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textDisabled),
          filled: true,
          fillColor: AppColors.cardDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      );

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(profileNotifierProvider.notifier).saveProfile(
            name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
            email:
                _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
            profileImageUrl: _uploadedTempKey,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
