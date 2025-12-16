// Importa o pacote cloud_firestore para interagir com o Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

// Representa um único item perdido ou achado na aplicação.
class ItemModel {
  // O identificador único para o item, tipicamente o ID do documento do Firestore.
  final String? id;
  // Uma descrição detalhada do item.
  final String description;
  // A categoria à qual o item pertence (ex: 'Eletrónicos', 'Chaves').
  final String category;
  // O estado atual do item ('pendente', 'aprovado').
  final String status;
  // O URL de uma imagem carregada para o item.
  final String? imageUrl;
  // O caminho para uma imagem de exemplo pré-definida para o item.
  final String? assetImage;
  // A localização geográfica onde o item foi perdido ou achado.
  final LocationModel? location;
  // O número de telefone de contacto fornecido pelo utilizador que reportou o item.
  final String? phone;
  // O UID do utilizador que criou o relatório.
  final String? createdBy;

  // Construtor para criar uma instância de ItemModel.
  ItemModel({
    this.id,
    required this.description,
    required this.category,
    this.status = 'pendente', // O estado padrão é 'pendente'.
    this.imageUrl,
    this.assetImage,
    this.location,
    this.phone,
    this.createdBy,
  });

  // Um construtor factory para criar um ItemModel a partir de um documento do Firestore.
  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    // Converte os dados do documento para um mapa, fornecendo um mapa vazio como fallback.
    final data = doc.data() as Map<String, dynamic>? ?? {};
    // Converte de forma segura os dados de localização do documento.
    final locationData = data['location'] as Map<String, dynamic>?;

    // Retorna uma nova instância de ItemModel preenchida com dados do Firestore.
    return ItemModel(
      id: doc.id,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? 'pendente',
      imageUrl: data['imageUrl'] as String?,
      assetImage: data['assetImage'] as String?,
      phone: data['phone'] as String?,
      createdBy: data['createdBy'] as String?,
      // Se existirem dados de localização, cria um LocationModel a partir deles.
      location: locationData != null ? LocationModel.fromJson(locationData) : null,
    );
  }

  // Converte a instância de ItemModel para um mapa JSON, adequado para escrever no Firestore.
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'category': category,
      'status': status,
      'imageUrl': imageUrl,
      'assetImage': assetImage,
      // Converte o LocationModel para JSON se existir.
      'location': location?.toJson(),
      'phone': phone,
      'createdBy': createdBy,
    };
  }
}

// Representa uma localização geográfica com latitude e longitude.
class LocationModel {
  // A latitude da localização.
  final double latitude;
  // A longitude da localização.
  final double longitude;

  // Construtor para criar uma instância de LocationModel.
  LocationModel({
    required this.latitude,
    required this.longitude,
  });

  // Um construtor factory para criar um LocationModel a partir de um mapa JSON.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      // Faz o parse da latitude de forma segura, usando 0.0 como padrão se for nulo ou não for um número.
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      // Faz o parse da longitude de forma segura, usando 0.0 como padrão se for nulo ou não for um número.
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Converte a instância de LocationModel para um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
