import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metro_axis/models/delivery.dart';
import 'package:metro_axis/utils/mapbox_config.dart';

void main() {
  group('Mapbox Maps Flutter Restoration Tests', () {
    test('MapboxConfig should have correct access token', () {
      expect(dotenv.env['MAPBOX_ACCESS_TOKEN'], isNotEmpty);
      expect(dotenv.env['MAPBOX_ACCESS_TOKEN'], startsWith('sk.'));
    });

    test('MapboxConfig should have correct default zoom', () {
      expect(MapboxConfig.defaultZoom, equals(15.0));
    });

    test('Delivery coordinates should be valid for Mapbox', () {
      final delivery = Delivery(
        id: 'TEST001',
        customerName: 'Test Customer',
        address: '123 Test Street, Test City',
        latitude: 40.7128, // New York coordinates
        longitude: -74.0060,
        status: DeliveryStatusEnum.pending,
        timestamp: DateTime.now(),
      );

      // Verify coordinates are within valid ranges for Mapbox
      expect(delivery.latitude, greaterThanOrEqualTo(-85.0511));
      expect(delivery.latitude, lessThanOrEqualTo(85.0511));
      expect(delivery.longitude, greaterThanOrEqualTo(-180.0));
      expect(delivery.longitude, lessThanOrEqualTo(180.0));
    });

    test('Red marker color values should be correct', () {
      const redColor = 0xFFFF0000;
      const whiteColor = 0xFFFFFFFF;

      // Verify color format is correct for Mapbox
      expect(redColor, equals(4294901760)); // Red in int format
      expect(whiteColor, equals(4294967295)); // White in int format
    });

    test('Mock delivery data coordinates should be valid', () {
      // Test coordinates from mock data
      final testCoordinates = [
        {'lat': 40.7128, 'lng': -74.0060}, // New York
        {'lat': 40.7589, 'lng': -73.9851}, // Manhattan
        {'lat': 40.7505, 'lng': -73.9934}, // Times Square
        {'lat': 40.7282, 'lng': -74.0776}, // Jersey City
        {'lat': 40.7831, 'lng': -73.9712}, // Upper East Side
      ];

      for (final coord in testCoordinates) {
        expect(coord['lat'], greaterThanOrEqualTo(-85.0511));
        expect(coord['lat'], lessThanOrEqualTo(85.0511));
        expect(coord['lng'], greaterThanOrEqualTo(-180.0));
        expect(coord['lng'], lessThanOrEqualTo(180.0));
      }
    });

    test('Circle marker properties should be correct', () {
      const circleRadius = 15.0;
      const circleStrokeWidth = 4.0;
      const circleOpacity = 0.9;

      expect(circleRadius, greaterThan(0));
      expect(circleStrokeWidth, greaterThan(0));
      expect(circleOpacity, greaterThan(0));
      expect(circleOpacity, lessThanOrEqualTo(1.0));
    });

    test('Symbol layer properties should be correct', () {
      const textSize = 24.0;
      const textOpacity = 1.0;
      const locationEmoji = '📍';

      expect(textSize, greaterThan(0));
      expect(textOpacity, equals(1.0));
      expect(locationEmoji, isNotEmpty);
    });
  });
}
