// Este ficheiro define o tema global e os estilos de texto para a aplicação.
// Centralizar os estilos garante uma aparência consistente e simplifica a manutenção.

import 'package:flutter/material.dart';
import 'colors.dart'; // Importa a paleta de cores da aplicação.

// Uma classe que fornece métodos estáticos para obter o tema e os estilos de texto da aplicação.
class AppStyles {
  // Getter para a configuração do tema claro da aplicação.
  static ThemeData get lightTheme {
    return ThemeData(
      // A cor primária para o tema.
      primaryColor: AppColors.primary,
      // A cor de fundo padrão para os scaffolds.
      scaffoldBackgroundColor: AppColors.background,
      // O esquema de cores, derivado de uma cor semente.
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        secondary: AppColors.secondary,
      ),
      // O tema padrão para as app bars.
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white, // Cor do texto e dos ícones.
        elevation: 2,
        centerTitle: true,
      ),
      // O tema padrão para os elevated buttons.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      // O tema padrão para os campos de entrada (input fields).
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // Um estilo de texto para os títulos principais (ex: títulos de ecrã).
  static TextStyle get heading1 => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  // Um estilo de texto para os títulos secundários.
  static TextStyle get heading2 => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  // O estilo de texto padrão para o corpo do conteúdo.
  static TextStyle get bodyText => const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      );

  // Um estilo de texto para legendas e texto menos importante.
  static TextStyle get caption => const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      );
}
