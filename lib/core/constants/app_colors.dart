import 'package:flutter/material.dart';

/// Paleta de colores de VozViva — Ngigua de San Marcos Tlacoyalco.
/// Extraída del logotipo oficial: terracota cobre, verde olivo y magenta vivo.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFB5622A);       // Terracota cobre (logo)
  static const Color secondary = Color(0xFF5F7A35);     // Verde olivo (logo)
  static const Color background = Color(0xFFFAF6F0);    // Crema blanco
  static const Color textPrimary = Color(0xFF2D1B0E);   // Café oscuro
  static const Color textSecondary = Color(0xFF7A6555); // Café medio
  static const Color accent = Color(0xFFD41A6C);        // Magenta vivo (logo)
  static const Color error = Color(0xFFD64045);         // Rojo suave
  static const Color cardBackground = Colors.white;
  static const Color lightGray = Color(0xFFE8E0D5);
  static const Color divider = Color(0xFFD4C9BB);

  // Colores por nivel de dificultad
  static const Color difficultyEasy = Color(0xFF5F7A35);    // Verde olivo
  static const Color difficultyMedium = Color(0xFFB5622A);  // Terracota cobre
  static const Color difficultyHard = Color(0xFFD41A6C);    // Magenta

  // Colores de retroalimentación de pronunciación
  static const Color feedbackGood = Color(0xFF5F7A35);
  static const Color feedbackTry = Color(0xFFB5622A);
  static const Color feedbackSaved = Color(0xFF5B8FBF);

  // Gradiente de bienvenida
  static const List<Color> welcomeGradient = [
    Color(0xFFB5622A),
    Color(0xFFD41A6C),
  ];
}
