import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class LostItemsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> reportLostItem({
    required String titulo,
    required String descricao,
    required String localizacao,
  }) async {
    final user = _authService.currentUser;

    if (user == null) {
      throw Exception('Tem de estar autenticado para reportar um objeto.');
    }

    await _firestore.collection('produtos_desaparecidos').add({
      'titulo': titulo,
      'descricao': descricao,
      'localizacao': localizacao,
      'userId': user.id,
      'emailUser': user.email,
      'createdAt': DateTime.now(),
      'status': 'desaparecido',
    });
  }
}
