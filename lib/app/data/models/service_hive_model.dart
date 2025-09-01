/// Modèle de données pour un service médical utilisant Hive pour la persistance
/// Contient les informations sur les privilèges requis et les jours bloqués
import 'package:hive/hive.dart';
import 'doctor_hive_model.dart';

part 'service_hive_model.g.dart';

@HiveType(typeId: 1)
class ServiceHive extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String nom;

  // Privilèges requis pour travailler dans ce service (au moins une correspondance nécessaire)
  @HiveField(2)
  late bool requiresAnesthesiste;

  @HiveField(3)
  late bool requiresPediatrique;

  @HiveField(4)
  late bool requiresSamu;

  @HiveField(5)
  late bool requiresIntensiviste;

  // Jours bloqués où aucune garde n'est nécessaire (stockés comme chaînes de dates ISO YYYY-MM-DD)
  @HiveField(6)
  late List<String> joursBloquees;

  /// Constructeur pour créer une nouvelle instance de ServiceHive
  /// [id] : Identifiant unique du service
  /// [nom] : Nom du service
  /// [requiresAnesthesiste] : Privilège anesthésiste requis
  /// [requiresPediatrique] : Privilège pédiatrique requis
  /// [requiresSamu] : Privilège SAMU requis
  /// [requiresIntensiviste] : Privilège intensiviste requis
  /// [joursBloquees] : Liste des jours où le service est fermé
  ServiceHive({
    required this.id,
    required this.nom,
    required this.requiresAnesthesiste,
    required this.requiresPediatrique,
    required this.requiresSamu,
    required this.requiresIntensiviste,
    required this.joursBloquees,
  });

  /// Retourne la liste de tous les privilèges requis comme énumération
  List<Privilege> get privileges {
    List<Privilege> result = [];
    if (requiresAnesthesiste) result.add(Privilege.anesthesiste);
    if (requiresPediatrique) result.add(Privilege.pediatrique);
    if (requiresSamu) result.add(Privilege.samu);
    if (requiresIntensiviste) result.add(Privilege.intensiviste);
    return result;
  }

  /// Vérifie si une date est bloquée pour ce service
  /// [date] : La date à vérifier
  /// Retourne true si la date est bloquée
  bool isDateBlocked(DateTime date) {
    String dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return joursBloquees.contains(dateString);
  }

  /// Vérifie si un médecin peut travailler dans ce service
  /// [doctor] : Le médecin à vérifier
  /// Retourne true si le médecin possède au moins un des privilèges requis
  bool acceptsDoctor(DoctorHive doctor) {
    // Vérifier si le médecin possède au moins un des privilèges requis
    for (final privilege in privileges) {
      if (doctor.hasPrivilege(privilege)) {
        return true;
      }
    }
    return false;
  }

  /// Ajoute un jour bloqué au service
  /// [date] : La date à bloquer
  void addBlockedDay(DateTime date) {
    final dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    if (!joursBloquees.contains(dateString)) {
      joursBloquees.add(dateString);
    }
  }

  /// Supprime un jour bloqué du service
  /// [date] : La date à débloquer
  void removeBlockedDay(DateTime date) {
    final dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    joursBloquees.remove(dateString);
  }
}
