// Doctor form view
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_form_controller.dart';
import '../../../global_widgets/app_widgets.dart';

/// Vue du formulaire de médecin
///
/// Cette vue affiche un formulaire pour créer ou modifier un médecin.
/// Le formulaire permet de saisir :
/// - Nom et prénom
/// - Identifiant de connexion
/// - Mot de passe (création ou modification)
/// - Services auxquels le médecin appartient
/// - Privilèges spéciaux (chef de service, etc.)
///
/// La vue s'adapte au mode édition ou création.
class DoctorFormView extends GetView<DoctorFormController> {
  /// Constructeur de la vue du formulaire médecin
  const DoctorFormView({super.key});

  /// Construit l'interface utilisateur du formulaire
  ///
  /// Returns : Widget Scaffold contenant le formulaire de médecin
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditing.value
                ? 'Modifier un Médecin'
                : 'Ajouter un Médecin',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Nom
                        AppTextField(
                          label: 'Nom',
                          controller: controller.nomController,
                          validator: controller.validateRequiredField,
                        ),

                        // Prénom
                        AppTextField(
                          label: 'Prénom',
                          controller: controller.prenomController,
                          validator: controller.validateRequiredField,
                        ),

                        // Login
                        AppTextField(
                          label: 'Login',
                          controller: controller.loginController,
                          validator: controller.validateRequiredField,
                        ),

                        // Password
                        AppTextField(
                          label: 'Mot de passe',
                          controller: controller.passwordController,
                          obscureText: true,
                          validator:
                              controller.isEditing.value
                                  ? null // Password optional when editing
                                  : controller.validateRequiredField,
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Privilèges',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Privileges
                        Obx(
                          () => Column(
                            children: [
                              AppCheckbox(
                                label: 'Anesthésiste',
                                value: controller.isAnesthesiste.value,
                                onChanged:
                                    (value) =>
                                        controller.isAnesthesiste.value =
                                            value ?? false,
                              ),
                              AppCheckbox(
                                label: 'Pédiatrique',
                                value: controller.isPediatrique.value,
                                onChanged:
                                    (value) =>
                                        controller.isPediatrique.value =
                                            value ?? false,
                              ),
                              AppCheckbox(
                                label: 'SAMU',
                                value: controller.isSamu.value,
                                onChanged:
                                    (value) =>
                                        controller.isSamu.value =
                                            value ?? false,
                              ),
                              AppCheckbox(
                                label: 'Intensiviste',
                                value: controller.isIntensiviste.value,
                                onChanged:
                                    (value) =>
                                        controller.isIntensiviste.value =
                                            value ?? false,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          'Paramètres de Garde',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Max gardes par mois
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Nombre maximum de gardes par mois'),
                            ),
                            Obx(
                              () => DropdownButton<int>(
                                value: controller.maxGardesParMois.value,
                                items:
                                    List.generate(15, (index) => index + 1).map(
                                      (int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(value.toString()),
                                        );
                                      },
                                    ).toList(),
                                onChanged: (int? value) {
                                  if (value != null) {
                                    controller.maxGardesParMois.value = value;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        // Jours min entre gardes
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Jours minimum entre deux gardes'),
                            ),
                            Obx(
                              () => DropdownButton<int>(
                                value: controller.joursMinEntreGardes.value,
                                items:
                                    List.generate(10, (index) => index + 1).map(
                                      (int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(value.toString()),
                                        );
                                      },
                                    ).toList(),
                                onChanged: (int? value) {
                                  if (value != null) {
                                    controller.joursMinEntreGardes.value =
                                        value;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Save button
                        AppButton(
                          text: 'Enregistrer',
                          icon: Icons.save,
                          onPressed: controller.saveDoctor,
                        ),
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
