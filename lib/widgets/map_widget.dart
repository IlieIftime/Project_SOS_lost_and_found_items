import '../models/item_model.dart';

/// Abstract map widget contract (interface only)
/// Implementations can be StatefulWidget or StatelessWidget.
abstract class MapWidget {
  List<ItemModel> get items;
  LatLng? get initialCenter;
  double get initialZoom;
  void Function(dynamic controller)? get onMapCreated;
  void Function(ItemModel)? get onMarkerTap;
}

/// A small LatLng holder to avoid coupling to external packages in callers.
class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}
