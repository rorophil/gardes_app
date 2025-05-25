// Schedule model for Realm database
import 'package:realm/realm.dart';

part 'schedule_model.realm.dart';

@RealmModel()
class _Schedule {
  @PrimaryKey()
  late ObjectId id;
  
  // References to doctor and service by ID
  late ObjectId doctorId;
  late ObjectId serviceId;
  
  // Date of the shift
  late DateTime date;
  
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
  Schedule copyWith({
    ObjectId? id,
    ObjectId? doctorId,
    ObjectId? serviceId,
    DateTime? date
  }) {
    return Schedule(
      id ?? this.id,
      doctorId ?? this.doctorId,
      serviceId ?? this.serviceId,
      date ?? this.date,
    );
  }
}
