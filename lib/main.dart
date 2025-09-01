/// Application de gestion des gardes médicales
///
/// Cette application Flutter utilise GetX pour la gestion d'état et la navigation,
/// et Hive comme base de données locale pour gérer :
/// - Les médecins et leurs informations
/// - Les services médicaux et leurs privilèges
/// - Les plannings de garde
/// - L'authentification des utilisateurs
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/data/providers/dependency_injection.dart';
import 'app/routes/app_routes.dart';
import 'app/app_theme.dart';

/// Point d'entrée principal de l'application
///
/// Initialise Hive, configure l'injection de dépendances
/// et lance l'application Flutter
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive
  await Hive.initFlutter();

  // Initialiser l'injection de dépendances
  await DependencyInjection.init();
  runApp(const MyApp());
}

/// Widget principal de l'application
///
/// Configure GetMaterialApp avec :
/// - Thèmes clair et sombre
/// - Système de navigation GetX
/// - Routes de l'application
/// - Transition par défaut (fade)
class MyApp extends StatelessWidget {
  /// Constructeur du widget principal
  const MyApp({super.key});

  /// Construit l'interface utilisateur de l'application
  ///
  /// Returns : Widget GetMaterialApp configuré avec les thèmes et routes
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gestion des Gardes Médicales',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.LOGIN,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
    );
  }
}

// L'application utilise GetX pour la gestion des routes
// La classe MyHomePage n'est plus nécessaire
