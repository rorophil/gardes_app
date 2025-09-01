/// Modèle de données pour un planning de garde utilisant Hive pour la persistance
/// Contient les références au médecin, service et la date de la garde
import 'package:hive/hive.dart';

part 'schedule_hive_model.g.dart';

@HiveType(typeId: 2)
class ScheduleHive extends HiveObject {
  @HiveField(0)
  late String id;

  // Références vers le médecin et le service par ID
  @HiveField(1)
  late String doctorId;

  @HiveField(2)
  late String serviceId;

  // Date de la garde (stockée en millisecondes depuis l'époque)
  @HiveField(3)
  late int dateMilliseconds;

  /// Constructeur pour créer une nouvelle instance de ScheduleHive
  /// [id] : Identifiant unique du planning
  /// [doctorId] : Identifiant du médecin assigné
  /// [serviceId] : Identifiant du service concerné
  /// [dateMilliseconds] : Date de la garde en millisecondes
  ScheduleHive({
    required this.id,
    required this.doctorId,
    required this.serviceId,
    required this.dateMilliseconds,
  });

  /// Getter pour récupérer la date comme objet DateTime
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dateMilliseconds);

  /// Setter pour définir la date comme objet DateTime
  set date(DateTime value) => dateMilliseconds = value.millisecondsSinceEpoch;

  /// Vérifie si la garde est prévue un week-end
  /// Retourne true si c'est samedi ou dimanche
  bool isWeekend() {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// Vérifie si la garde est prévue un vendredi
  /// Retourne true si c'est vendredi
  bool isFriday() {
    return date.weekday == DateTime.friday;
  }

  /// Vérifie si la garde est prévue un jeudi
  /// Retourne true si c'est jeudi
  bool isThursday() {
    return date.weekday == DateTime.thursday;
  }

  /// Retourne la priorité de la garde pour le tri et la planification
  /// 1 = priorité maximale (vendredi), 4 = priorité minimale (jeudi)
  int get priority {
    if (isFriday()) return 1; // Priorité maximale
    if (isWeekend()) return 2;
    if (isThursday()) return 4; // Priorité minimale
    return 3; // Autres jours de la semaine
  }

  /// Crée une copie modifiée du planning
  /// [id] : Nouvel identifiant (optionnel)
  /// [doctorId] : Nouvel identifiant de médecin (optionnel)
  /// [serviceId] : Nouvel identifiant de service (optionnel)
  /// [date] : Nouvelle date (optionnel)
  /// Retourne une nouvelle instance de ScheduleHive
  ScheduleHive copyWith({
    String? id,
    String? doctorId,
    String? serviceId,
    DateTime? date,
  }) {
    return ScheduleHive(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      serviceId: serviceId ?? this.serviceId,
      dateMilliseconds: date?.millisecondsSinceEpoch ?? this.dateMilliseconds,
    );
  }

  /// Vérifie si ce planning correspond à une date spécifique
  /// [targetDate] : La date à comparer
  /// Retourne true si les dates correspondent (jour, mois, année)
  bool isOnDate(DateTime targetDate) {
    final scheduleDate = date;
    return scheduleDate.year == targetDate.year &&
        scheduleDate.month == targetDate.month &&
        scheduleDate.day == targetDate.day;
  }

  /// Retourne la date sous forme de chaîne formatée (YYYY-MM-DD)
  String get dateString {
    final d = date;
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }
}
