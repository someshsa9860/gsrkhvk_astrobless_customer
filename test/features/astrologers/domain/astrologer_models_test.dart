import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/astrologers/domain/astrologer_models.dart';

Map<String, dynamic> get fullAstrologerJson => {
      'id': 'astro-1',
      'displayName': 'Pandit Sharma',
      'profileImageUrl': 'https://cdn.example.com/sharma.jpg',
      'bio': 'Expert in Vedic astrology',
      'specialties': ['Vedic', 'Kundli'],
      'languages': ['Hindi', 'English'],
      'experienceYears': 10,
      'pricePerMinChatPaise': 300,
      'pricePerMinCallPaise': 500,
      'isOnline': true,
      'isBusy': false,
      'ratingAvg': 4.8,
      'ratingCount': 250,
      'totalConsultations': 1200,
    };

void main() {
  group('Astrologer.fromJson', () {
    test('parses all fields correctly', () {
      final a = Astrologer.fromJson(fullAstrologerJson);

      expect(a.id, 'astro-1');
      expect(a.displayName, 'Pandit Sharma');
      expect(a.profileImageUrl, 'https://cdn.example.com/sharma.jpg');
      expect(a.bio, 'Expert in Vedic astrology');
      expect(a.specialties, ['Vedic', 'Kundli']);
      expect(a.languages, ['Hindi', 'English']);
      expect(a.experienceYears, 10);
      expect(a.pricePerMinChatPaise, 300);
      expect(a.pricePerMinCallPaise, 500);
      expect(a.isOnline, isTrue);
      expect(a.isBusy, isFalse);
      expect(a.ratingAvg, 4.8);
      expect(a.ratingCount, 250);
      expect(a.totalConsultations, 1200);
    });

    test('defaults optional numeric fields to 0 when absent', () {
      final a = Astrologer.fromJson({'id': 'a-2', 'displayName': 'Test'});

      expect(a.experienceYears, 0);
      expect(a.pricePerMinChatPaise, 0);
      expect(a.pricePerMinCallPaise, 0);
      expect(a.ratingAvg, 0.0);
      expect(a.ratingCount, 0);
      expect(a.totalConsultations, 0);
    });

    test('defaults isOnline and isBusy to false when absent', () {
      final a = Astrologer.fromJson({'id': 'a-3', 'displayName': 'Test'});

      expect(a.isOnline, isFalse);
      expect(a.isBusy, isFalse);
    });

    test('handles empty specialties and languages lists', () {
      final json = {
        'id': 'a-4',
        'displayName': 'Offline',
        'specialties': <String>[],
        'languages': <String>[],
      };
      final a = Astrologer.fromJson(json);

      expect(a.specialties, isEmpty);
      expect(a.languages, isEmpty);
    });

    test('defaults specialties and languages to empty when absent', () {
      final a = Astrologer.fromJson({'id': 'a-5', 'displayName': 'New'});

      expect(a.specialties, isEmpty);
      expect(a.languages, isEmpty);
    });

    test('ratingAvg is a double', () {
      final a = Astrologer.fromJson(fullAstrologerJson);
      expect(a.ratingAvg, isA<double>());
    });

    test('prices are stored as int (paise)', () {
      final a = Astrologer.fromJson(fullAstrologerJson);
      expect(a.pricePerMinChatPaise, isA<int>());
      expect(a.pricePerMinCallPaise, isA<int>());
    });
  });
}
