// Importa os pacotes necessários para operações assíncronas, manipulação de ficheiros, UI, e mais.
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:latlong2/latlong.dart' as ll;
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

// Importa modelos, serviços, widgets e utilitários personalizados.
import '../models/item_model.dart';
import '../services/item_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/colors.dart';
import 'map_picker_screen.dart';
import '../utils/tile_resolver.dart';
import '../utils/assets.dart';

// ReportFormScreen é um StatefulWidget para o formulário de relatório de itens.
class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  // Chave para o formulário e controladores de edição de texto.
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationSearchController = TextEditingController();

  // Serviços e utilitários.
  final _itemService = ItemService();
  final _imagePicker = ImagePicker();

  // Variáveis de estado.
  String _selectedCategory = 'Acessórios';
  String? _selectedAsset;
  XFile? _selectedImage;
  bool _isLoading = false;
  LocationModel? _selectedLocation;
  bool _requireLocation = true; // A seleção da localização é obrigatória.
  List<geocoding.Location> _locationSearchResults = [];
  Timer? _debounce;
  final MapController _mapController = MapController();

  // Lista de categorias.
  final List<String> _categories = [
    'Acessórios',
    'Chaves',
    'Documentos',
    'Eletrónicos',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    // Adiciona um listener ao controlador de pesquisa de localização para implementar o debounce.
    _locationSearchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (_locationSearchController.text.isNotEmpty) {
          _searchLocation(_locationSearchController.text);
        } else {
          setState(() {
            _locationSearchResults = [];
          });
        }
      });
    });
  }

  @override
  void dispose() {
    // Liberta os recursos dos controladores e do temporizador de debounce.
    _descriptionController.dispose();
    _phoneController.dispose();
    _locationSearchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Pesquisa uma localização com base numa string de consulta.
  Future<void> _searchLocation(String query) async {
    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(query);
      setState(() {
        _locationSearchResults = locations;
      });
    } catch (e) {
      // Ignora erros de geocodificação (ex: nenhum resultado encontrado).
    }
  }

  // Seleciona uma localização da lista de resultados da pesquisa.
  void _onLocationSearchResultSelected(geocoding.Location location) {
    setState(() {
      _selectedLocation = LocationModel(latitude: location.latitude, longitude: location.longitude);
      _locationSearchController.clear();
      _locationSearchResults = [];
    });
    // Move o mapa para a localização selecionada.
    _mapController.move(ll.LatLng(location.latitude, location.longitude), 15.0);
  }

  // Escolhe uma imagem da câmara ou da galeria.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Exibe um diálogo para escolher a fonte da imagem (câmara ou galeria).
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Câmara'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Submete o formulário de relatório.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_requireLocation && _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione a localização do item.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final item = ItemModel(
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        phone: _phoneController.text.trim(),
        imageUrl: _selectedImage != null
            ? 'https://via.placeholder.com/300x200?text=$_selectedCategory'
            : null,
        assetImage: _selectedAsset,
        location: _selectedLocation,
      );

      await _itemService.reportItem(item);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
          title: const Text('Item Reportado!'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'O seu item foi reportado com sucesso!',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'O item ficará pendente até que um administrador o aprove.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Após a aprovação, ele aparecerá na lista para todos os utilizadores.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao reportar item: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Obtém e usa a localização atual do utilizador.
  Future<void> _useMyLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissão de localização negada')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissão de localização negada permanentemente. Ative nas configurações.')));
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      setState(() {
        _selectedLocation = LocationModel(latitude: pos.latitude, longitude: pos.longitude);
      });
       _mapController.move(ll.LatLng(pos.latitude, pos.longitude), 15.0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao obter localização: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Item'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Secção de informações.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Preencha os dados do item perdido ou achado',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Campo de seleção de categoria.
              const Text('Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Campo de descrição.
              const Text('Descrição', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                label: 'Descrição do item',
                hint: 'Descreva o item em detalhe',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira uma descrição';
                  if (value.length < 10) return 'A descrição deve ter no mínimo 10 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Campo de imagem de exemplo.
              const Text('Imagem do Item (Opcional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAsset,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'Selecione uma imagem de exemplo',
                ),
                items: assetImages.map((asset) {
                  return DropdownMenuItem(value: asset, child: Text(asset.split('/').last));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedAsset = value);
                },
              ),
              const SizedBox(height: 24),

              // Secção de foto do item.
              const Text('Foto do Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_selectedImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_selectedImage!.path), height: 200, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _selectedImage = null),
                        style: IconButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                )
              else
                InkWell(
                  onTap: _showImageSourceDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 8),
                        Text('Adicionar Foto', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Toque para selecionar', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Campo de telefone de contacto.
              const Text('Telefone de contacto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _phoneController,
                label: 'Número de telefone',
                hint: 'Ex: 912345678',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Insira um número de telefone';
                  if (!RegExp(r'^[0-9]{9}$').hasMatch(value)) return 'Número inválido (9 dígitos)';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Barra de pesquisa de localização.
              const Text('Pesquisar Localização', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _locationSearchController,
                label: 'Endereço',
                hint: 'Digite um endereço para pesquisar',
                prefixIcon: Icons.search,
              ),
              // Exibe os resultados da pesquisa de localização.
              if (_locationSearchResults.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: _locationSearchResults.length,
                    itemBuilder: (context, index) {
                      final location = _locationSearchResults[index];
                      return ListTile(
                        title: Text('Localização $index'), // Nome de placeholder
                        subtitle: Text('Lat: ${location.latitude.toStringAsFixed(4)}, Lon: ${location.longitude.toStringAsFixed(4)}'),
                        onTap: () => _onLocationSearchResultSelected(location),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),

              // Cabeçalho do seletor de mapa.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Localização do item (obrigatória)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _useMyLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Usar a minha localização'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Pré-visualização do mapa.
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.of(context).push<LocationModel?>(
                    MaterialPageRoute(builder: (context) => MapPickerScreen(initialLocation: _selectedLocation)),
                  );
                  if (result != null) {
                     setState(() => _selectedLocation = result);
                     _mapController.move(ll.LatLng(result.latitude, result.longitude), 15.0);
                  }
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade200),
                  child: _selectedLocation == null
                      ? Center(child: Text('Toque para escolher a localização', style: TextStyle(color: AppColors.textSecondary)))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureBuilder<String?>(
                            future: TileResolver.getActiveTemplate(),
                            builder: (context, snap) {
                              if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                              if (!snap.hasData || snap.data == null) {
                                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Erro ao carregar tiles.'), const SizedBox(height:8), ElevatedButton(onPressed: () => setState((){}), child: const Text('Tentar novamente'))]));
                              }
                              final tmpl = snap.data!;
                              return FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  center: ll.LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
                                  zoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: tmpl,
                                    userAgentPackageName: 'com.example.app',
                                    tileProvider: NetworkTileProvider(),
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: ll.LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
                                        width: 40,
                                        height: 40,
                                        builder: (ctx) => const Icon(Icons.location_on, color: Colors.red, size: 36),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ),
              ),
              if (_selectedLocation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, Long: ${_selectedLocation!.longitude.toStringAsFixed(6)}'),
                ),
              const SizedBox(height: 24),
              // Botão de submissão.
              CustomButton(
                text: 'Reportar Item',
                onPressed: _submitForm,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
