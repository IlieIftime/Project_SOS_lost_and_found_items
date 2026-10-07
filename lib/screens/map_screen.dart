import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/item_model.dart';
import '../utils/colors.dart';

class MapScreen extends StatefulWidget {
  final List<ItemModel> items;

  const MapScreen({super.key, required this.items});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  ItemModel? _selectedItem;

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    for (var item in widget.items) {
      // **FIX: Only create a marker if the location is not null.**
      if (item.location != null) {
        _markers.add(
          Marker(
            // **FIX: Provide a fallback for the marker ID if item.id is null.**
            markerId: MarkerId(item.id ?? item.description),
            position: LatLng(item.location!.latitude, item.location!.longitude),
            infoWindow: InfoWindow(
              title: item.category,
              snippet: item.description,
              onTap: () {
                setState(() => _selectedItem = item);
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              item.status == 'aprovado'
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
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
    // **FIX: Create a new list containing only items with a valid location.**
    final itemsWithLocation = widget.items.where((item) => item.location != null).toList();

    // **FIX: Safely determine the initial camera position.**
    final CameraPosition initialPosition = CameraPosition(
      target: itemsWithLocation.isNotEmpty
          ? LatLng(
        itemsWithLocation.first.location!.latitude,
        itemsWithLocation.first.location!.longitude,
      )
          : const LatLng(38.736946, -9.142685), // Fallback to Lisbon
      zoom: 13,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Localizações'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      // **FIX: Use the filtered list to decide what to display.**
      body: itemsWithLocation.isEmpty
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

          // **FIX: Add a null check for the selected item's location.**
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
                              _selectedItem!.category,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
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
    _mapController?.dispose();
    super.dispose();
  }
}