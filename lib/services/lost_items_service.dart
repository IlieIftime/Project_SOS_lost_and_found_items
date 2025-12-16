// Importa os pacotes necessários para o Firestore e autenticação.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

// Uma classe de serviço para lidar com a lógica relacionada a itens perdidos.
// NOTA: Este serviço parece ser um duplicado ou uma versão mais antiga do ItemService.
// É recomendado fundir a sua funcionalidade no ItemService para evitar redundância.
class LostItemsService {
  // Instâncias dos serviços Firebase.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Reporta um item perdido para o Firestore.
  Future<void> reportLostItem({
    required String titulo,
    required String descricao,
    required String localizacao,
  }) async {
    // Obtém o utilizador atual do serviço de autenticação.
    final user = _authService.currentUser;

    // Garante que o utilizador está autenticado antes de reportar um item.
    if (user == null) {
      throw Exception('É necessário estar autenticado para reportar um item.');
    }

    // Adiciona o novo item perdido à coleção 'produtos_desaparecidos'.
    await _firestore.collection('produtos_desaparecidos').add({
      'titulo': titulo,
      'descricao': descricao,
      'localizacao': localizacao,
      'userId': user.id, // O ID do utilizador que está a reportar o item.
      'emailUser': user.email, // O email do utilizador.
      'createdAt': DateTime.now(), // O timestamp de quando o item foi reportado.
      'status': 'desaparecido',
    });
  }
}
