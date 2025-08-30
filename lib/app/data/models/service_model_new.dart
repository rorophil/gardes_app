// Service model for compatibility
// Note: This is kept for compatibility during migration

class Service {
  String id;
  String nom;

  // Requirements for doctors
  bool requiresAnesthesiste;
  bool requiresPediatrique;
  bool requiresSamu;
  bool requiresIntensiviste;

  // Days when this service is blocked (no shifts allowed)
  List<String> joursBloquees;

  Service(
    this.id,
    this.nom,
    this.requiresAnesthesiste,
    this.requiresPediatrique,
    this.requiresSamu,
    this.requiresIntensiviste, {
    List<String>? joursBloquees,
  }) : joursBloquees = joursBloquees ?? [];

  // Helper method to check if service is blocked on a specific date
  bool isBlockedOn(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return joursBloquees.contains(dateString);
  }

  // Helper method to add blocked day
  void addBlockedDay(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (!joursBloquees.contains(dateString)) {
      joursBloquees.add(dateString);
    }
  }

  // Helper method to remove blocked day
  void removeBlockedDay(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    joursBloquees.remove(dateString);
  }
}
