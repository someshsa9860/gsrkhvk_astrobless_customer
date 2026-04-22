import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/features/kundli/domain/kundli_models.dart';

void main() {
  group('KundliProfile.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 'kp-1',
        'name': 'Rahul',
        'dateOfBirth': '1990-06-15',
        'timeOfBirth': '14:30',
        'placeOfBirth': 'Mumbai, Maharashtra',
        'lat': 19.0760,
        'lng': 72.8777,
        'createdAt': '2026-01-01T00:00:00.000Z',
      };
      final profile = KundliProfile.fromJson(json);

      expect(profile.id, 'kp-1');
      expect(profile.name, 'Rahul');
      expect(profile.dateOfBirth, '1990-06-15');
      expect(profile.timeOfBirth, '14:30');
      expect(profile.placeOfBirth, 'Mumbai, Maharashtra');
      expect(profile.lat, closeTo(19.076, 0.001));
      expect(profile.lng, closeTo(72.8777, 0.001));
      expect(profile.createdAt, DateTime.utc(2026, 1, 1));
    });

    test('handles optional timeOfBirth being null', () {
      final json = {
        'id': 'kp-2',
        'name': 'Sita',
        'dateOfBirth': '1985-03-21',
        'placeOfBirth': 'Delhi',
        'lat': 28.6139,
        'lng': 77.2090,
        'createdAt': '2026-02-01T00:00:00.000Z',
      };
      final profile = KundliProfile.fromJson(json);

      expect(profile.timeOfBirth, isNull);
    });

    test('lat and lng are parsed as doubles', () {
      final json = {
        'id': 'kp-3',
        'name': 'Mohan',
        'dateOfBirth': '2000-12-01',
        'placeOfBirth': 'Chennai',
        'lat': 13,
        'lng': 80,
        'createdAt': '2026-03-01T00:00:00.000Z',
      };
      final profile = KundliProfile.fromJson(json);

      expect(profile.lat, isA<double>());
      expect(profile.lng, isA<double>());
    });
  });

  group('KundliReport.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'profileId': 'kp-1',
        'chartData': {'sun': 'Aries', 'moon': 'Gemini'},
        'computedAt': '2026-04-10T06:00:00.000Z',
      };
      final report = KundliReport.fromJson(json);

      expect(report.profileId, 'kp-1');
      expect(report.chartData['sun'], 'Aries');
      expect(report.chartData['moon'], 'Gemini');
      expect(report.computedAt, DateTime.utc(2026, 4, 10, 6));
    });

    test('defaults chartData to empty map when absent', () {
      final json = {
        'profileId': 'kp-2',
        'computedAt': '2026-04-11T00:00:00.000Z',
      };
      final report = KundliReport.fromJson(json);

      expect(report.chartData, isEmpty);
    });
  });
}
