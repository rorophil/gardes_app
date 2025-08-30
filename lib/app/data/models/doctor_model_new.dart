// Doctor model for compatibility
// Note: This is kept for compatibility during migration

enum Privilege { anesthesiste, pediatrique, samu, intensiviste }

class Doctor {
  String id;
  String nom;
  String prenom;
  String login;
  String password;

  // Privileges
  bool isAnesthesiste;
  bool isPediatrique;
  bool isSamu;
  bool isIntensiviste;

  // Unavailable days stored as ISO date strings (YYYY-MM-DD)
  List<String> joursIndisponibles;

  // Maximum number of shifts per month
  int maxGardesParMois;

  // Minimum days between shifts
  int joursMinEntreGardes;

  Doctor(
    this.id,
    this.nom,
    this.prenom,
    this.login,
    this.password,
    this.isAnesthesiste,
    this.isPediatrique,
    this.isSamu,
    this.isIntensiviste,
    this.maxGardesParMois,
    this.joursMinEntreGardes, {
    List<String>? joursIndisponibles,
  }) : joursIndisponibles = joursIndisponibles ?? [];

  // Helper method to check if doctor can take a shift on a specific date
  bool canTakeShiftOn(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return !joursIndisponibles.contains(dateString);
  }

  // Helper method to add unavailable day
  void addUnavailableDay(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (!joursIndisponibles.contains(dateString)) {
      joursIndisponibles.add(dateString);
    }
  }

  // Helper method to remove unavailable day
  void removeUnavailableDay(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    joursIndisponibles.remove(dateString);
  }

  // Method to check if doctor has specific privilege
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
}
