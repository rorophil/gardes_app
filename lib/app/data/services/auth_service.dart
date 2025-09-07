/// Service d'authentification pour la gestion des utilisateurs
/// Gère la connexion des administrateurs et des médecins
import 'package:get/get.dart';
import '../models/doctor_hive_model.dart';
import 'database_service.dart';

/// Énumération des rôles utilisateur disponibles
enum UserRole { admin, doctor }

class AuthService extends GetxService {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Variables réactives pour l'état d'authentification
  final Rx<DoctorHive?> currentUser = Rx<DoctorHive?>(null);
  final Rx<UserRole> currentRole = Rx<UserRole>(UserRole.doctor);

  // Identifiants administrateur codés en dur pour la simplicité
  // Dans une vraie application, ils seraient stockés de manière sécurisée
  static const String adminLogin = "admin";
  static const String adminPassword = "admin123";

  /// Vérifie si un utilisateur est connecté
  bool get isLoggedIn => currentUser.value != null || isAdminLoggedIn;

  /// Vérifie si l'administrateur est connecté
  bool get isAdminLoggedIn => currentRole.value == UserRole.admin;

  /// Authentifie un utilisateur avec login et mot de passe
  /// [login] : Identifiant de connexion
  /// [password] : Mot de passe
  /// Retourne true si l'authentification réussit
  Future<bool> login(String login, String password) async {
    // Vérifier les identifiants administrateur
    if (login == adminLogin && password == adminPassword) {
      currentRole.value = UserRole.admin;
      return true;
    }

    // Check for doctor login
    final doctors = _databaseService.getAllDoctors();
    for (final doctor in doctors) {
      if (doctor.login == login && doctor.password == password) {
        currentUser.value = doctor;
        currentRole.value = UserRole.doctor;
        return true;
      }
    }

    return false;
  }

  void logout() {
    currentUser.value = null;
    currentRole.value = UserRole.doctor;
  }

  bool canManageDoctors() {
    return isAdminLoggedIn;
  }

  bool canManageServices() {
    return isAdminLoggedIn;
  }

  bool canGenerateSchedules() {
    return isAdminLoggedIn;
  }

  bool canEditUnavailability() {
    return isLoggedIn;
  }

  bool canViewSchedules() {
    return isLoggedIn;
  }
}
