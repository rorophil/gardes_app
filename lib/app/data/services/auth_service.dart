// Authentication service
import 'package:get/get.dart';
import '../models/doctor_model.dart';
import 'database_service.dart';

enum UserRole {
  admin,
  doctor
}

class AuthService extends GetxService {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final Rx<Doctor?> currentUser = Rx<Doctor?>(null);
  final Rx<UserRole> currentRole = Rx<UserRole>(UserRole.doctor);
  
  // Hardcoded admin credentials for simplicity
  // In a real app, you would store admin credentials securely
  static const String adminLogin = "admin";
  static const String adminPassword = "admin123";
  
  bool get isLoggedIn => currentUser.value != null || isAdminLoggedIn;
  bool get isAdminLoggedIn => currentRole.value == UserRole.admin;
  
  Future<bool> login(String login, String password) async {
    // Check for admin login
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
