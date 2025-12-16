// Importa os pacotes necessários.
import 'package:flutter/material.dart';
import '../utils/colors.dart';

// Um widget de botão personalizado e reutilizável.
class CustomButton extends StatelessWidget {
  // O texto a ser exibido no botão.
  final String text;
  // A função de callback que é chamada quando o botão é pressionado.
  final VoidCallback onPressed;
  // Uma flag para indicar se o botão está em estado de carregamento.
  final bool isLoading;
  // A cor de fundo do botão.
  final Color? backgroundColor;
  // A cor do texto no botão.
  final Color? textColor;

  // Construtor para o widget CustomButton.
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Faz com que o botão ocupe toda a largura disponível.
      height: 50,
      child: ElevatedButton(
        // Desativa o botão quando está no estado de carregamento.
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          // Usa a cor de fundo fornecida ou a cor primária da aplicação como fallback.
          backgroundColor: backgroundColor ?? AppColors.primary,
          // Usa a cor do texto fornecida ou branco como fallback.
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Exibe um indicador de progresso circular se estiver a carregar, caso contrário, exibe o texto.
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.white,
                ),
              ),
      ),
    );
  }
}
