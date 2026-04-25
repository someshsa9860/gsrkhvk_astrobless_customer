import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._client);
  final ApiClient _client;

  Future<CustomerProfileFull> fetchProfile() async {
    final data = await _client.fetchProfile();
    return CustomerProfileFull.fromJson(data);
  }

  Future<CustomerProfileFull> updateProfile({
    String? name,
    String? email,
    String? gender,
    String? dob,
    String? profileImageUrl,
  }) async {
    final data = await _client.updateProfile(
      name: name,
      email: email,
      gender: gender,
      dob: dob,
      profileImageUrl: profileImageUrl,
    );
    return CustomerProfileFull.fromJson(data);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(apiClientProvider));
});

class ProfileNotifier extends AsyncNotifier<CustomerProfileFull> {
  @override
  Future<CustomerProfileFull> build() {
    return ref.read(profileRepositoryProvider).fetchProfile();
  }

  Future<void> saveProfile({
    String? name,
    String? email,
    String? gender,
    String? dob,
    String? profileImageUrl,
  }) async {
    final updated = await ref.read(profileRepositoryProvider).updateProfile(
          name: name,
          email: email,
          gender: gender,
          dob: dob,
          profileImageUrl: profileImageUrl,
        );
    state = AsyncData(updated);
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, CustomerProfileFull>(ProfileNotifier.new);
