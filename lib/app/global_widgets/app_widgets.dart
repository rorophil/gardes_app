// Shared widgets for the application
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Widget de champ de texte personnalisé pour l'application
///
/// Ce widget fournit un champ de texte réutilisable avec un style cohérent
/// et des fonctionnalités de validation intégrées.
class AppTextField extends StatelessWidget {
  /// Libellé du champ
  final String label;

  /// Texte d'aide optionnel
  final String? hint;

  /// Contrôleur pour gérer le contenu du champ
  final TextEditingController controller;

  /// Masque le texte (pour les mots de passe)
  final bool obscureText;

  /// Fonction de validation du champ
  final String? Function(String?)? validator;

  /// Type de clavier à afficher
  final TextInputType keyboardType;

  /// Nombre maximum de lignes
  final int? maxLines;

  /// Constructeur du widget AppTextField
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  /// Construit l'interface utilisateur du champ de texte
  ///
  /// Returns : Widget Padding contenant un TextFormField stylisé
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

/// Widget de case à cocher personnalisé pour l'application
///
/// Ce widget fournit une case à cocher avec un libellé associé,
/// suivant le style de l'application.
class AppCheckbox extends StatelessWidget {
  /// Libellé de la case à cocher
  final String label;

  /// État actuel de la case (cochée ou non)
  final bool value;

  /// Callback appelé lors du changement d'état
  final ValueChanged<bool?> onChanged;

  /// Constructeur du widget AppCheckbox
  const AppCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// Construit l'interface utilisateur de la case à cocher
  ///
  /// Returns : Widget Row avec case à cocher et libellé
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Checkbox(value: value, onChanged: onChanged), Text(label)],
    );
  }
}

/// Widget de sélecteur de date personnalisé pour l'application
///
/// Ce widget affiche une date et permet de la modifier via
/// un sélecteur de date natif.
class AppDatePicker extends StatelessWidget {
  /// Libellé du sélecteur de date
  final String label;

  /// Date actuellement sélectionnée
  final DateTime selectedDate;

  /// Callback appelé lors du changement de date
  final Function(DateTime) onDateChanged;

  /// Constructeur du widget AppDatePicker
  const AppDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateChanged,
  });

  /// Construit l'interface utilisateur du sélecteur de date
  ///
  /// Returns : Widget Padding contenant un Row avec libellé, date et bouton
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null && picked != selectedDate) {
                onDateChanged(picked);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Widget de bouton personnalisé pour l'application
///
/// Ce widget fournit un bouton avec support pour :
/// - Indicateur de chargement
/// - Icône optionnelle
/// - Style personnalisé
class AppButton extends StatelessWidget {
  /// Texte du bouton
  final String text;

  /// Callback appelé lors du clic
  final VoidCallback onPressed;

  /// Indique si le bouton est en cours de chargement
  final bool isLoading;

  /// Couleur personnalisée du bouton
  final Color? color;

  /// Icône optionnelle du bouton
  final IconData? icon;

  /// Constructeur du widget AppButton
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.icon,
  });

  /// Construit l'interface utilisateur du bouton
  ///
  /// Affiche un indicateur de chargement ou une icône selon l'état
  ///
  /// Returns : Widget ElevatedButton stylisé
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon, size: 20),
            ),
          Text(text),
        ],
      ),
    );
  }
}

/// Widget de dialogue de confirmation personnalisé
///
/// Ce widget affiche un dialogue modal pour confirmer une action
/// avec des boutons d'annulation et de confirmation.
class ConfirmDialog extends StatelessWidget {
  /// Titre du dialogue
  final String title;

  /// Message du dialogue
  final String message;

  /// Texte du bouton de confirmation
  final String confirmText;

  /// Texte du bouton d'annulation
  final String cancelText;

  /// Callback appelé lors de la confirmation
  final VoidCallback onConfirm;

  /// Constructeur du widget ConfirmDialog
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmer',
    this.cancelText = 'Annuler',
    required this.onConfirm,
  });

  /// Affiche un dialogue de confirmation
  ///
  /// [title] : Titre du dialogue
  /// [message] : Message à afficher
  /// [confirmText] : Texte du bouton de confirmation
  /// [cancelText] : Texte du bouton d'annulation
  /// [onConfirm] : Callback de confirmation
  ///
  /// Returns : Future qui se complète quand le dialogue est fermé
  static Future<void> show({
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    required VoidCallback onConfirm,
  }) async {
    await Get.dialog(
      ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
      ),
    );
  }

  /// Construit l'interface utilisateur du dialogue de confirmation
  ///
  /// Returns : Widget AlertDialog avec titre, message et boutons d'action
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text(cancelText)),
        ElevatedButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
