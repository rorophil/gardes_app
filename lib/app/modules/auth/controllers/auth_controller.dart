/// Contrôleur d'authentification pour la gestion des connexions utilisateur
/// Gère la validation des identifiants et la navigation post-connexion
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService;

  // Contrôleurs de formulaire
  var loginFormKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  /// Constructeur avec injection de dépendance pour AuthService
  /// [authService] : Service d'authentification (optionnel, utilise Get.find par défaut)
  AuthController({AuthService? authService})
    : _authService = authService ?? Get.find<AuthService>();

  // Variables réactives pour l'état de l'interface
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    // Nettoyer les contrôleurs
    loginController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Valide le champ identifiant
  /// [value] : La valeur à valider
  /// Retourne un message d'erreur ou null si valide
  String? validateLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre identifiant';
    }
    return null;
  }

  /// Valide le champ mot de passe
  /// [value] : La valeur à valider
  /// Retourne un message d'erreur ou null si valide
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    return null;
  }

  /// Effectue la connexion de l'utilisateur
  /// Valide le formulaire, authentifie et redirige selon le rôle
  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final success = await _authService.login(
        loginController.text.trim(),
        passwordController.text,
      );

      if (success) {
        if (_authService.isAdminLoggedIn) {
          Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
        } else {
          Get.offAllNamed(AppRoutes.DOCTOR_DASHBOARD);
        }
      } else {
        errorMessage.value = 'Identifiant ou mot de passe incorrect';
      }
    } catch (e) {
      errorMessage.value = 'Une erreur est survenue: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
