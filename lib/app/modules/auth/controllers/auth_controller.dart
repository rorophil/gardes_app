// Authentication controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService;

  var loginFormKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  AuthController({AuthService? authService})
    : _authService = authService ?? Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onClose() {
    loginController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validateLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre identifiant';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    return null;
  }

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
