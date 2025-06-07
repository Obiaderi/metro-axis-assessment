import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapboxConfig {
  // static const String accessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  // Default map style
  static const String mapStyle = 'mapbox://styles/mapbox/streets-v12';

  // Default zoom level for delivery locations
  static const double defaultZoom = 15.0;
}
