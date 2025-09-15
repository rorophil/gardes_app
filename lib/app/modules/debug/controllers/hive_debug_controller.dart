/// Contrôleur pour l'interface de debug des tables Hive
/// Permet de visualiser et gérer les données stockées en local
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/doctor_hive_model.dart';
import '../../../data/models/service_hive_model.dart';
import '../../../data/models/schedule_hive_model.dart';

class HiveDebugController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Variables réactives pour les données
  final RxList<DoctorHive> doctors = <DoctorHive>[].obs;
  final RxList<ServiceHive> services = <ServiceHive>[].obs;
  final RxList<ScheduleHive> schedules = <ScheduleHive>[].obs;

  // Variables réactives pour l'état
  final RxBool isLoading = false.obs;
  final RxString selectedTable = 'doctors'.obs;

  // Statistiques
  final RxInt totalDoctors = 0.obs;
  final RxInt totalServices = 0.obs;
  final RxInt totalSchedules = 0.obs;

  /// Vérifie si l'interface de debug est disponible
  bool get isDebugMode => kDebugMode;

  @override
  void onInit() {
    super.onInit();
    if (isDebugMode) {
      loadAllData();
    }
  }

  /// Charge toutes les données depuis Hive
  Future<void> loadAllData() async {
    if (!isDebugMode) return;

    isLoading.value = true;
    try {
      doctors.value = _databaseService.getAllDoctors();
      services.value = _databaseService.getAllServices();
      schedules.value = _databaseService.getAllSchedules();

      // Mettre à jour les statistiques
      totalDoctors.value = doctors.length;
      totalServices.value = services.length;
      totalSchedules.value = schedules.length;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données Hive: \${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Change la table sélectionnée
  void selectTable(String tableName) {
    selectedTable.value = tableName;
  }

  /// Efface toutes les données d'une table (avec confirmation)
  Future<void> clearTable(String tableName) async {
    if (!isDebugMode) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmation'),
        content: Text(
          'Voulez-vous vraiment supprimer toutes les données de la table "\$tableName" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        switch (tableName) {
          case 'doctors':
            for (final doctor in doctors) {
              await _databaseService.deleteDoctor(doctor.id);
            }
            break;
          case 'services':
            for (final service in services) {
              await _databaseService.deleteService(service.id);
            }
            break;
          case 'schedules':
            for (final schedule in schedules) {
              await _databaseService.deleteSchedule(schedule.id);
            }
            break;
        }

        await loadAllData();
        Get.snackbar(
          'Succès',
          'Table "\$tableName" vidée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de vider la table: \${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  /// Crée des données de test
  Future<void> createTestData() async {
    if (!isDebugMode) return;

    try {
      // Vider toutes les tables avant de créer les données de test (séquentiellement)
      for (final doctor in doctors) {
        await _databaseService.deleteDoctor(doctor.id);
      }
      for (final service in services) {
        await _databaseService.deleteService(service.id);
      }
      for (final schedule in schedules) {
        await _databaseService.deleteSchedule(schedule.id);
      }

      // Attendre un peu pour que les suppressions soient bien effectives
      await Future.delayed(const Duration(milliseconds: 100));

      // Créer des médecins de test
      await _databaseService.createDoctor(
        nom: 'Dupont',
        prenom: 'Jean',
        login: 'jdupont',
        password: 'test123',
        isAnesthesiste: true,
        isPediatrique: false,
        isSamu: false,
        isIntensiviste: false,
        maxGardesParMois: 7,
        joursMinEntreGardes: 3,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await _databaseService.createDoctor(
        nom: 'Martin',
        prenom: 'Marie',
        login: 'mmartin',
        password: 'test123',
        isAnesthesiste: true,
        isPediatrique: true,
        isSamu: true,
        isIntensiviste: false,
        maxGardesParMois: 7,
        joursMinEntreGardes: 3,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // Créer 25 médecins anesthésistes supplémentaires (total: 27 médecins)
      final List<Map<String, String>> medecinsData = [
        {'nom': 'Bernard', 'prenom': 'Pierre'},
        {'nom': 'Durand', 'prenom': 'Sophie'},
        {'nom': 'Moreau', 'prenom': 'Antoine'},
        {'nom': 'Laurent', 'prenom': 'Isabelle'},
        {'nom': 'Simon', 'prenom': 'François'},
        {'nom': 'Michel', 'prenom': 'Catherine'},
        {'nom': 'Leroy', 'prenom': 'Philippe'},
        {'nom': 'Roux', 'prenom': 'Nathalie'},
        {'nom': 'David', 'prenom': 'Christophe'},
        {'nom': 'Bertrand', 'prenom': 'Véronique'},
        {'nom': 'Thomas', 'prenom': 'Stéphane'},
        {'nom': 'Robert', 'prenom': 'Sylvie'},
        {'nom': 'Petit', 'prenom': 'Laurent'},
        {'nom': 'Richard', 'prenom': 'Brigitte'},
        {'nom': 'Garcia', 'prenom': 'Pascal'},
        {'nom': 'Rousseau', 'prenom': 'Chantal'},
        {'nom': 'Blanc', 'prenom': 'Olivier'},
        {'nom': 'Guerin', 'prenom': 'Martine'},
        {'nom': 'Muller', 'prenom': 'Thierry'},
        {'nom': 'Henry', 'prenom': 'Dominique'},
        {'nom': 'Roussel', 'prenom': 'Alain'},
        {'nom': 'Nicolas', 'prenom': 'Françoise'},
        {'nom': 'Perrin', 'prenom': 'Bruno'},
        {'nom': 'Morin', 'prenom': 'Christine'},
        {'nom': 'Girard', 'prenom': 'Patrick'},
      ];

      // Créer tous les médecins supplémentaires séquentiellement
      for (int i = 0; i < medecinsData.length; i++) {
        final medecin = medecinsData[i];
        final login =
            '${medecin['prenom']!.toLowerCase().substring(0, 1)}${medecin['nom']!.toLowerCase()}';

        await _databaseService.createDoctor(
          nom: medecin['nom']!,
          prenom: medecin['prenom']!,
          login: login,
          password: 'test123',
          isAnesthesiste: true, // Tous anesthésistes
          isPediatrique: i % 3 == 0, // Un tiers pédiatriques (variation)
          isSamu: i % 4 == 0, // Un quart SAMU (variation)
          isIntensiviste: false, // Aucun intensiviste
          maxGardesParMois: 7, // Maximum 7 gardes par mois
          joursMinEntreGardes: 3, // Minimum 3 jours entre les gardes
        );
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Créer des services de test
      await _databaseService.createService(
        nom: 'Centre',
        requiresAnesthesiste: true,
        requiresPediatrique: false,
        requiresSamu: false,
        requiresIntensiviste: false,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await _databaseService.createService(
        nom: 'Maternité',
        requiresAnesthesiste: true,
        requiresPediatrique: false,
        requiresSamu: false,
        requiresIntensiviste: false,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      await _databaseService.createService(
        nom: 'Samu',
        requiresAnesthesiste: true,
        requiresPediatrique: false,
        requiresSamu: true,
        requiresIntensiviste: true,
      );
      await Future.delayed(const Duration(milliseconds: 100));

      // Attendre un peu pour que toutes les données soient bien enregistrées
      await Future.delayed(const Duration(milliseconds: 100));

      await loadAllData();
      Get.snackbar(
        'Succès',
        'Données de test créées avec succès (${doctors.length} médecins, ${services.length} services)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer les données de test: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }

  /// Exporte les données sous forme de texte
  String exportData() {
    final buffer = StringBuffer();

    buffer.writeln('=== EXPORT DONNÉES HIVE ===');
    buffer.writeln('Date: ${DateTime.now()}');
    buffer.writeln();

    // Médecins
    buffer.writeln('MÉDECINS (${doctors.length}):');
    for (final doctor in doctors) {
      buffer.writeln('- ${doctor.nom} ${doctor.prenom} (${doctor.login})');
      buffer.writeln(
        '  Privilèges: A:${doctor.isAnesthesiste} P:${doctor.isPediatrique} S:${doctor.isSamu} I:${doctor.isIntensiviste}',
      );
      buffer.writeln('  Max gardes/mois: ${doctor.maxGardesParMois}');
      buffer.writeln(
        '  Jours indisponibles: ${doctor.joursIndisponibles.length}',
      );
      buffer.writeln();
    }

    // Services
    buffer.writeln('SERVICES (${services.length}):');
    for (final service in services) {
      buffer.writeln('- ${service.nom}');
      buffer.writeln(
        '  Requis: A:${service.requiresAnesthesiste} P:${service.requiresPediatrique} S:${service.requiresSamu} I:${service.requiresIntensiviste}',
      );
      buffer.writeln('  Jours bloqués: ${service.joursBloquees.length}');
      buffer.writeln();
    }

    // Plannings
    buffer.writeln('PLANNINGS (${schedules.length}):');
    for (final schedule in schedules) {
      final doctor = doctors.firstWhereOrNull((d) => d.id == schedule.doctorId);
      final service = services.firstWhereOrNull(
        (s) => s.id == schedule.serviceId,
      );
      buffer.writeln(
        '- ${schedule.dateString}: ${doctor?.displayName ?? "Médecin inconnu"} -> ${service?.nom ?? "Service inconnu"}',
      );
    }

    return buffer.toString();
  }
}
