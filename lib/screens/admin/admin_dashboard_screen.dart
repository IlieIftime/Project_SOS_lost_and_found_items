// Importa os pacotes e ficheiros necessários.
import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../services/auth_service.dart';
import '../../services/item_service.dart';
import '../../utils/colors.dart';
import '../../widgets/asset_image_helper.dart';
import '../login_screen.dart';

// Um ecrã para os administradores gerirem os itens reportados.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

// O estado para o AdminDashboardScreen.
class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  // Instâncias de serviços para gestão de itens e autenticação.
  final _itemService = ItemService();
  final _authService = AuthService();

  // Listas para guardar os itens pendentes e todos os itens.
  List<ItemModel> _pendingItems = [];
  List<ItemModel> _allItems = [];
  // Indicador do estado de carregamento.
  bool _isLoading = true;
  // Controlador para a barra de separadores (tabs).
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inicializa o controlador de separadores com dois separadores.
    _tabController = TabController(length: 2, vsync: this);
    // Carrega os itens quando o ecrã é inicializado.
    _loadItems();
  }

  @override
  void dispose() {
    // Liberta os recursos do controlador de separadores.
    _tabController.dispose();
    super.dispose();
  }

  // Busca tanto os itens pendentes como todos os itens do serviço de itens.
  Future<void> _loadItems() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Busca os itens pendentes e todos os itens em paralelo.
      final pending = await _itemService.getPendingItems();
      final all = await _itemService.getItems();
      if (mounted) {
        setState(() {
          _pendingItems = pending;
          _allItems = all;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar itens: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // Valida um item específico, mudando o seu estado para 'aprovado'.
  Future<void> _validateItem(ItemModel item) async {
    if (item.id == null) return;
    try {
      await _itemService.validateItem(item.id!);
      await _loadItems(); // Atualiza as listas após a validação.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item validado com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao validar o item: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // Apaga um item específico do sistema.
  Future<void> _deleteItem(ItemModel item) async {
    if (item.id == null) return;

    // Mostra um diálogo de confirmação antes de apagar.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: const Text('Tem a certeza que deseja remover este item?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Remover'), style: TextButton.styleFrom(foregroundColor: AppColors.error)),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _itemService.deleteItem(item.id!, item.imageUrl);
      await _loadItems(); // Atualiza as listas após a remoção.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removido com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover o item: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // Faz logout do utilizador atual e navega para o ecrã de login.
  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Remove todas as rotas anteriores.
      );
    }
  }

  // Constrói a lista de itens para um determinado separador.
  Widget _buildItemList(List<ItemModel> items, bool isAdmin, String? currentUserId) {
    if (items.isEmpty) {
      return Center(
        child: Text('Nenhum item para exibir.', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
      );
    }

    // Um indicador de atualização (pull-to-refresh) para recarregar os itens.
    return RefreshIndicator(
      onRefresh: _loadItems,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          // Determina se o utilizador atual pode apagar o item.
          final canDelete = isAdmin || (item.createdBy != null && item.createdBy == currentUserId);
          return _AdminItemCard(
            item: item,
            // Fornece o callback de validação apenas para itens pendentes.
            onValidate: item.status == 'pendente' ? () => _validateItem(item) : null,
            // Fornece o callback de remoção se o utilizador tiver permissão.
            onDelete: canDelete ? () => _deleteItem(item) : null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final isAdmin = currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Administração'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadItems, tooltip: 'Recarregar'),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Sair'),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            // Separador para itens pendentes, com um emblema a mostrar a contagem.
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Pendentes'),
                  if (_pendingItems.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(10)),
                      child: Text('${_pendingItems.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            // Separador para todos os itens.
            const Tab(text: 'Todos os Itens'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Mostra um indicador de carregamento enquanto os itens são buscados.
          : TabBarView(
              controller: _tabController,
              children: [
                // O conteúdo para o separador 'Pendentes'.
                _buildItemList(_pendingItems, isAdmin, currentUser?.id),
                // O conteúdo para o separador 'Todos os Itens'.
                _buildItemList(_allItems, isAdmin, currentUser?.id),
              ],
            ),
    );
  }
}

// Um widget de cartão para exibir um item no painel de administração.
class _AdminItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onValidate; // Callback para o botão de validar.
  final VoidCallback? onDelete; // Callback para o botão de apagar.

  const _AdminItemCard({required this.item, this.onValidate, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final assetPath = item.assetImage;
    // Formata a string de localização.
    final locationText = item.location != null
        ? 'Lat: ${item.location!.latitude.toStringAsFixed(4)}, Long: ${item.location!.longitude.toStringAsFixed(4)}'
        : 'Localização não disponível';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exibe a imagem do item se disponível.
          if (assetPath?.isNotEmpty == true)
            buildAssetImageIfExists(assetPath, width: double.infinity, height: 200, fit: BoxFit.cover)
          else if (item.imageUrl?.isNotEmpty == true)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                item.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                // Mostra um placeholder se a imagem não carregar.
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 200, color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 64)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exibe as tags de categoria and estado.
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(item.category, style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: item.status == 'aprovado' ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(item.status.toUpperCase(),
                          style: TextStyle(color: item.status == 'aprovado' ? AppColors.success : AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Descrição do item.
                Text(item.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                // Informação da localização.
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(locationText, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  ],
                ),
                const SizedBox(height: 16),
                // Botões de ação (Validar e Remover).
                Row(
                  children: [
                    if (onValidate != null)
                      Expanded(
                        child: ElevatedButton.icon(
                            onPressed: onValidate,
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Validar'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white)),
                      ),
                    if (onValidate != null && onDelete != null) const SizedBox(width: 8),
                    if (onDelete != null)
                      Expanded(
                        child: ElevatedButton.icon(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Remover'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
