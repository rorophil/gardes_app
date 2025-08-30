// Database service for Hive
import 'package:hive/hive.dart';
import '../models/doctor_hive_model.dart';
import '../models/service_hive_model.dart';
import '../models/schedule_hive_model.dart';
import 'package:get/get.dart';

class DatabaseService extends GetxService {
  late final Box<DoctorHive> _doctorsBox;
  late final Box<ServiceHive> _servicesBox;
  late final Box<ScheduleHive> _schedulesBox;

  Future<DatabaseService> init() async {
    // Enregistrer les adapters Hive
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DoctorHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ServiceHiveAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ScheduleHiveAdapter());
    }

    // Ouvrir les boxes Hive
    _doctorsBox = await Hive.openBox<DoctorHive>('doctors');
    _servicesBox = await Hive.openBox<ServiceHive>('services');
    _schedulesBox = await Hive.openBox<ScheduleHive>('schedules');

    return this;
  }

  // =============== DOCTOR OPERATIONS ===============

  List<DoctorHive> getAllDoctors() {
    return _doctorsBox.values.toList();
  }

  DoctorHive? getDoctor(String id) {
    return _doctorsBox.get(id);
  }

  Future<DoctorHive> createDoctor({
    required String nom,
    required String prenom,
    required String login,
    required String password,
    required bool isAnesthesiste,
    required bool isPediatrique,
    required bool isSamu,
    required bool isIntensiviste,
    required int maxGardesParMois,
    required int joursMinEntreGardes,
    List<String>? joursIndisponibles,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final doctor = DoctorHive(
      id: id,
      nom: nom,
      prenom: prenom,
      login: login,
      password: password,
      isAnesthesiste: isAnesthesiste,
      isPediatrique: isPediatrique,
      isSamu: isSamu,
      isIntensiviste: isIntensiviste,
      maxGardesParMois: maxGardesParMois,
      joursMinEntreGardes: joursMinEntreGardes,
      joursIndisponibles: joursIndisponibles ?? [],
    );

    await _doctorsBox.put(id, doctor);
    return doctor;
  }

  Future<void> updateDoctor(DoctorHive doctor) async {
    await _doctorsBox.put(doctor.id, doctor);
  }

  Future<void> deleteDoctor(String id) async {
    await _doctorsBox.delete(id);
  }

  // =============== SERVICE OPERATIONS ===============

  List<ServiceHive> getAllServices() {
    return _servicesBox.values.toList();
  }

  ServiceHive? getService(String id) {
    return _servicesBox.get(id);
  }

  Future<ServiceHive> createService({
    required String nom,
    required bool requiresAnesthesiste,
    required bool requiresPediatrique,
    required bool requiresSamu,
    required bool requiresIntensiviste,
    List<String>? joursBloquees,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final service = ServiceHive(
      id: id,
      nom: nom,
      requiresAnesthesiste: requiresAnesthesiste,
      requiresPediatrique: requiresPediatrique,
      requiresSamu: requiresSamu,
      requiresIntensiviste: requiresIntensiviste,
      joursBloquees: joursBloquees ?? [],
    );

    await _servicesBox.put(id, service);
    return service;
  }

  Future<void> updateService(ServiceHive service) async {
    await _servicesBox.put(service.id, service);
  }

  Future<void> deleteService(String id) async {
    await _servicesBox.delete(id);
  }

  // =============== SCHEDULE OPERATIONS ===============

  List<ScheduleHive> getAllSchedules() {
    return _schedulesBox.values.toList();
  }

  List<ScheduleHive> getSchedulesByMonth(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // Last day of month

    return _schedulesBox.values.where((schedule) {
      final scheduleDate = schedule.date;
      return scheduleDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          scheduleDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<ScheduleHive> getSchedulesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _schedulesBox.values.where((schedule) {
      final scheduleDate = schedule.date;
      return scheduleDate.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          scheduleDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Future<ScheduleHive> createSchedule({
    required String doctorId,
    required String serviceId,
    required DateTime date,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final schedule = ScheduleHive(
      id: id,
      doctorId: doctorId,
      serviceId: serviceId,
      dateMilliseconds: date.millisecondsSinceEpoch,
    );

    await _schedulesBox.put(id, schedule);
    return schedule;
  }

  Future<void> updateSchedule(ScheduleHive schedule) async {
    await _schedulesBox.put(schedule.id, schedule);
  }

  Future<void> deleteSchedule(String id) async {
    await _schedulesBox.delete(id);
  }

  List<ScheduleHive> getSchedulesByDoctor(DoctorHive doctor) {
    return _schedulesBox.values
        .where((schedule) => schedule.doctorId == doctor.id)
        .toList();
  }

  List<ScheduleHive> getSchedulesByService(
    ServiceHive service,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _schedulesBox.values
        .where(
          (schedule) =>
              schedule.serviceId == service.id &&
              schedule.date.isAfter(startDate.subtract(Duration(days: 1))) &&
              schedule.date.isBefore(endDate.add(Duration(days: 1))),
        )
        .toList();
  }

  // =============== AUTHENTICATION ===============

  DoctorHive? authenticateDoctor(String login, String password) {
    for (var doctor in _doctorsBox.values) {
      if (doctor.login == login && doctor.password == password) {
        return doctor;
      }
    }
    return null;
  }

  // =============== HELPER METHODS ===============

  DoctorHive? getDoctorById(String id) {
    return _doctorsBox.get(id);
  }

  ServiceHive? getServiceById(String id) {
    return _servicesBox.get(id);
  }

  List<DoctorHive> getDoctorsForService(String serviceId) {
    final service = getService(serviceId);
    if (service == null) return [];

    return getAllDoctors()
        .where((doctor) => service.acceptsDoctor(doctor))
        .toList();
  }

  List<ScheduleHive> getSchedulesForDoctor(String doctorId) {
    return _schedulesBox.values
        .where((schedule) => schedule.doctorId == doctorId)
        .toList();
  }

  List<ScheduleHive> getSchedulesForService(String serviceId) {
    return _schedulesBox.values
        .where((schedule) => schedule.serviceId == serviceId)
        .toList();
  }

  // Check if a doctor is available on a specific date
  bool isDoctorAvailable(String doctorId, DateTime date) {
    final doctor = getDoctorById(doctorId);
    if (doctor == null) return false;

    // Check if doctor has marked this day as unavailable
    if (!doctor.isAvailableOn(date)) return false;

    // Check if doctor already has a schedule on this date
    final existingSchedules = getSchedulesForDoctor(doctorId);
    for (var schedule in existingSchedules) {
      if (schedule.isOnDate(date)) return false;
    }

    return true;
  }

  // Check minimum days between shifts
  bool respectsMinimumDaysBetweenShifts(String doctorId, DateTime date) {
    final doctor = getDoctorById(doctorId);
    if (doctor == null) return false;

    final existingSchedules = getSchedulesForDoctor(doctorId);
    for (var schedule in existingSchedules) {
      final daysBetween = date.difference(schedule.date).inDays.abs();
      if (daysBetween < doctor.joursMinEntreGardes) {
        return false;
      }
    }

    return true;
  }

  // Count shifts for a doctor in a specific month
  int countShiftsForDoctorInMonth(String doctorId, int year, int month) {
    final schedules = getSchedulesByMonth(year, month);
    return schedules.where((schedule) => schedule.doctorId == doctorId).length;
  }

  // Check if doctor has exceeded maximum shifts for the month
  bool hasExceededMaxShifts(String doctorId, int year, int month) {
    final doctor = getDoctorById(doctorId);
    if (doctor == null) return true;

    final currentShifts = countShiftsForDoctorInMonth(doctorId, year, month);
    return currentShifts >= doctor.maxGardesParMois;
  }

  // Close all boxes when disposing
  Future<void> close() async {
    await _doctorsBox.close();
    await _servicesBox.close();
    await _schedulesBox.close();
  }
}
