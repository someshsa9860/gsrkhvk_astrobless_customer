import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_app/core/network/api_client.dart';
import 'package:user_app/features/kundli/data/kundli_repository.dart';
import 'package:user_app/features/kundli/domain/kundli_models.dart';

class MockApiClient extends Mock implements ApiClient {}

Map<String, dynamic> profileJson(String id, String name) => {
      'id': id,
      'name': name,
      'dateOfBirth': '1990-06-15',
      'timeOfBirth': '10:00',
      'placeOfBirth': 'Mumbai',
      'lat': 19.076,
      'lng': 72.877,
      'createdAt': '2026-01-01T00:00:00.000Z',
    };

void main() {
  late MockApiClient client;
  late KundliRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = KundliRepository(client);
  });

  group('fetchProfiles', () {
    test('returns mapped KundliProfile list', () async {
      when(() => client.fetchKundliProfiles()).thenAnswer(
        (_) async => [profileJson('kp-1', 'Rahul'), profileJson('kp-2', 'Sita')],
      );

      final list = await repo.fetchProfiles();

      expect(list, hasLength(2));
      expect(list.first, isA<KundliProfile>());
      expect(list.first.id, 'kp-1');
      expect(list.last.id, 'kp-2');
    });

    test('returns empty list when client returns empty', () async {
      when(() => client.fetchKundliProfiles()).thenAnswer((_) async => []);

      final list = await repo.fetchProfiles();

      expect(list, isEmpty);
    });

    test('propagates exceptions from client', () async {
      when(() => client.fetchKundliProfiles()).thenThrow(Exception('network error'));

      await expectLater(repo.fetchProfiles(), throwsA(isA<Exception>()));
    });
  });

  group('createProfile', () {
    test('returns a KundliProfile with all fields', () async {
      when(() => client.createKundliProfile(
            name: any(named: 'name'),
            dateOfBirth: any(named: 'dateOfBirth'),
            timeOfBirth: any(named: 'timeOfBirth'),
            placeOfBirth: any(named: 'placeOfBirth'),
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
          )).thenAnswer((_) async => profileJson('kp-new', 'Mohan'));

      final profile = await repo.createProfile(
        name: 'Mohan',
        dateOfBirth: '2000-01-01',
        placeOfBirth: 'Chennai',
        lat: 13.08,
        lng: 80.27,
      );

      expect(profile.id, 'kp-new');
      expect(profile.name, 'Mohan');
    });

    test('passes timeOfBirth as null when not provided', () async {
      when(() => client.createKundliProfile(
            name: any(named: 'name'),
            dateOfBirth: any(named: 'dateOfBirth'),
            timeOfBirth: any(named: 'timeOfBirth'),
            placeOfBirth: any(named: 'placeOfBirth'),
            lat: any(named: 'lat'),
            lng: any(named: 'lng'),
          )).thenAnswer((_) async => {
            ...profileJson('kp-3', 'Anita'),
            'timeOfBirth': null,
          });

      final profile = await repo.createProfile(
        name: 'Anita',
        dateOfBirth: '1985-11-11',
        placeOfBirth: 'Delhi',
        lat: 28.61,
        lng: 77.20,
      );

      expect(profile.timeOfBirth, isNull);
    });
  });

  group('deleteProfile', () {
    test('completes without throwing on success', () async {
      when(() => client.deleteKundliProfile(any())).thenAnswer((_) async {});

      await expectLater(repo.deleteProfile('kp-1'), completes);
    });

    test('propagates exceptions from client', () async {
      when(() => client.deleteKundliProfile(any()))
          .thenThrow(Exception('not found'));

      await expectLater(
        repo.deleteProfile('kp-missing'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fetchReport', () {
    test('returns a KundliReport parsed from client data', () async {
      when(() => client.fetchKundliReport('kp-1')).thenAnswer(
        (_) async => {
          'profileId': 'kp-1',
          'chartData': {'sun': 'Taurus', 'moon': 'Leo'},
          'computedAt': '2026-04-01T12:00:00.000Z',
        },
      );

      final report = await repo.fetchReport('kp-1');

      expect(report, isA<KundliReport>());
      expect(report.profileId, 'kp-1');
      expect(report.chartData['sun'], 'Taurus');
      expect(report.computedAt, DateTime.utc(2026, 4, 1, 12));
    });

    test('propagates exceptions from client', () async {
      when(() => client.fetchKundliReport(any()))
          .thenThrow(Exception('compute error'));

      await expectLater(
        repo.fetchReport('kp-x'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
