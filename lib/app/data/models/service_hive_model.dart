// Service model for Hive database
import 'package:hive/hive.dart';
import 'doctor_hive_model.dart';

part 'service_hive_model.g.dart';

@HiveType(typeId: 1)
class ServiceHive extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nom;

  // Required privileges to work in this service (at least one match is needed)
  @HiveField(2)
  late bool requiresAnesthesiste;

  @HiveField(3)
  late bool requiresPediatrique;

  @HiveField(4)
  late bool requiresSamu;

  @HiveField(5)
  late bool requiresIntensiviste;

  // Blocked days where no shifts are needed (stored as ISO date strings YYYY-MM-DD)
  @HiveField(6)
  late List<String> joursBloquees;

  ServiceHive({
    required this.id,
    required this.nom,
    required this.requiresAnesthesiste,
    required this.requiresPediatrique,
    required this.requiresSamu,
    required this.requiresIntensiviste,
    required this.joursBloquees,
  });

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
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return joursBloquees.contains(dateString);
  }

  // Check if a doctor can work in this service
  bool acceptsDoctor(DoctorHive doctor) {
    // Check if the doctor has any of the required privileges
    for (final privilege in privileges) {
      if (doctor.hasPrivilege(privilege)) {
        return true;
      }
    }
    return false;
  }

  // Helper method to add a blocked day
  void addBlockedDay(DateTime date) {
    final dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (!joursBloquees.contains(dateString)) {
      joursBloquees.add(dateString);
    }
  }

  // Helper method to remove a blocked day
  void removeBlockedDay(DateTime date) {
    final dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    joursBloquees.remove(dateString);
  }
}
