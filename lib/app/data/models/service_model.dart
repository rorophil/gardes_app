// Service model for Realm database
import 'package:realm/realm.dart';
import 'doctor_model.dart';

part 'service_model.realm.dart';

@RealmModel()
class _Service {
  @PrimaryKey()
  late ObjectId id;
  
  late String nom;
  
  // Required privileges to work in this service (at least one match is needed)
  late bool requiresAnesthesiste;
  late bool requiresPediatrique;
  late bool requiresSamu;
  late bool requiresIntensiviste;
  
  // Blocked days where no shifts are needed (stored as ISO date strings YYYY-MM-DD)
  late List<String> joursBloquees;
  
  // Helper method to get all required privileges as a list
  List<Privilege> get privileges {
    List<Privilege> result = [];
    if (requiresAnesthesiste) result.add(Privilege.anesthesiste);
    if (requiresPediatrique) result.add(Privilege.pediatrique);
    if (requiresSamu) result.add(Privilege.samu);
    if (requiresIntensiviste) result.add(Privilege.intensiviste);
    return result;
  }
  
  // Check if a date is blocked for this service
  bool isDateBlocked(DateTime date) {
    String dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return joursBloquees.contains(dateString);
  }
  
  // Check if a doctor can work in this service
  bool acceptsDoctor(Doctor doctor) {
    // Check if the doctor has any of the required privileges
    for (final privilege in privileges) {
      if (doctor.hasPrivilege(privilege)) {
        return true;
      }
    }
    return false;
  }
}
