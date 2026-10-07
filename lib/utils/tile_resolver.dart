import 'package:http/http.dart' as http;
import 'map_config.dart';

/// Simple singleton to probe and cache a working tile URL template.
/// Call `TileResolver.getActiveTemplate()` before building maps that depend on a
/// working tile endpoint. Returns `null` if no working template was found.
class TileResolver {
  static String? _activeTemplate;
  static bool _probing = false;

  /// Probe candidates if needed and return the active template or null.
  static Future<String?> getActiveTemplate() async {
    if (_activeTemplate != null) return _activeTemplate;
    if (!MapConfig.hasMapTilerKey) return null;
    if (_probing) {
      // If another caller is probing, wait briefly until it's done
      var attempts = 0;
      while (_probing && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
      return _activeTemplate;
    }

    _probing = true;
    try {
      final candidates = MapConfig.tileUrlCandidates;
      for (final template in candidates) {
        try {
          final testUrl = template
              .replaceAll('{z}', '0')
              .replaceAll('{x}', '0')
              .replaceAll('{y}', '0');
          final uri = Uri.parse(testUrl);
          // Provide a conservative User-Agent and accept header so some tile
          // providers don't reject the probe request.
          final resp = await http
              .get(uri, headers: {
                'User-Agent': 'projeto_prog_mob/1.0',
                'Accept': 'image/*',
              })
              .timeout(const Duration(seconds: 5));
          if (resp.statusCode == 200 && resp.headers['content-type']?.startsWith('image/') == true) {
            _activeTemplate = template;
            return _activeTemplate;
          }
        } catch (_) {
          // ignore and try next candidate
        }
      }
    } finally {
      _probing = false;
    }
    return null;
  }
}

