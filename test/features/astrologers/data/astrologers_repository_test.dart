import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:user_app/core/network/api_client.dart';
import 'package:user_app/features/astrologers/data/astrologers_repository.dart';
import 'package:user_app/features/astrologers/domain/astrologer_models.dart';

class MockApiClient extends Mock implements ApiClient {}

Map<String, dynamic> astrologerJson(String id, String name) => {
      'id': id,
      'displayName': name,
      'specialties': ['Vedic'],
      'languages': ['Hindi'],
      'experienceYears': 5,
      'pricePerMinChatPaise': 200,
      'pricePerMinCallPaise': 300,
      'isOnline': true,
      'isBusy': false,
      'ratingAvg': 4.5,
      'ratingCount': 100,
      'totalConsultations': 500,
    };

void main() {
  late MockApiClient client;
  late AstrologersRepository repo;

  setUp(() {
    client = MockApiClient();
    repo = AstrologersRepository(client);
  });

  group('fetchAstrologers', () {
    test('returns mapped Astrologer list from items key', () async {
      when(() => client.fetchAstrologers(
            search: any(named: 'search'),
            specialty: any(named: 'specialty'),
            language: any(named: 'language'),
            isOnline: any(named: 'isOnline'),
            minRating: any(named: 'minRating'),
            maxPricePaise: any(named: 'maxPricePaise'),
            sort: any(named: 'sort'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer(
        (_) async => {
          'astrologers': [
            astrologerJson('a-1', 'Pandit Sharma'),
            astrologerJson('a-2', 'Guruji Verma'),
          ],
        },
      );

      final list = await repo.fetchAstrologers();

      expect(list, hasLength(2));
      expect(list.first, isA<Astrologer>());
      expect(list.first.id, 'a-1');
      expect(list.first.displayName, 'Pandit Sharma');
      expect(list.last.id, 'a-2');
    });

    test('returns empty list when response has no astrologers', () async {
      when(() => client.fetchAstrologers(
            search: any(named: 'search'),
            specialty: any(named: 'specialty'),
            language: any(named: 'language'),
            isOnline: any(named: 'isOnline'),
            minRating: any(named: 'minRating'),
            maxPricePaise: any(named: 'maxPricePaise'),
            sort: any(named: 'sort'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => {'astrologers': []});

      final list = await repo.fetchAstrologers();

      expect(list, isEmpty);
    });

    test('propagates exceptions from client', () async {
      when(() => client.fetchAstrologers(
            search: any(named: 'search'),
            specialty: any(named: 'specialty'),
            language: any(named: 'language'),
            isOnline: any(named: 'isOnline'),
            minRating: any(named: 'minRating'),
            maxPricePaise: any(named: 'maxPricePaise'),
            sort: any(named: 'sort'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          )).thenThrow(Exception('network error'));

      await expectLater(
        repo.fetchAstrologers(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('fetchAstrologer', () {
    test('returns a single Astrologer parsed from detail key', () async {
      when(() => client.fetchAstrologer('a-1')).thenAnswer(
        (_) async => {'astrologer': astrologerJson('a-1', 'Pandit Sharma')},
      );

      final a = await repo.fetchAstrologer('a-1');

      expect(a.id, 'a-1');
      expect(a.displayName, 'Pandit Sharma');
    });

    test('falls back to flat map when astrologer key is absent', () async {
      when(() => client.fetchAstrologer('a-2')).thenAnswer(
        (_) async => astrologerJson('a-2', 'Guruji Verma'),
      );

      final a = await repo.fetchAstrologer('a-2');

      expect(a.id, 'a-2');
      expect(a.displayName, 'Guruji Verma');
    });

    test('propagates not-found exception from client', () async {
      when(() => client.fetchAstrologer(any()))
          .thenThrow(Exception('not found'));

      await expectLater(
        repo.fetchAstrologer('missing-id'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
