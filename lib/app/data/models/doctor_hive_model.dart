/// Modèle de données pour un médecin utilisant Hive pour la persistance
/// Contient toutes les informations nécessaires pour la gestion des gardes
import 'package:hive/hive.dart';

part 'doctor_hive_model.g.dart';

/// Énumération des privilèges médicaux disponibles
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

  // Jours indisponibles stockés comme chaînes de dates ISO (YYYY-MM-DD)
  @HiveField(9)
  late List<String> joursIndisponibles;

  // Nombre maximum de gardes par mois
  @HiveField(10)
  late int maxGardesParMois;

  // Nombre minimum de jours entre deux gardes
  @HiveField(11)
  late int joursMinEntreGardes;

  /// Constructeur pour créer une nouvelle instance de DoctorHive
  /// [id] : Identifiant unique du médecin
  /// [nom] : Nom de famille du médecin
  /// [prenom] : Prénom du médecin
  /// [login] : Identifiant de connexion
  /// [password] : Mot de passe
  /// [isAnesthesiste] : Privilège anesthésiste
  /// [isPediatrique] : Privilège pédiatrique
  /// [isSamu] : Privilège SAMU
  /// [isIntensiviste] : Privilège intensiviste
  /// [joursIndisponibles] : Liste des jours où le médecin n'est pas disponible
  /// [maxGardesParMois] : Nombre maximum de gardes par mois
  /// [joursMinEntreGardes] : Nombre minimum de jours entre deux gardes
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

  /// Vérifie si le médecin possède un privilège spécifique
  /// [privilege] : Le privilège à vérifier
  /// Retourne true si le médecin possède le privilège
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

  /// Retourne le nom complet du médecin pour l'affichage
  String get displayName => '$prenom $nom';

  /// Vérifie si le médecin est disponible à une date donnée
  /// [date] : La date à vérifier
  /// Retourne true si le médecin est disponible
  bool isAvailableOn(DateTime date) {
    final dateString = date.toIso8601String().substring(0, 10);
    return !joursIndisponibles.contains(dateString);
  }

  /// Alias pour la compatibilité avec le service de planification
  /// [date] : La date à vérifier
  /// Retourne true si le médecin peut prendre une garde
  bool canTakeShiftOn(DateTime date) => isAvailableOn(date);

  /// Ajoute un jour d'indisponibilité
  /// [date] : La date à ajouter comme indisponible
  void addUnavailableDay(DateTime date) {
    final dateString = date.toIso8601String().substring(0, 10);
    if (!joursIndisponibles.contains(dateString)) {
      joursIndisponibles.add(dateString);
    }
  }

  /// Supprime un jour d'indisponibilité
  /// [date] : La date à retirer de la liste des indisponibilités
  void removeUnavailableDay(DateTime date) {
    final dateString = date.toIso8601String().substring(0, 10);
    joursIndisponibles.remove(dateString);
  }
}
