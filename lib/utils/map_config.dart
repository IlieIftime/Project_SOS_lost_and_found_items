// Small map configuration to avoid using volunteer-run OSM tile servers by default.
// To use a commercial/free tile provider (recommended), create a free account at MapTiler
// (https://www.maptiler.com/).
//
// IMPORTANT: For security don't commit API keys to source. Provide the MapTiler key at build
// time via `--dart-define=MAPTILER_KEY=your_key` or via your CI secret mechanism.

class MapConfig {
  // The MapTiler API key is read from a compile-time environment variable. This avoids
  // committing secrets to source control. To provide the key during development/build use:
  // flutter run --dart-define=MAPTILER_KEY=YOUR_KEY
  static const String mapTilerKey = String.fromEnvironment('MAPTILER_KEY', defaultValue: '8RGJ3mCWOxoXXo1iaKu2');

  static bool get hasMapTilerKey => mapTilerKey.isNotEmpty;

  // Returns the tile URL template to use with flutter_map TileLayer.
  // MapTiler example URLs (try a few formats for compatibility):
  // 1) Maps endpoint (preferred): https://api.maptiler.com/maps/basic/256/{z}/{x}/{y}.png?key=YOUR_KEY
  // 2) Tiles endpoint: https://api.maptiler.com/tiles/basic/{z}/{x}/{y}.png?key=YOUR_KEY
  // 3) Streets style: https://api.maptiler.com/maps/streets/256/{z}/{x}/{y}.png?key=YOUR_KEY
  static String get tileUrlTemplate {
    if (!hasMapTilerKey) return '';

    // Preferred 'maps' endpoint (includes style and tile size)
    return 'https://api.maptiler.com/maps/basic/256/{z}/{x}/{y}.png?key=$mapTilerKey';
  }

  // Expose candidates so callers can probe which URL works for the account
  static List<String> get tileUrlCandidates {
    if (!hasMapTilerKey) return [];
    final primary = 'https://api.maptiler.com/maps/basic/256/{z}/{x}/{y}.png?key=$mapTilerKey';
    final fallback1 = 'https://api.maptiler.com/tiles/basic/{z}/{x}/{y}.png?key=$mapTilerKey';
    final fallback2 = 'https://api.maptiler.com/maps/streets/256/{z}/{x}/{y}.png?key=$mapTilerKey';
    return [primary, fallback1, fallback2];
  }

  // Small helper for attribution text when using MapTiler
  static String get attributionText {
    if (hasMapTilerKey) return '© MapTiler © OpenStreetMap contributors';
    return 'OpenStreetMap tiles blocked — configure a tile provider key';
  }
}
