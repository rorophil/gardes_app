// Schedule model for compatibility
// Note: This is kept for compatibility during migration

class Schedule {
  String id;
  String doctorId;
  String serviceId;
  DateTime date;

  Schedule(this.id, this.doctorId, this.serviceId, this.date);

  // Helper method to check if this schedule is on a specific date
  bool isOnDate(DateTime checkDate) {
    return date.year == checkDate.year &&
        date.month == checkDate.month &&
        date.day == checkDate.day;
  }

  // Helper method to format the date for display
  String get formattedDate {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
