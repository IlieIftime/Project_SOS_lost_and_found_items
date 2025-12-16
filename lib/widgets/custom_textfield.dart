// Importa o pacote Material do Flutter.
import 'package:flutter/material.dart';

// Um widget de campo de texto personalizado e reutilizável.
class CustomTextField extends StatelessWidget {
  // O controlador para o campo de texto.
  final TextEditingController controller;
  // O rótulo a ser exibido acima do campo de texto.
  final String label;
  // O texto de dica a ser exibido dentro do campo de texto quando está vazio.
  final String? hint;
  // Uma flag para indicar se o texto deve ser ocultado (ex: para senhas).
  final bool obscureText;
  // O tipo de teclado a ser exibido.
  final TextInputType keyboardType;
  // Uma função para validar a entrada.
  final String? Function(String?)? validator;
  // O número máximo de linhas que o campo de texto pode ter.
  final int maxLines;
  // Um widget a ser exibido no final do campo de texto.
  final Widget? suffixIcon;
  // Um ícone a ser exibido no início do campo de texto.
  final IconData? prefixIcon;

  // Construtor para o widget CustomTextField.
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // O TextFormField oferece capacidades de validação.
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        // Exibe o ícone de prefixo se não for nulo.
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
