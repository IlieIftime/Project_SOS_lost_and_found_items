// Importa os pacotes necessários para o Firestore e Firebase Storage.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Importa os modelos e outros serviços.
import '../models/item_model.dart';
import 'auth_service.dart';

// Uma classe de serviço para lidar com toda a lógica relacionada a itens (operações CRUD).
class ItemService {
  // Padrão Singleton para garantir que apenas uma instância de ItemService é criada.
  static final ItemService _instance = ItemService._internal();
  factory ItemService() => _instance;
  ItemService._internal();

  // Instâncias dos serviços Firebase.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();

  // O nome da coleção do Firestore onde os itens são armazenados.
  final String _collection = 'produtos_desaparecidos';

  // Converte um DocumentSnapshot do Firestore para um ItemModel.
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

  // Busca todos los itens da coleção do Firestore.
  Future<List<ItemModel>> getItems() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc))
        .toList();
  }

  // Busca apenas os itens que foram aprovados.
  Future<List<ItemModel>> getApprovedItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection(_collection)
        .where('status', isEqualTo: 'aprovado')
        .get();

    return snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc))
        .toList();
  }

  // Busca apenas os itens que estão pendentes de aprovação (para uso do administrador).
  Future<List<ItemModel>> getPendingItems() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pendente')
        .get();

    return snapshot.docs
        .map((doc) => ItemModel.fromFirestore(doc))
        .toList();
  }

  // Cria um novo relatório de item no Firestore.
  Future<void> reportItem(ItemModel item) async {
    final user = _authService.currentUser;

    await _firestore.collection(_collection).add({
      'description': item.description,
      'category': item.category,
      'status': 'pendente', // Novos itens estão sempre pendentes.
      'imageUrl': item.imageUrl,
      'assetImage': item.assetImage,
      'phone': item.phone,
      'location': item.location != null ? {
        'latitude': item.location!.latitude,
        'longitude': item.location!.longitude,
      } : null,
      'createdBy': user?.id, // O ID do utilizador que criou o relatório.
      'userId': user?.id,
      'emailUser': user?.email,
      'createdAt': FieldValue.serverTimestamp(), // Timestamp da criação.
    });
  }

  // Aprova um item (para uso do administrador).
  Future<void> validateItem(String docId) async {
    await _firestore
        .collection(_collection)
        .doc(docId)
        .update({
      'status': 'aprovado', // Altera o estado para "aprovado".
      'updatedAt': FieldValue.serverTimestamp(), // Timestamp da atualização.
    });
  }

  // Apaga um item do Firestore e a sua imagem associada do Firebase Storage.
  Future<void> deleteItem(String docId, String? imageUrl) async {
    // Apaga o documento do Firestore.
    await _firestore.collection(_collection).doc(docId).delete();
    // Se houver um URL de imagem, apaga o ficheiro do Firebase Storage.
    if (imageUrl != null && imageUrl.startsWith('https')) {
      try {
        await _storage.refFromURL(imageUrl).delete();
      } catch (e) {
        // Imprime um erro se a eliminação do ficheiro falhar, mas não bloqueia a operação.
        print('Erro ao apagar o ficheiro do storage: $e');
      }
    }
  }
}
