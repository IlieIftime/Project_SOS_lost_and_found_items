import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  // Singleton (igual ao antigo)
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const _adminEmail = 'admin@sos.com';
  // Tempo máximo à espera do Firestore no login/registo (não bloqueia a UI).
  static const _fsTimeout = Duration(seconds: 8);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Garante uma sessão (anónima) para o modo convidado/preview.
  /// Nunca lança: se falhar, as regras públicas de leitura (aprovados) cobrem.
  Future<void> ensureSignedIn() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously().timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      debugPrint('ensureSignedIn (anónimo) falhou: $e');
    }
  }

  // LOGIN COM FIREBASE
  Future<UserModel?> login(String email, String password) async {
    try {
      final cred = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 20));

      final uid = cred.user!.uid;
      final mail = cred.user!.email ?? email;
      final isAdminEmail = mail.toLowerCase() == _adminEmail;

      // Perfil no Firestore: melhor esforço. Se falhar/demorar, o login
      // NÃO falha: o papel deriva do email (as regras também o fazem).
      var role = isAdminEmail ? 'admin' : 'user';
      final docRef = _firestore.collection('users').doc(uid);
      try {
        final doc = await docRef.get().timeout(_fsTimeout);
        if (!doc.exists) {
          _fireAndForget(docRef.set(
              UserModel(id: uid, email: mail, role: role).toJson()));
        } else {
          final stored = UserModel.fromJson(doc.data()!);
          role = isAdminEmail ? 'admin' : stored.role;
          if (isAdminEmail && stored.role != 'admin') {
            _fireAndForget(docRef.update({'role': 'admin'}));
          }
        }
      } catch (e) {
        debugPrint('Perfil Firestore indisponível no login (continua): $e');
      }

      _currentUser = UserModel(id: uid, email: mail, role: role);
      return _currentUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login FirebaseAuthException: ${e.code} ${e.message}');
      throw Exception(_mapAuthError(e));
    } on TimeoutException {
      throw Exception(
          'Sem resposta do Firebase. Verifica a ligação e tenta novamente.');
    } catch (e) {
      debugPrint('Login erro: $e');
      throw Exception('Erro ao iniciar sessão: $e');
    }
  }

  // REGISTO COM FIREBASE
  Future<UserModel?> register(String email, String password) async {
    try {
      final cred = await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(const Duration(seconds: 20));

      final uid = cred.user!.uid;
      final mail = cred.user!.email ?? email;
      final isAdminEmail = mail.toLowerCase() == _adminEmail;

      _currentUser = UserModel(
        id: uid,
        email: mail,
        role: isAdminEmail ? 'admin' : 'user',
      );

      // Escrita do perfil sem bloquear (antes demorava ~20s e dava erro
      // mesmo com a conta criada).
      _fireAndForget(
          _firestore.collection('users').doc(uid).set(_currentUser!.toJson()));

      return _currentUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('Registo FirebaseAuthException: ${e.code} ${e.message}');
      throw Exception(_mapAuthError(e));
    } on TimeoutException {
      throw Exception(
          'Sem resposta do Firebase. Verifica a ligação e tenta novamente.');
    } catch (e) {
      debugPrint('Registo erro: $e');
      throw Exception('Erro ao registar: $e');
    }
  }

  void _fireAndForget(Future<void> f) {
    f.catchError((Object e) => debugPrint('Escrita Firestore falhou: $e'));
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Utilizador não encontrado.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Email ou palavra-passe incorretos.';
      case 'email-already-in-use':
        return 'Já existe uma conta com este email.';
      case 'weak-password':
        return 'A palavra-passe é demasiado fraca.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'network-request-failed':
        return 'Falha de rede ao contactar o Firebase.';
      case 'too-many-requests':
        return 'Demasiadas tentativas. Aguarda uns minutos.';
      case 'operation-not-allowed':
        return 'Método de login desativado na consola Firebase.';
      default:
        return '${e.message ?? 'Erro de autenticação.'} (${e.code})';
    }
  }
}
