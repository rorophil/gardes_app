// Schedule model for Hive database
import 'package:hive/hive.dart';

part 'schedule_hive_model.g.dart';

@HiveType(typeId: 2)
class ScheduleHive extends HiveObject {
  @HiveField(0)
  late String id;

  // References to doctor and service by ID
  @HiveField(1)
  late String doctorId;

  @HiveField(2)
  late String serviceId;

  // Date of the shift (stored as milliseconds since epoch)
  @HiveField(3)
  late int dateMilliseconds;

  ScheduleHive({
    required this.id,
    required this.doctorId,
    required this.serviceId,
    required this.dateMilliseconds,
  });

  // Getter for date
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dateMilliseconds);

  // Setter for date
  set date(DateTime value) => dateMilliseconds = value.millisecondsSinceEpoch;

  // Helper methods
  bool isWeekend() {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  bool isFriday() {
    return date.weekday == DateTime.friday;
  }

  bool isThursday() {
    return date.weekday == DateTime.thursday;
  }

  // For sorting and prioritizing shifts
  int get priority {
    if (isFriday()) return 1; // Highest priority
    if (isWeekend()) return 2;
    if (isThursday()) return 4; // Lowest priority
    return 3; // Other weekdays
  }

  // Helper method for creating a modified copy of the schedule
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

  // Helper method to check if this schedule is for a specific date
  bool isOnDate(DateTime targetDate) {
    final scheduleDate = date;
    return scheduleDate.year == targetDate.year &&
        scheduleDate.month == targetDate.month &&
        scheduleDate.day == targetDate.day;
  }

  // Helper method to get date as string
  String get dateString {
    final d = date;
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }
}
