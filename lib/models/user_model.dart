// Representa uma conta de utilizador na aplicação.
class UserModel {
  // O identificador único para o utilizador, tipicamente o UID do Firebase Auth.
  final String id;
  // O endereço de email do utilizador, usado para login.
  final String email;
  // A função (role) do utilizador, que determina as suas permissões ('user' ou 'admin').
  final String role;

  // Construtor para criar uma instância de UserModel.
  UserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  // Um construtor factory para criar um UserModel a partir de um mapa JSON.
  // Isto é útil para desserializar dados do utilizador de uma base de dados como o Firestore.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Faz o parse do id de forma segura, usando uma string vazia como padrão se for nulo.
      id: json['id'] ?? '',
      // Faz o parse do email de forma segura, usando uma string vazia como padrão se for nulo.
      email: json['email'] ?? '',
      // Faz o parse da função de forma segura, usando 'user' como padrão se for nulo.
      role: json['role'] ?? 'user',
    );
  }

  // Converte a instância de UserModel para um mapa JSON.
  // Isto é útil para serializar dados do utilizador para serem armazenados numa base de dados.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }
}
