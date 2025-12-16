// Importa os pacotes e ficheiros necessários.
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/item_model.dart';
import '../utils/colors.dart';

// Um ecrã para exibir uma lista de itens num Google Map.
class MapScreen extends StatefulWidget {
  // A lista de itens a serem exibidos no mapa.
  final List<ItemModel> items;

  const MapScreen({super.key, required this.items});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// O estado para o MapScreen.
class _MapScreenState extends State<MapScreen> {
  // Controlador para o Google Map.
  GoogleMapController? _mapController;
  // Um conjunto para guardar todos os marcadores a serem exibidos no mapa.
  final Set<Marker> _markers = {};
  // O item atualmente selecionado, para exibir os seus detalhes.
  ItemModel? _selectedItem;

  @override
  void initState() {
    super.initState();
    // Cria os marcadores para os itens quando o ecrã é inicializado.
    _createMarkers();
  }

  // Cria marcadores para cada item que tem uma localização válida.
  void _createMarkers() {
    for (var item in widget.items) {
      // Apenas cria um marcador se a localização não for nula.
      if (item.location != null) {
        _markers.add(
          Marker(
            // Usa o ID ou a descrição do item como um ID de marcador único.
            markerId: MarkerId(item.id ?? item.description),
            position: LatLng(item.location!.latitude, item.location!.longitude),
            // Janela de informação para mostrar detalhes básicos ao tocar.
            infoWindow: InfoWindow(
              title: item.category,
              snippet: item.description,
              onTap: () {
                setState(() => _selectedItem = item);
              },
            ),
            // Define a cor do marcador com base no estado do item.
            icon: BitmapDescriptor.defaultMarkerWithHue(
              item.status == 'aprovado'
                  ? BitmapDescriptor.hueGreen // Verde para aprovado
                  : BitmapDescriptor.hueRed,   // Vermelho para pendente
            ),
            onTap: () {
              setState(() => _selectedItem = item);
            },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cria uma nova lista contendo apenas itens com uma localização válida.
    final itemsWithLocation = widget.items.where((item) => item.location != null).toList();

    // Determina a posição inicial da câmara.
    final CameraPosition initialPosition = CameraPosition(
      // Centra a câmara no primeiro item ou numa localização padrão (Lisboa).
      target: itemsWithLocation.isNotEmpty
          ? LatLng(
              itemsWithLocation.first.location!.latitude,
              itemsWithLocation.first.location!.longitude,
            )
          : const LatLng(38.736946, -9.142685), // Fallback para Lisboa.
      zoom: 13,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Localizações'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      // Usa a lista filtrada para decidir o que exibir.
      body: itemsWithLocation.isEmpty
          // Mostra uma mensagem se não houver itens com localização.
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum item com localização para exibir no mapa',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          // Exibe o mapa se houver itens com localizações.
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: initialPosition,
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                ),

                // Exibe um cartão com os detalhes do item selecionado.
                if (_selectedItem != null && _selectedItem!.location != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Tag da categoria do item.
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _selectedItem!.category,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Botão de fechar para o cartão de detalhes.
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() => _selectedItem = null);
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Descrição do item.
                            Text(
                              _selectedItem!.description,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Coordenadas de localização do item.
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Lat: ${_selectedItem!.location!.latitude.toStringAsFixed(4)}, '
                                    'Long: ${_selectedItem!.location!.longitude.toStringAsFixed(4)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Uma legenda para explicar as cores dos marcadores.
                Positioned(
                  top: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Legenda',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Legenda para itens aprovados.
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Aprovado',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Legenda para itens pendentes.
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Pendente',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    // Liberta os recursos do controlador do mapa.
    _mapController?.dispose();
    super.dispose();
  }
}
