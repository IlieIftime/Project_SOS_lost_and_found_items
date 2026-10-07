import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../utils/map_config.dart';
import '../utils/tile_resolver.dart';
import '../models/item_model.dart';

class MapPickerScreen extends StatefulWidget {
  final LocationModel? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _controller = MapController();
  ll.LatLng? _picked;
  String? _activeTemplate;
  bool _probing = false;
  String? _probeError;
  double _zoom = 13.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _picked = ll.LatLng(widget.initialLocation!.latitude, widget.initialLocation!.longitude);
    }
    if (MapConfig.hasMapTilerKey) _resolveTemplate();
  }

  Future<void> _resolveTemplate() async {
    setState(() {
      _probing = true;
      _probeError = null;
    });
    final t = await TileResolver.getActiveTemplate();
    if (t != null) {
      setState(() {
        _activeTemplate = t;
        _probing = false;
      });
    } else {
      setState(() {
        _probing = false;
        _probeError = 'Não foi possível obter tiles válidos. Verifica a chave.';
      });
    }
  }

  void _zoomIn() {
    _zoom += 1;
    _controller.move(_controller.center, _zoom);
    setState(() {});
  }

  void _zoomOut() {
    _zoom = (_zoom - 1).clamp(1.0, 20.0);
    _controller.move(_controller.center, _zoom);
    setState(() {});
  }

  void _onTap(ll.LatLng p) {
    setState(() => _picked = p);
  }

  void _confirm() {
    if (_picked == null) return;
    Navigator.of(context).pop(LocationModel(latitude: _picked!.latitude, longitude: _picked!.longitude));
  }

  @override
  Widget build(BuildContext context) {
    if (!MapConfig.hasMapTilerKey) {
      return Scaffold(
        appBar: AppBar(title: const Text('Escolher localização')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nenhuma chave de tiles configurada. Configure MAPTILER_KEY e tente novamente.'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar')),
              ],
            ),
          ),
        ),
      );
    }

    final center = _picked ?? ll.LatLng(38.736946, -9.142685);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolher localização'),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: _probing
          ? const Center(child: CircularProgressIndicator())
          : _activeTemplate == null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_probeError ?? 'Erro ao carregar tiles.'),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _resolveTemplate, child: const Text('Tentar novamente')),
                  ],),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _controller,
                      options: MapOptions(
                        center: center,
                        zoom: _zoom,
                        onTap: (tapPos, latlng) => _onTap(latlng),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: _activeTemplate!,
                          userAgentPackageName: 'com.example.app',
                          tileProvider: NetworkTileProvider(),
                        ),
                        if (_picked != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _picked!,
                                width: 40,
                                height: 40,
                                builder: (ctx) => const Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                      ],
                    ),

                    Positioned(
                      right: 12,
                      top: 12,
                      child: Column(
                        children: [
                          FloatingActionButton.small(onPressed: _zoomIn, heroTag: 'picker_zoom_in', child: const Icon(Icons.add)),
                          const SizedBox(height: 8),
                          FloatingActionButton.small(onPressed: _zoomOut, heroTag: 'picker_zoom_out', child: const Icon(Icons.remove)),
                        ],
                      ),
                    ),

                    if (_picked != null)
                      Positioned(
                        bottom: 24,
                        left: 16,
                        child: ElevatedButton(onPressed: _confirm, child: const Text('Confirmar localização')),
                      ),
                  ],
                ),
    );
  }
}
