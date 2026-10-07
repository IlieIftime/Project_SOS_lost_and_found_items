import 'package:flutter/material.dart';
import '../../models/item_model.dart';
import '../../services/auth_service.dart';
import '../../services/item_service.dart';
import '../../utils/colors.dart';
import '../../widgets/asset_image_helper.dart';
import '../login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final _itemService = ItemService();
  final _authService = AuthService();
  List<ItemModel> _pendingItems = [];
  List<ItemModel> _allItems = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
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

  Future<void> _validateItem(ItemModel item) async {
    if (item.id == null) return;
    try {
      await _itemService.validateItem(item.id!);
      await _loadItems(); // Refresh lists
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item validado com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao validar item: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteItem(ItemModel item) async {
    if (item.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Remoção'),
        content: const Text('Deseja realmente remover este item?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Remover')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _itemService.deleteItem(item.id!, item.imageUrl);
      await _loadItems(); // Refresh lists
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removido com sucesso!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover item: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildItemList(List<ItemModel> items, bool isAdmin, String? currentUserId) {
    if (items.isEmpty) {
      return Center(
        child: Text('Nenhum item para exibir.', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadItems,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final canDelete = isAdmin || (item.createdBy != null && item.createdBy == currentUserId);
          return _AdminItemCard(
            item: item,
            onValidate: item.status == 'pendente' ? () => _validateItem(item) : null,
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
            const Tab(text: 'Todos os Itens'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildItemList(_pendingItems, isAdmin, currentUser?.id),
                _buildItemList(_allItems, isAdmin, currentUser?.id),
              ],
            ),
    );
  }
}

class _AdminItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback? onValidate;
  final VoidCallback? onDelete;

  const _AdminItemCard({required this.item, this.onValidate, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final assetPath = item.assetImage;
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
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 200, color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported, size: 64)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(item.category, style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: item.status == 'aprovado' ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(item.status.toUpperCase(),
                          style: TextStyle(color: item.status == 'aprovado' ? AppColors.success : AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(locationText, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                  ],
                ),
                const SizedBox(height: 16),
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
