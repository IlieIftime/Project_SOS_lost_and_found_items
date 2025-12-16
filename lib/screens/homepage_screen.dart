// Importa os pacotes necessários do Flutter.
import 'package:flutter/material.dart';
// Importa modelos, serviços, utilitários e widgets personalizados.
import '../models/item_model.dart';
import '../services/auth_service.dart';
import '../services/item_service.dart';
import '../utils/colors.dart';
import '../widgets/asset_image_helper.dart';
import 'report_form_screen.dart';
import 'simple_map_screen.dart';
import 'login_screen.dart';

// O HomepageScreen é um StatefulWidget que exibe a lista de itens perdidos e achados.
class HomepageScreen extends StatefulWidget {
  // isPreview é um booleano para controlar o modo de pré-visualização.
  final bool isPreview;
  const HomepageScreen({super.key, this.isPreview = false});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  // Instâncias dos serviços de itens e autenticação.
  final _itemService = ItemService();
  final _authService = AuthService();
  // Listas para armazenar os itens e os itens filtrados.
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];
  // Booleano para controlar o estado de carregamento.
  bool _isLoading = true;
  // String para armazenar a categoria selecionada.
  String _selectedCategory = 'Todos';

  // Lista de categorias de itens.
  final List<String> _categories = [
    'Todos',
    'Acessórios',
    'Chaves',
    'Documentos',
    'Eletrónicos',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    // Carrega os itens ao iniciar o ecrã.
    _loadItems();
  }

  // Método para carregar os itens aprovados do serviço.
  Future<void> _loadItems() async {
    // Define o estado de carregamento como verdadeiro.
    setState(() => _isLoading = true);
    try {
      // Obtém os itens aprovados.
      final items = await _itemService.getApprovedItems();
      // Atualiza o estado com os itens carregados.
      setState(() {
        _items = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      // Define o estado de carregamento como falso em caso de erro.
      setState(() => _isLoading = false);
      if (mounted) {
        // Exibe uma SnackBar com a mensagem de erro.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar itens: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Método para filtrar os itens por categoria.
  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Todos') {
        // Se a categoria for 'Todos', exibe todos os itens.
        _filteredItems = _items;
      } else {
        // Filtra os itens pela categoria selecionada.
        _filteredItems = _items.where((item) => item.category == category).toList();
      }
    });
  }

  // Método para fazer logout do utilizador.
  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    // Navega para o ecrã de login após o logout.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Perdidos e Achados'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Botão para abrir o mapa.
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () async {
              // Filtra os itens que possuem localização.
              final itemsWithLocation = _items.where((item) => item.location != null).toList();
              if (itemsWithLocation.isEmpty) {
                if (!mounted) return;
                // Exibe uma SnackBar se não houver itens com localização.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nenhum item com localização para exibir no mapa'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              if (!mounted) return;
              // Navega para o ecrã do mapa.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SimpleMapScreen(items: itemsWithLocation),
                ),
              );
            },
            tooltip: 'Ver Mapa',
          ),
          // Botão de logout, visível apenas se não estiver no modo de pré-visualização.
          if (!widget.isPreview)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Sair',
            ),
        ],
      ),
      body: Column(
        children: [
          // Container para a lista de categorias.
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  // Chip de filtro para cada categoria.
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) => _filterByCategory(category),
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                );
              },
            ),
          ),

          // Corpo principal que exibe a lista de itens.
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    // Exibe uma mensagem se não houver itens.
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum item encontrado',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    // Exibe a lista de itens com um RefreshIndicator.
                    : RefreshIndicator(
                        onRefresh: _loadItems,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return _ItemCard(item: item, isPreview: widget.isPreview);
                          },
                        ),
                      ),
          ),
        ],
      ),
      // Botão de ação flutuante.
      floatingActionButton: widget.isPreview
          ? FloatingActionButton.extended(
              onPressed: () {
                // Navega para o ecrã de registo se estiver no modo de pré-visualização.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen(isSigningUp: true)),
                );
              },
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.person_add),
              label: const Text('Criar Conta para Reportar'),
            )
          : FloatingActionButton.extended(
              onPressed: () async {
                // Navega para o ecrã de formulário de relatório.
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReportFormScreen(),
                  ),
                );
                // Recarrega os itens se um novo item for reportado.
                if (result == true) {
                  _loadItems();
                }
              },
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.add),
              label: const Text('Reportar'),
            ),
    );
  }
}

// _ItemCard é um widget que exibe um único item na lista.
class _ItemCard extends StatelessWidget {
  final ItemModel item;
  final bool isPreview;

  const _ItemCard({required this.item, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    final assetPath = item.assetImage;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Exibe um diálogo com os detalhes do item ao tocar.
          showDialog(
            context: context,
            builder: (context) => _ItemDetailDialog(item: item, isPreview: isPreview),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Imagem do item.
            SizedBox(
              width: 72,
              height: 72,
              child: buildAssetImageIfExists(assetPath, width: 72, height: 72, fit: BoxFit.cover),
            ),
            // Detalhes do item.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Categoria do item.
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        // Ícone de localização se disponível.
                        if (item.location != null) ...[
                          const Spacer(),
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ver no mapa',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Descrição do item.
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _ItemDetailDialog é um diálogo que exibe os detalhes completos de um item.
class _ItemDetailDialog extends StatelessWidget {
  final ItemModel item;
  final bool isPreview;

  _ItemDetailDialog({required this.item, this.isPreview = false});

  @override
  Widget build(BuildContext context) {
    final assetPath = item.assetImage;
    final location = item.location;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do item.
            buildAssetImageIfExists(assetPath, width: double.infinity, height: 200, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoria do item.
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Rótulo da descrição.
                  const Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  // Descrição do item.
                  Text(item.description, style: const TextStyle(fontSize: 16)),
                  // Localização do item, se disponível.
                  if (location != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Localização:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lat: ${location.latitude.toStringAsFixed(4)}, Long: ${location.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                  // Contacto do utilizador, se não estiver no modo de pré-visualização.
                  if (!isPreview) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Contacto:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.phone ?? 'Não fornecido', style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Botão para fechar o diálogo.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Fechar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
