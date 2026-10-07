import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String? id;
  final String description;
  final String category;
  final String status;
  final String? imageUrl;
  final String? assetImage;
  final LocationModel? location;
  final String? phone;
  final String? createdBy;

  ItemModel({
    this.id,
    required this.description,
    required this.category,
    this.status = 'pendente',
    this.imageUrl,
    this.assetImage,
    this.location,
    this.phone,
    this.createdBy,
  });

  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final locationData = data['location'] as Map<String, dynamic>?;

    return ItemModel(
      id: doc.id,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? 'pendente',
      imageUrl: data['imageUrl'] as String?,
      assetImage: data['assetImage'] as String?,
      phone: data['phone'] as String?,
      createdBy: data['createdBy'] as String?,
      location: locationData != null ? LocationModel.fromJson(locationData) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
      'assetImage': assetImage,
      'location': location?.toJson(),
      'phone': phone,
      'createdBy': createdBy,
    };
  }
}

class LocationModel {
  final double latitude;
  final double longitude;

  LocationModel({
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
