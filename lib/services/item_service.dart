import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/item_model.dart';
import 'auth_service.dart';

class ItemService {
  static final ItemService _instance = ItemService._internal();
  factory ItemService() => _instance;
  ItemService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  final String _collection = 'produtos_desaparecidos';

  /// 🔹 Converter Firestore → ItemModel
  ItemModel _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ItemModel(
      id: doc.id,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      status: data['status'] ?? 'pendente',
      imageUrl: data['imageUrl'],
      assetImage: data['assetImage'],
      phone: data['phone'] ?? '',
      createdBy: data['createdBy'],
      location: data['location'] != null ? LocationModel.fromJson(data['location']) : null,
    );
  }

  /// Buscar todos os itens
  Future<List<ItemModel>> getItems() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc))
        .toList();
  }

  /// Buscar itens aprovados
  Future<List<ItemModel>> getApprovedItems() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'aprovado')
        .get()
        .timeout(const Duration(seconds: 25));

    return snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc))
        .toList();
  }

  /// Buscar itens pendentes (admin)
  Future<List<ItemModel>> getPendingItems() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pendente')
        .get();

    return snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc))
        .toList();
  }

  /// Reportar item (criar no Firestore)
  Future<void> reportItem(ItemModel item) async {
    final user = _authService.currentUser;

    await _firestore.collection(_collection).add({
      'description': item.description,
      'category': item.category,
      'status': 'pendente',
      'imageUrl': item.imageUrl,
      'assetImage': item.assetImage,
      'phone': item.phone,
      'location': item.location != null ? {
        'latitude': item.location!.latitude,
        'longitude': item.location!.longitude,
      } : null,
      'createdBy': user?.id, // Corrected from uid to id
      'userId': user?.id,
      'emailUser': user?.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Aprovar item (admin)
  Future<void> validateItem(String docId) async {
    await _firestore
        .collection(_collection)
        .doc(docId)
        .update({
      'status': 'aprovado',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Apagar item (admin)
  Future<void> deleteItem(String docId, String? imageUrl) async {
    await _firestore.collection(_collection).doc(docId).delete();
    if (imageUrl != null && imageUrl.startsWith('https')) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (e) {
        print('Error deleting storage file: $e');
      }
    }
  }
}
