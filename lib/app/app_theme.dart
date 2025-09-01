// Theme configuration
import 'package:flutter/material.dart';

/// Configuration des thèmes de l'application
///
/// Cette classe définit les thèmes clair et sombre de l'application
/// avec des styles cohérents pour tous les composants UI.
/// Utilise Material 3 Design System.
class AppTheme {
  /// Thème clair de l'application
  ///
  /// Utilise une palette de couleurs basée sur indigo avec
  /// une luminosité claire. Définit les styles pour :
  /// - AppBar avec élévation et titre centré
  /// - Cards avec élévation et marges
  /// - Boutons avec padding et bordures arrondies
  /// - Champs de texte avec bordures et remplissage
  /// - SnackBars flottantes
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
    cardTheme: const CardTheme(elevation: 4, margin: EdgeInsets.all(8)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    dividerTheme: DividerThemeData(thickness: 1, indent: 0, endIndent: 0),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
  );

  /// Thème sombre de l'application
  ///
  /// Utilise la même palette de couleurs que le thème clair
  /// mais avec une luminosité sombre. Partage les mêmes
  /// configurations de style pour maintenir la cohérence.
  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
    cardTheme: const CardTheme(elevation: 4, margin: EdgeInsets.all(8)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    dividerTheme: DividerThemeData(thickness: 1, indent: 0, endIndent: 0),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
  );
}
