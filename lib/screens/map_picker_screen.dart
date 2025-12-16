// Importa os pacotes e ficheiros necessários.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../utils/map_config.dart';
import '../utils/tile_resolver.dart';
import '../models/item_model.dart';

// Um ecrã que permite ao utilizador escolher uma localização a partir de um mapa.
class MapPickerScreen extends StatefulWidget {
  // A localização inicial a ser exibida no mapa, se houver.
  final LocationModel? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

// O estado para o MapPickerScreen.
class _MapPickerScreenState extends State<MapPickerScreen> {
  // Controlador para controlar programaticamente o mapa.
  late final MapController _controller = MapController();
  // A localização escolhida pelo utilizador no mapa.
  ll.LatLng? _picked;
  // O template de URL de tile ativo.
  String? _activeTemplate;
  // Uma flag para indicar se o resolvedor de tiles está atualmente a testar um URL funcional.
  bool _probing = false;
  // Uma mensagem de erro a ser exibida se o teste falhar.
  String? _probeError;
  // O nível de zoom atual do mapa.
  double _zoom = 13.0;

  @override
  void initState() {
    super.initState();
    // Se uma localização inicial for fornecida, define-a como a localização escolhida.
    if (widget.initialLocation != null) {
      _picked = ll.LatLng(widget.initialLocation!.latitude, widget.initialLocation!.longitude);
    }
    // Se uma chave do MapTiler estiver disponível, começa a resolver o template de tile.
    if (MapConfig.hasMapTilerKey) _resolveTemplate();
  }

  // Resolve de forma assíncrona um template de URL de tile funcional.
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
        _probeError = 'Não foi possível obter tiles válidos. Verifique a sua chave.';
      });
    }
  }

  // Aumenta o zoom do mapa.
  void _zoomIn() {
    _zoom += 1;
    _controller.move(_controller.center, _zoom);
    setState(() {}); // Reconstrói para atualizar a UI, se necessário.
  }

  // Diminui o zoom do mapa, com fixação de limites (clamping).
  void _zoomOut() {
    _zoom = (_zoom - 1).clamp(1.0, 20.0); // Fixa o nível de zoom entre 1 e 20.
    _controller.move(_controller.center, _zoom);
    setState(() {}); // Reconstrói para atualizar a UI, se necessário.
  }

  // Lida com um evento de toque no mapa, atualizando a localização escolhida.
  void _onTap(ll.LatLng p) {
    setState(() => _picked = p);
  }

  // Confirma a localização escolhida e retorna-a para o ecrã anterior.
  void _confirm() {
    if (_picked == null) return;
    Navigator.of(context).pop(LocationModel(latitude: _picked!.latitude, longitude: _picked!.longitude));
  }

  @override
  Widget build(BuildContext context) {
    // Se nenhuma chave do MapTiler estiver configurada, mostra uma mensagem de erro.
    if (!MapConfig.hasMapTilerKey) {
      return Scaffold(
        appBar: AppBar(title: const Text('Escolher Localização')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nenhuma chave de tiles configurada. Configure a MAPTILER_KEY e tente novamente.'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar')),
              ],
            ),
          ),
        ),
      );
    }

    // O centro do mapa, usando Lisboa como padrão se nenhuma localização for escolhida.
    final center = _picked ?? ll.LatLng(38.736946, -9.142685);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolher Localização'),
        actions: [
          // Botão para confirmar a seleção.
          TextButton(
            onPressed: _confirm,
            child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: _probing
          ? const Center(child: CircularProgressIndicator()) // Mostra um indicador de carregamento durante o teste.
          : _activeTemplate == null
              // Mostra uma mensagem de erro se nenhum template puder ser resolvido.
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_probeError ?? 'Erro ao carregar tiles.'),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _resolveTemplate, child: const Text('Tentar novamente')),
                  ],),
                )
              // Constrói o mapa se um template estiver disponível.
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _controller,
                      options: MapOptions(
                        center: center,
                        zoom: _zoom,
                        onTap: (tapPos, latlng) => _onTap(latlng), // Lida com toques no mapa.
                      ),
                      children: [
                        // A camada de tiles para o fundo do mapa.
                        TileLayer(
                          urlTemplate: _activeTemplate!,
                          userAgentPackageName: 'com.example.app',
                          tileProvider: NetworkTileProvider(),
                        ),
                        // Uma camada de marcadores para mostrar a localização escolhida.
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

                    // Botões de zoom posicionados no mapa.
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

                    // Um botão na parte inferior para confirmar a localização.
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
