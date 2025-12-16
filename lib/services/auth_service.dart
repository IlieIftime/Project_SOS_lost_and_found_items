// Importa os pacotes necessários para autenticação Firebase e Firestore.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importa o modelo de utilizador.
import '../models/user_model.dart';

// Uma classe de serviço para lidar com toda a lógica relacionada à autenticação.
class AuthService {
  // Padrão Singleton para garantir que apenas uma instância de AuthService é criada.
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Instâncias do FirebaseAuth e do FirebaseFirestore.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // O utilizador atualmente com sessão iniciada.
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Inicia sessão de um utilizador com email e senha usando o Firebase.
  Future<UserModel?> login(String email, String password) async {
    try {
      // Inicia sessão com as credenciais fornecidas.
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // Busca os dados do utilizador no Firestore.
      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();

      // Verifica se o email pertence a um administrador.
      final isAdminEmail = (cred.user!.email ?? email).toLowerCase() == 'admin@sos.com';

      if (!doc.exists) {
        // Se o documento do utilizador não existir, cria um novo.
        _currentUser = UserModel(
          id: uid,
          email: cred.user!.email ?? email,
          role: isAdminEmail ? 'admin' : 'user',
        );

        await docRef.set(_currentUser!.toJson());
      } else {
        // Se o documento existir, lê os dados.
        _currentUser = UserModel.fromJson(doc.data()!);

        // Se o email for de um admin mas a função no Firestore não for 'admin', atualiza-a.
        if (isAdminEmail && _currentUser!.role != 'admin') {
          _currentUser = UserModel(
            id: _currentUser!.id,
            email: _currentUser!.email,
            role: 'admin',
          );
          await docRef.update({'role': 'admin'});
        }
      }

      return _currentUser;
    } on FirebaseAuthException catch (e) {
      // Lida com erros de autenticação do Firebase.
      throw Exception(_mapAuthError(e));
    } catch (_) {
      // Lida com outros erros.
      throw Exception('Erro ao iniciar sessão. Tente novamente.');
    }
  }

  // Regista um novo utilizador com email e senha usando o Firebase.
  Future<UserModel?> register(String email, String password) async {
    try {
      // Cria um novo utilizador com as credenciais fornecidas.
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // Verifica se o email é de um administrador.
      final isAdminEmail = email.toLowerCase() == 'admin@sos.com';

      // Cria um novo modelo de utilizador.
      _currentUser = UserModel(
        id: uid,
        email: cred.user!.email ?? email,
        role: isAdminEmail ? 'admin' : 'user',
      );

      // Guarda os dados do novo utilizador no Firestore.
      await _firestore
          .collection('users')
          .doc(uid)
          .set(_currentUser!.toJson());

      return _currentUser;
    } on FirebaseAuthException catch (e) {
      // Lida com erros de autenticação do Firebase.
      throw Exception(_mapAuthError(e));
    } catch (_) {
      // Lida com outros erros.
      throw Exception('Erro ao registar. Tente novamente.');
    }
  }

  // Termina a sessão do utilizador atual.
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  // Mapeia os códigos de erro de autenticação do Firebase para mensagens amigáveis para o utilizador.
  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Utilizador não encontrado.';
      case 'wrong-password':
        return 'Palavra-passe incorreta.';
      case 'email-already-in-use':
        return 'Já existe uma conta com este email.';
      case 'weak-password':
        return 'A palavra-passe é demasiado fraca.';
      case 'invalid-email':
        return 'Email inválido.';
      default:
        return e.message ?? 'Ocorreu um erro de autenticação.';
    }
  }
}
