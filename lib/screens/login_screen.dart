// Importa os pacotes e ficheiros necessários.
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/colors.dart';
import 'registration_screen.dart';
import 'homepage_screen.dart';
import 'admin/admin_dashboard_screen.dart';

// Um ecrã para o login do utilizador.
class LoginScreen extends StatefulWidget {
  // Uma flag para determinar se o utilizador deve ser redirecionado para o ecrã de registo.
  final bool isSigningUp;
  const LoginScreen({super.key, this.isSigningUp = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// O estado para o LoginScreen.
class _LoginScreenState extends State<LoginScreen> {
  // Chave global para identificar unicamente o widget do formulário.
  final _formKey = GlobalKey<FormState>();
  // Controladores para os campos de texto de email e senha.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Instância do serviço de autenticação.
  final _authService = AuthService();
  // Indicador de estado de carregamento.
  bool _isLoading = false;
  // Estado para alternar a visibilidade da senha.
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Se o utilizador pretende registar-se, redireciona para o ecrã de registo.
    if (widget.isSigningUp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const RegistrationScreen(),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    // Liberta os recursos dos controladores.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Lida com o processo de login.
  Future<void> _handleLogin() async {
    // Valida os campos do formulário.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Tenta fazer login com as credenciais fornecidas.
      final user = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        // Navega para o ecrã apropriado com base na função do utilizador.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => user.role == 'admin'
                ? const AdminDashboardScreen()
                : const HomepageScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Mostra uma SnackBar com a mensagem de erro.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logótipo ou ícone da aplicação.
                  Image.asset('assets/logo.jpg', width: 120, height: 120),
                  const SizedBox(height: 16),

                  // Título da aplicação.
                  Text(
                    'SOS Perdidos e Achados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo da aplicação.
                  Text(
                    'Encontre o que perdeu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Campo de entrada de email.
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'seu@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o seu email';
                      }
                      if (!value.contains('@')) {
                        return 'Por favor, insira um email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de entrada de senha.
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a sua senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter no mínimo 6 caracteres';
                      }
                      return null;
                    },
                    // Ícone para alternar a visibilidade da senha.
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão de login.
                  CustomButton(
                    text: 'Entrar',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Link para o ecrã de registo.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem conta? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegistrationScreen(),
                            ),
                          );
                        },
                        child: const Text('Registe-se'),
                      ),
                    ],
                  ),
                   const SizedBox(height: 12),
                  // Botão para ver itens sem conta (modo de pré-visualização).
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HomepageScreen(isPreview: true),
                        ),
                      );
                    },
                    child: const Text('Ver itens sem conta (Preview)'),
                  ),
                  const SizedBox(height: 24),

                  // Exibe as credenciais de teste para fácil acesso.
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔑 Credenciais de Teste',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Admin: admin@sos.com / admin123',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Utilizador: user@sos.com / user123',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
