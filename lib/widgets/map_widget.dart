// Importa o pacote Material do Flutter.
import 'package:flutter/material.dart';
// Importa o modelo de item para definir a estrutura de dados dos itens.
import '../models/item_model.dart';

/// Contrato abstrato (interface) para um widget de mapa.
///
/// Esta classe abstrata define as propriedades e métodos necessários que qualquer implementação
/// de widget de mapa na aplicação deve ter. Isto permite o uso de fornecedores de mapas intercambiáveis
/// (ex: Google Maps, OpenStreetMap) sem alterar o código que o chama.
/// As implementações desta classe podem ser um StatefulWidget ou um StatelessWidget.
abstract class MapWidget {
  // Uma lista de itens a serem exibidos como marcadores no mapa.
  List<ItemModel> get items;
  
  // O ponto central inicial do mapa.
  LatLng? get initialCenter;
  
  // O nível de zoom inicial do mapa.
  double get initialZoom;
  
  // Uma função de callback que é chamada quando o controlador do mapa é criado.
  // O controlador pode ser usado para mover o mapa programaticamente.
  void Function(dynamic controller)? get onMapCreated;
  
  // Uma função de callback que é chamada quando um marcador no mapa é tocado.
  // Fornece o `ItemModel` associado ao marcador tocado.
  void Function(ItemModel)? get onMarkerTap;
}

/// Um simples contentor para LatLng para evitar o acoplamento a pacotes externos de mapas nos chamadores.
///
/// Esta classe fornece uma forma leve e livre de dependências para representar
/// coordenadas geográficas, garantindo que o resto da aplicação não precise de importar uma
/// biblioteca de mapa específica apenas para lidar com dados de localização.
class LatLng {
  // A coordenada de latitude.
  final double latitude;
  // A coordenada de longitude.
  final double longitude;
  
  // Construtor para a classe LatLng.
  const LatLng(this.latitude, this.longitude);
}
