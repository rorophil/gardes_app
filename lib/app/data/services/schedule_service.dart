// Schedule generation service
import 'package:get/get.dart';
import 'package:realm/realm.dart';
import '../models/doctor_model.dart';
import '../models/service_model.dart';
import '../models/schedule_model.dart';
import 'database_service.dart';

class ScheduleService extends GetxService {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  // Generate a monthly schedule for a specific service
  Future<List<Schedule>> generateMonthlySchedule(Service service, int year, int month) async {
    List<Schedule> schedules = [];
    List<Doctor> eligibleDoctors = _getEligibleDoctors(service);
    
    if (eligibleDoctors.isEmpty) {
      return schedules;
    }
    
    // Sort doctors by number of unavailable days (most unavailable first)
    eligibleDoctors.sort((a, b) => b.joursIndisponibles.length.compareTo(a.joursIndisponibles.length));
    
    // Create a list of dates for the month
    List<DateTime> dates = _getDatesInMonth(year, month);
    
    // Sort dates by priority (Fridays, weekends, then other days, with Thursdays last)
    dates.sort((a, b) {
      int priorityA = _getDatePriority(a);
      int priorityB = _getDatePriority(b);
      return priorityA.compareTo(priorityB);
    });
    
    // Try to assign doctors to dates
    for (DateTime date in dates) {
      // Skip if date is blocked for this service
      if (service.isDateBlocked(date)) {
        continue;
      }
      
      // Find eligible doctors for this date
      List<Doctor> availableDoctors = _getAvailableDoctorsForDate(
        eligibleDoctors, 
        date,
        schedules
      );
      
      if (availableDoctors.isNotEmpty) {
        // Sort by the number of shifts already assigned for this weekday (least first)
        availableDoctors.sort((a, b) {
          int shiftsA = _countShiftsByWeekday(a, date.weekday);
          int shiftsB = _countShiftsByWeekday(b, date.weekday);
          return shiftsA.compareTo(shiftsB);
        });
        
        // Assign first available doctor
        Doctor doctor = availableDoctors.first;
        Schedule schedule = _databaseService.createSchedule(
          doctor: doctor, 
          service: service, 
          date: date
        );
        schedules.add(schedule);
      }
    }
    
    return schedules;
  }
  
  // Helper methods
  List<Doctor> _getEligibleDoctors(Service service) {
    List<Doctor> allDoctors = _databaseService.getAllDoctors();
    return allDoctors.where((doctor) => service.acceptsDoctor(doctor)).toList();
  }
  
  List<DateTime> _getDatesInMonth(int year, int month) {
    List<DateTime> dates = [];
    
    DateTime start = DateTime(year, month, 1);
    DateTime end = DateTime(year, month + 1, 0); // Last day of month
    
    for (int i = 0; i < end.day; i++) {
      DateTime date = start.add(Duration(days: i));
      dates.add(date);
    }
    
    return dates;
  }
  
  int _getDatePriority(DateTime date) {
    if (date.weekday == DateTime.friday) return 0; // Highest priority
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) return 1;
    if (date.weekday == DateTime.thursday) return 3; // Lowest priority
    return 2; // Other weekdays
  }
  
  List<Doctor> _getAvailableDoctorsForDate(
    List<Doctor> doctors, 
    DateTime date,
    List<Schedule> currentSchedules
  ) {
    return doctors.where((doctor) {
      // Check if doctor is available on this date
      if (!doctor.isAvailableOn(date)) return false;
      
      // Check if the doctor already has a shift on this day in current schedules
      bool hasShiftOnDay = currentSchedules.any((schedule) =>
        schedule.doctorId == doctor.id &&
        schedule.date.year == date.year &&
        schedule.date.month == date.month &&
        schedule.date.day == date.day
      );
      
      if (hasShiftOnDay) return false;
      
      // Check minimum days between shifts
      for (final schedule in currentSchedules.where((s) => s.doctorId == doctor.id)) {
        int daysBetween = (schedule.date.difference(date).inHours / 24).abs().round();
        if (daysBetween < doctor.joursMinEntreGardes) {
          return false;
        }
      }
      
      // Check if the doctor has reached maximum shifts for this month
      int shiftsInMonth = currentSchedules.where((s) => 
        s.doctorId == doctor.id && 
        s.date.year == date.year && 
        s.date.month == date.month
      ).length;
      
      return shiftsInMonth < doctor.maxGardesParMois;
    }).toList();
  }
  
  int _countShiftsByWeekday(Doctor doctor, int weekday) {
    List<Schedule> doctorSchedules = _databaseService.getSchedulesByDoctor(doctor);
    return doctorSchedules.where((s) => s.date.weekday == weekday).length;
  }
  
  // Swap doctors between two schedules
  void swapDoctors(Schedule schedule1, Schedule schedule2) {
    ObjectId tempDoctorId = schedule1.doctorId;
    
    _databaseService.updateSchedule(
      schedule1..doctorId = schedule2.doctorId
    );
    
    _databaseService.updateSchedule(
      schedule2..doctorId = tempDoctorId
    );
  }
  
  // Change doctor for a specific schedule
  void changeDoctor(Schedule schedule, Doctor newDoctor) {
    _databaseService.updateSchedule(
      schedule..doctorId = newDoctor.id
    );
  }
}
