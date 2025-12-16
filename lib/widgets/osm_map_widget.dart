// Importa os pacotes e ficheiros necessários.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;
import '../models/item_model.dart';
import '../utils/map_config.dart';
import '../utils/tile_resolver.dart';

// Um widget OpenStreetMap que exibe itens num mapa.
class OsmMapWidget extends StatefulWidget {
  // A lista de itens a serem exibidos como marcadores.
  final List<ItemModel> items;
  // O centro inicial do mapa.
  final dynamic initialCenter; // Pode aceitar um LatLng personalizado ou nulo.
  // O nível de zoom inicial do mapa.
  final double initialZoom;
  // Função de callback para quando o mapa é criado.
  final void Function(dynamic controller)? onMapCreated;
  // Função de callback para quando um marcador é tocado.
  final void Function(ItemModel)? onMarkerTap;

  const OsmMapWidget({
    super.key,
    required this.items,
    this.initialCenter,
    this.initialZoom = 13.0,
    this.onMapCreated,
    this.onMarkerTap,
  });

  @override
  State<OsmMapWidget> createState() => _OsmMapWidgetState();
}

// O estado para o OsmMapWidget.
class _OsmMapWidgetState extends State<OsmMapWidget> {
  late final MapController _mapController;
  String? _activeTileTemplate;
  bool _probing = false;
  String? _probeError;
  double _currentZoom = 13.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onMapCreated != null) widget.onMapCreated!(_mapController);
      _fitToPoints();
      if (MapConfig.hasMapTilerKey) {
        _resolveTileTemplate();
      }
    });
  }

  // Resolve o template de tile ativo a partir dos candidatos disponíveis.
  Future<void> _resolveTileTemplate() async {
    setState(() {
      _probing = true;
      _probeError = null;
    });
    final template = await TileResolver.getActiveTemplate();
    if (template != null) {
      setState(() {
        _activeTileTemplate = template;
        _probing = false;
      });
    } else {
      setState(() {
        _probing = false;
        _probeError = 'Nenhum template de tile respondeu com sucesso. Verifique a chave do MapTiler.';
      });
    }
  }

  // Aumenta o zoom do mapa.
  void _zoomIn() {
    _currentZoom += 1;
    _mapController.move(_mapController.center, _currentZoom);
    setState(() {});
  }

  // Diminui o zoom do mapa.
  void _zoomOut() {
    _currentZoom = (_currentZoom - 1).clamp(1.0, 20.0);
    _mapController.move(_mapController.center, _currentZoom);
    setState(() {});
  }

  // Ajusta os limites do mapa para enquadrar todos os marcadores de itens.
  void _fitToPoints() {
    final points = widget.items
        .where((i) => i.location != null)
        .map((i) => ll.LatLng(i.location!.latitude, i.location!.longitude))
        .where((p) => !(p.latitude.abs() < 0.000001 && p.longitude.abs() < 0.000001))
        .toList();
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, widget.initialZoom);
      return;
    }
    final latitudes = points.map((p) => p.latitude);
    final longitudes = points.map((p) => p.longitude);
    final north = latitudes.reduce((a, b) => a > b ? a : b);
    final south = latitudes.reduce((a, b) => a < b ? a : b);
    final east = longitudes.reduce((a, b) => a > b ? a : b);
    final west = longitudes.reduce((a, b) => a < b ? a : b);

    final bounds = LatLngBounds(ll.LatLng(south, west), ll.LatLng(north, east));
    try {
      _mapController.fitBounds(bounds, options: FitBoundsOptions(padding: EdgeInsets.all(48)));
    } catch (_) {
      // Ignora erros de ajuste de limites.
    }
  }

  @override
  void didUpdateWidget(covariant OsmMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _fitToPoints();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pointsWithItems = widget.items
        .where((i) => i.location != null)
        .map((i) => MapEntry(ll.LatLng(i.location!.latitude, i.location!.longitude), i))
        .where((e) => !(e.key.latitude.abs() < 0.000001 && e.key.longitude.abs() < 0.000001))
        .toList();

    if (pointsWithItems.isEmpty) {
      return SizedBox(
        height: 240,
        child: Container(
          color: Colors.brown[50],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.map_outlined, size: 48, color: Colors.black45),
                SizedBox(height: 12),
                Text('Sem coordenadas válidas para mostrar no mapa', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      );
    }

    final center = widget.initialCenter != null
        ? ll.LatLng(widget.initialCenter!.latitude, widget.initialCenter!.longitude)
        : pointsWithItems.first.key;

    if (!MapConfig.hasMapTilerKey) {
      return SizedBox(
        height: 240,
        child: Container(
          color: Colors.brown[50],
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 48, color: Colors.black45),
                const SizedBox(height: 12),
                const Text('Os tiles públicos do OpenStreetMap não devem ser usados por aplicações de produção.'),
                const SizedBox(height: 8),
                const Text('Por favor, configure uma chave de tiles (ex: MapTiler) em lib/utils/map_config.dart (mapTilerKey).'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Configurar fornecedor de tiles'),
                        content: const Text(
                          'Para não usar os tiles públicos do OpenStreetMap (servidores voluntários), crie uma conta gratuita em https://www.maptiler.com/ e cole a sua API key em lib/utils/map_config.dart (mapTilerKey).',
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Fechar')),
                        ],
                      ),
                    );
                  },
                  child: const Text('Entendi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_probing) {
      return SizedBox(
        height: 240,
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [CircularProgressIndicator(), SizedBox(height:8), Text('A carregar tiles...')])),
      );
    }

    if (_activeTileTemplate == null) {
      return SizedBox(
        height: 240,
        child: Container(
          color: Colors.brown[50],
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.black45),
                const SizedBox(height: 12),
                Text(_probeError ?? 'Erro ao carregar tiles.'),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _resolveTileTemplate, child: const Text('Tentar novamente')),
                const SizedBox(height: 8),
                const Text('Se o problema persistir, verifique a sua chave do MapTiler.'),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: center,
          zoom: widget.initialZoom,
          onPositionChanged: (pos, has) {
            if (has) {
              _currentZoom = pos.zoom ?? _currentZoom;
            }
          },
          onTap: (_, __) {},
        ),
        children: [
          TileLayer(
            urlTemplate: _activeTileTemplate!,
            userAgentPackageName: 'com.example.app',
            tileProvider: NetworkTileProvider(),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Column(
              children: [
                FloatingActionButton.small(
                  onPressed: _zoomIn,
                  heroTag: 'osm_zoom_in',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: _zoomOut,
                  heroTag: 'osm_zoom_out',
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
          MarkerLayer(
            markers: pointsWithItems
                .map((e) => Marker(
                      point: e.key,
                      width: 40,
                      height: 40,
                      builder: (ctx) => GestureDetector(
                        onTap: () => widget.onMarkerTap?.call(e.value),
                        child: const Icon(Icons.location_on, color: Colors.red, size: 36),
                      ),
                    ))
                .toList(),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              color: Colors.white70,
              child: Text(
                MapConfig.attributionText,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
