// Login view
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../global_widgets/app_widgets.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: controller.loginFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.medical_services,
                          size: 80,
                          color: Colors.indigo,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Gestion des Gardes Médicales',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          label: 'Identifiant',
                          controller: controller.loginController,
                          validator: controller.validateLogin,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Mot de passe',
                          controller: controller.passwordController,
                          obscureText: true,
                          validator: controller.validatePassword,
                        ),
                        const SizedBox(height: 24),
                        Obx(() => AppButton(
                              text: 'Connexion',
                              onPressed: controller.login,
                              isLoading: controller.isLoading.value,
                              icon: Icons.login,
                            )),
                        const SizedBox(height: 16),
                        Obx(() {
                          if (controller.errorMessage.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                controller.errorMessage.value,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        })
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
