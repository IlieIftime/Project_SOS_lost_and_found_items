import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../models/item_model.dart';
import '../utils/colors.dart';
import '../widgets/osm_map_widget.dart';
import '../widgets/map_search_bar.dart';

class SimpleMapScreen extends StatefulWidget {
  final List<ItemModel> items;

  const SimpleMapScreen({super.key, required this.items});

  @override
  State<SimpleMapScreen> createState() => _SimpleMapScreenState();
}

class _SimpleMapScreenState extends State<SimpleMapScreen> {
  dynamic _mapController;
  late List<ItemModel> _filteredItems;

  @override
  void initState() {
    super.initState();
    // Filter out items that don't have a location
    _filteredItems = widget.items.where((item) => item.location != null).toList();
  }

  void _onMapCreated(dynamic controller) {
    _mapController = controller;
  }

  void _centerOnItem(ItemModel item) {
    if (_mapController == null || item.location == null) return;
    try {
      final p = ll.LatLng(item.location!.latitude, item.location!.longitude);
      _mapController.move(p, 15.0);
    } catch (_) {}
  }

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
                  Navigator.of(ctx).pop();
                  _centerOnItem(item);
                },
                child: const Text('Centrar no mapa'),
              ),
            ],
          ),
        );
      },
    );
  }

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
          MapSearchBar(onSubmitted: _search),
          Expanded(
            child: _filteredItems.isEmpty
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        OsmMapWidget(items: _filteredItems, onMapCreated: _onMapCreated, onMarkerTap: _showItemDetails),
                        const SizedBox(height: 16),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return GestureDetector(
                              onTap: () => _centerOnItem(item),
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
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.1),
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
                                                  ? AppColors.success.withValues(alpha: 0.1)
                                                  : AppColors.warning.withValues(alpha: 0.1),
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
                                      Text(
                                        item.description,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
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
