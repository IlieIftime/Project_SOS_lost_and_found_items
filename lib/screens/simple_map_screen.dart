// Importa os pacotes e ficheiros necessários.
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../models/item_model.dart';
import '../utils/colors.dart';
import '../widgets/osm_map_widget.dart';
import '../widgets/map_search_bar.dart';

// Um ecrã que exibe um mapa simples com uma lista de itens abaixo.
class SimpleMapScreen extends StatefulWidget {
  // A lista de itens a serem exibidos.
  final List<ItemModel> items;

  const SimpleMapScreen({super.key, required this.items});

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreenState();
}

// O estado para o SimpleMapScreen.
class _SimpleMapScreenState extends State<SimpleMapScreen> {
  // Um controlador para o mapa, que pode ser de qualquer tipo (ex: MapController).
  dynamic _mapController;
  // Uma lista para guardar os itens que estão a ser exibidos atualmente após a filtragem.
  late List<ItemModel> _filteredItems;

  @override
  void initState() {
    super.initState();
    // Filtra os itens que não têm uma localização.
    _filteredItems = widget.items.where((item) => item.location != null).toList();
  }

  // Função de callback que é chamada quando o mapa é criado.
  void _onMapCreated(dynamic controller) {
    _mapController = controller;
  }

  // Centra o mapa na localização de um item específico.
  void _centerOnItem(ItemModel item) {
    if (_mapController == null || item.location == null) return;
    try {
      final p = ll.LatLng(item.location!.latitude, item.location!.longitude);
      _mapController.move(p, 15.0); // Move o mapa para a posição do item com um nível de zoom de 15.
    } catch (_) {
      // Ignora quaisquer erros que possam ocorrer durante a operação de movimento do mapa.
    }
  }

  // Mostra uma folha inferior modal (modal bottom sheet) com os detalhes de um item selecionado.
  void _showItemDetails(ItemModel item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.category, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(item.description),
              if (item.location != null) ...[
                const SizedBox(height: 12),
                Text('Lat: ${item.location!.latitude.toStringAsFixed(6)}'),
                Text('Long: ${item.location!.longitude.toStringAsFixed(6)}'),
              ],
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Fecha a folha inferior.
                  _centerOnItem(item); // Centra o mapa no item.
                },
                child: const Text('Centrar no mapa'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Filtra a lista de itens com base numa consulta de pesquisa.
  void _search(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) =>
              item.location != null &&
              (item.description.toLowerCase().contains(query.toLowerCase()) ||
                  item.category.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localizações'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Uma barra de pesquisa para filtrar itens.
          MapSearchBar(onSubmitted: _search),
          Expanded(
            child: _filteredItems.isEmpty
                // Exibe uma mensagem se não houver itens disponíveis para mostrar.
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
                          'Nenhum item para exibir',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                // Exibe o mapa e a lista de itens.
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // O widget do mapa.
                        OsmMapWidget(items: _filteredItems, onMapCreated: _onMapCreated, onMarkerTap: _showItemDetails),
                        const SizedBox(height: 16),
                        // A lista de itens filtrados.
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(), // Desativa o scroll para a lista interna.
                          shrinkWrap: true,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return GestureDetector(
                              onTap: () => _centerOnItem(item), // Centra o mapa no item ao tocar.
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Exibe a categoria e o estado do item.
                                      Row(
                                        children: [
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
                                              item.category,
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: item.status == 'aprovado'
                                                  ? AppColors.success.withOpacity(0.1)
                                                  : AppColors.warning.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.status.toUpperCase(),
                                              style: TextStyle(
                                                color: item.status == 'aprovado'
                                                    ? AppColors.success
                                                    : AppColors.warning,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Descrição do item.
                                      Text(
                                        item.description,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      // Exibe os detalhes da localização, se disponíveis.
                                      if (item.location != null) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 20,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Localização:',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textSecondary,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Lat: ${item.location!.latitude.toStringAsFixed(6)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    Text(
                                                      'Long: ${item.location!.longitude.toStringAsFixed(6)}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
