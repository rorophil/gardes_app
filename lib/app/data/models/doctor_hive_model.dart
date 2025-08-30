// Doctor model for Hive database
import 'package:hive/hive.dart';

part 'doctor_hive_model.g.dart';

enum Privilege { anesthesiste, pediatrique, samu, intensiviste }

@HiveType(typeId: 0)
class DoctorHive extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nom;

  @HiveField(2)
  late String prenom;

  @HiveField(3)
  late String login;

  @HiveField(4)
  late String password;

  // Privileges
  @HiveField(5)
  late bool isAnesthesiste;

  @HiveField(6)
  late bool isPediatrique;

  @HiveField(7)
  late bool isSamu;

  @HiveField(8)
  late bool isIntensiviste;

  // Unavailable days stored as ISO date strings (YYYY-MM-DD)
  @HiveField(9)
  late List<String> joursIndisponibles;

  // Maximum number of shifts per month
  @HiveField(10)
  late int maxGardesParMois;

  // Minimum days between shifts
  @HiveField(11)
  late int joursMinEntreGardes;

  DoctorHive({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.login,
    required this.password,
    required this.isAnesthesiste,
    required this.isPediatrique,
    required this.isSamu,
    required this.isIntensiviste,
    required this.joursIndisponibles,
    required this.maxGardesParMois,
    required this.joursMinEntreGardes,
  });

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

  // Helper method to get display name
  String get displayName => '$prenom $nom';

  // Helper method to check if doctor is available on a specific date
  bool isAvailableOn(DateTime date) {
    final dateString = date.toIso8601String().substring(0, 10);
    return !joursIndisponibles.contains(dateString);
  }

  // Alias for compatibility with schedule service
  bool canTakeShiftOn(DateTime date) => isAvailableOn(date);

  // Helper method to add unavailable day
  void addUnavailableDay(DateTime date) {
    final dateString = date.toIso8601String().substring(0, 10);
    if (!joursIndisponibles.contains(dateString)) {
      joursIndisponibles.add(dateString);
    }
  }

  // Helper method to remove unavailable day
  void removeUnavailableDay(DateTime date) {
    final dateString = date.toIso8601String().substring(0, 10);
    joursIndisponibles.remove(dateString);
  }
}
