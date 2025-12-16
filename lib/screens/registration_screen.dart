// Importa os pacotes e ficheiros necessários.
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../utils/colors.dart';
import 'homepage_screen.dart';

// Um ecrã para o registo de novos utilizadores.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

// O estado para o RegistrationScreen.
class _RegistrationScreenState extends State<RegistrationScreen> {
  // Chave global para identificar unicamente o widget do formulário.
  final _formKey = GlobalKey<FormState>();
  // Controladores para os campos de texto de email, senha e confirmação de senha.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // Instância do serviço de autenticação.
  final _authService = AuthService();
  // Indicador de estado de carregamento.
  bool _isLoading = false;
  // Estado para alternar a visibilidade da senha.
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // Liberta os recursos dos controladores.
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Lida com o processo de registo do utilizador.
  Future<void> _handleRegister() async {
    // Valida os campos do formulário.
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Tenta registar um novo utilizador com as credenciais fornecidas.
      final user = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        // Navega para a homepage após o registo bem-sucedido.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomepageScreen(),
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
      appBar: AppBar(
        title: const Text('Registo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
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
                  // Ícone para o ecrã de registo.
                  Icon(
                    Icons.person_add_rounded,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),

                  // Título do ecrã.
                  Text(
                    'Criar Conta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtítulo do ecrã.
                  Text(
                    'Preencha os dados para se registar',
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
                  const SizedBox(height: 16),

                  // Campo de confirmação de senha.
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar Senha',
                    hint: '••••••••',
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme a sua senha';
                      }
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                    // Ícone para alternar a visibilidade da confirmação de senha.
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão de registo.
                  CustomButton(
                    text: 'Registar',
                    onPressed: _handleRegister,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Link para o ecrã de login.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tem conta? ',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Fazer Login'),
                      ),
                    ],
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
