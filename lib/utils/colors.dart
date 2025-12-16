// Este ficheiro define a paleta de cores para a aplicação.
// Usar uma classe centralizada para as cores garante consistência em toda a aplicação
// e facilita a atualização do tema.

import 'package:flutter/material.dart';

// Uma classe que contém todas as constantes de cores estáticas para a aplicação.
class AppColors {
  // A cor primária, usada para os principais elementos da UI, como barras de aplicação e botões.
  static const Color primary = Color(0xFF2196F3);

  // A cor secundária, usada para elementos complementares da UI.
  static const Color secondary = Color(0xFF03A9F4);

  // A cor de destaque (accent), usada para realçar e chamar a atenção para partes específicas da UI.
  static const Color accent = Color(0xFFFF5722);

  // A cor de fundo para a maioria dos ecrãs.
  static const Color background = Color(0xFFF5F5F5);

  // A cor primária do texto, para texto de alta ênfase.
  static const Color textPrimary = Color(0xFF212121);

  // A cor secundária do texto, para texto de média ênfase e dicas (hints).
  static const Color textSecondary = Color(0xFF757575);

  // A cor para mensagens e ícones de erro.
  static const Color error = Color(0xFFF44336);

  // A cor para mensagens e ícones de sucesso.
  static const Color success = Color(0xFF4CAF50);

  // A cor para mensagens e ícones de aviso.
  static const Color warning = Color(0xFFFFC107);
}
