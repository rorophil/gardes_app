// Doctor model for Realm database
import 'package:realm/realm.dart';

part 'doctor_model.realm.dart';

enum Privilege {
  anesthesiste,
  pediatrique,
  samu,
  intensiviste
}

@RealmModel()
class _Doctor {
  @PrimaryKey()
  late ObjectId id;
  
  late String nom;
  late String prenom;
  late String login;
  late String password;
  
  // Privileges
  late bool isAnesthesiste;
  late bool isPediatrique;
  late bool isSamu;
  late bool isIntensiviste;
  
  // Unavailable days stored as ISO date strings (YYYY-MM-DD)
  late List<String> joursIndisponibles;
  
  // Maximum number of shifts per month
  late int maxGardesParMois;
  
  // Minimum days between shifts
  late int joursMinEntreGardes;
  
  // Helper method to check if the doctor has a specific privilege
  bool hasPrivilege(Privilege privilege) {
    switch (privilege) {
      case Privilege.anesthesiste:
        return isAnesthesiste;
      case Privilege.pediatrique:
        return isPediatrique;
      case Privilege.samu:
        return isSamu;
      case Privilege.intensiviste:
        return isIntensiviste;
    }
  }
  
  // Helper method to get all privileges as a list
  List<Privilege> get privileges {
    List<Privilege> result = [];
    if (isAnesthesiste) result.add(Privilege.anesthesiste);
    if (isPediatrique) result.add(Privilege.pediatrique);
    if (isSamu) result.add(Privilege.samu);
    if (isIntensiviste) result.add(Privilege.intensiviste);
    return result;
  }
  
  // Check if the doctor is available on a given date
  bool isAvailableOn(DateTime date) {
    String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return !joursIndisponibles.contains(dateString);
  }
  
  // Check if the doctor can take a shift on a given date
  bool canTakeShiftOn(DateTime date) {
    // First check if doctor is available on this day
    if (!isAvailableOn(date)) {
      return false;
    }
    
    // Additional checks could be implemented here, such as:
    // - Maximum shift count for the month
    // - Minimum days between shifts
    // - Other constraints
    
    return true;
  }
}
