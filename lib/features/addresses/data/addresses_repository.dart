import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../domain/address_models.dart';

class AddressesRepository {
  AddressesRepository(this._client);
  final ApiClient _client;

  Future<List<CustomerAddress>> fetchAddresses() async {
    final list = await _client.fetchAddresses();
    return list
        .map((e) => CustomerAddress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerAddress> createAddress({
    required String label,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pincode,
    String country = 'India',
    bool isDefault = false,
  }) async {
    final data = await _client.createAddress(
      label: label,
      line1: line1,
      line2: line2,
      city: city,
      state: state,
      pincode: pincode,
      country: country,
      isDefault: isDefault,
    );
    return CustomerAddress.fromJson(data);
  }

  Future<CustomerAddress> updateAddress(
      String id, Map<String, dynamic> fields) async {
    final data = await _client.updateAddress(id, fields);
    return CustomerAddress.fromJson(data);
  }

  Future<void> deleteAddress(String id) => _client.deleteAddress(id);

  Future<void> setDefault(String id) => _client.setDefaultAddress(id);
}

final addressesRepositoryProvider = Provider<AddressesRepository>((ref) {
  return AddressesRepository(ref.read(apiClientProvider));
});

// ── Notifier ──────────────────────────────────────────────────────────────

class AddressesNotifier extends AsyncNotifier<List<CustomerAddress>> {
  @override
  Future<List<CustomerAddress>> build() {
    return ref.read(addressesRepositoryProvider).fetchAddresses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(addressesRepositoryProvider).fetchAddresses());
  }

  Future<void> add({
    required String label,
    required String line1,
    String? line2,
    required String city,
    required String state,
    required String pincode,
    bool isDefault = false,
  }) async {
    final addr = await ref.read(addressesRepositoryProvider).createAddress(
          label: label,
          line1: line1,
          line2: line2,
          city: city,
          state: state,
          pincode: pincode,
          isDefault: isDefault,
        );
    final current = this.state.valueOrNull ?? [];
    if (isDefault) {
      final updated = current.map((a) => CustomerAddress(
            id: a.id, label: a.label, line1: a.line1, line2: a.line2,
            city: a.city, state: a.state, pincode: a.pincode,
            country: a.country, isDefault: false, createdAt: a.createdAt,
          )).toList();
      this.state = AsyncData([addr, ...updated]);
    } else {
      this.state = AsyncData([addr, ...current]);
    }
  }

  Future<void> setDefault(String id) async {
    await ref.read(addressesRepositoryProvider).setDefault(id);
    final current = state.valueOrNull ?? [];
    state = AsyncData(current.map((a) => CustomerAddress(
      id: a.id, label: a.label, line1: a.line1, line2: a.line2,
      city: a.city, state: a.state, pincode: a.pincode,
      country: a.country, isDefault: a.id == id, createdAt: a.createdAt,
    )).toList());
  }

  Future<void> remove(String id) async {
    await ref.read(addressesRepositoryProvider).deleteAddress(id);
    state = AsyncData(
        (state.valueOrNull ?? []).where((a) => a.id != id).toList());
  }
}

final addressesNotifierProvider =
    AsyncNotifierProvider<AddressesNotifier, List<CustomerAddress>>(
        AddressesNotifier.new);
