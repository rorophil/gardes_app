// Database service for Realm
import 'package:realm/realm.dart';
import '../models/doctor_model.dart';
import '../models/service_model.dart';
import '../models/schedule_model.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService extends GetxService {
  late final Realm _realm;
  
  Future<DatabaseService> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/gardes_app.realm';
    
    // Define schema
    final config = Configuration.local(
      [Doctor.schema, Service.schema, Schedule.schema],
      schemaVersion: 1,
      path: path
    );
    
    // Open Realm
    _realm = Realm(config);
    return this;
  }
  
  // =============== HELPER FACTORY METHODS ===============
  // Ces méthodes permettent de créer des objets de manière plus lisible
  
  // Doctor factory helper
  Doctor _createDoctorInstance({
    required ObjectId id,
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
    required List<String> joursIndisponibles,
  }) {
    return Doctor(
      id,
      nom,
      prenom,
      login,
      password,
      isAnesthesiste,
      isPediatrique,
      isSamu,
      isIntensiviste,
      maxGardesParMois,
      joursMinEntreGardes,
      joursIndisponibles: joursIndisponibles,
    );
  }
  
  // Service factory helper
  Service _createServiceInstance({
    required ObjectId id,
    required String nom,
    required bool requiresAnesthesiste,
    required bool requiresPediatrique,
    required bool requiresSamu,
    required bool requiresIntensiviste,
    required List<String> joursBloquees,
  }) {
    return Service(
      id,
      nom,
      requiresAnesthesiste,
      requiresPediatrique,
      requiresSamu,
      requiresIntensiviste,
      joursBloquees: joursBloquees,
    );
  }
  
  // Schedule factory helper
  Schedule _createScheduleInstance({
    required ObjectId id,
    required ObjectId doctorId,
    required ObjectId serviceId,
    required DateTime date,
  }) {
    return Schedule(
      id,
      doctorId,
      serviceId,
      date,
    );
  }
  
  // =============== DOCTOR CRUD OPERATIONS ===============
  List<Doctor> getAllDoctors() {
    return _realm.all<Doctor>().toList();
  }
  
  Doctor? getDoctor(ObjectId id) {
    return _realm.find<Doctor>(id);
  }
  
  Doctor createDoctor({
    required String nom,
    required String prenom,
    required String login,
    required String password,
    bool isAnesthesiste = false,
    bool isPediatrique = false,
    bool isSamu = false,
    bool isIntensiviste = false,
    List<String> joursIndisponibles = const [],
    int maxGardesParMois = 5,
    int joursMinEntreGardes = 3,
  }) {
    final doctor = _createDoctorInstance(
      id: ObjectId(),
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
      joursIndisponibles: joursIndisponibles,
    );
    
    _realm.write(() {
      _realm.add(doctor);
    });
    
    return doctor;
  }
  
  void updateDoctor(Doctor doctor) {
    _realm.write(() {
      _realm.add(doctor, update: true);
    });
  }
  
  void deleteDoctor(Doctor doctor) {
    _realm.write(() {
      _realm.delete(doctor);
    });
  }
  
  // =============== SERVICE CRUD OPERATIONS ===============
  List<Service> getAllServices() {
    return _realm.all<Service>().toList();
  }
  
  Service? getService(ObjectId id) {
    return _realm.find<Service>(id);
  }
  
  Service createService({
    required String nom,
    bool requiresAnesthesiste = false,
    bool requiresPediatrique = false,
    bool requiresSamu = false,
    bool requiresIntensiviste = false,
    List<String>? joursBloquees,
  }) {
    final service = _createServiceInstance(
      id: ObjectId(),
      nom: nom,
      requiresAnesthesiste: requiresAnesthesiste,
      requiresPediatrique: requiresPediatrique,
      requiresSamu: requiresSamu,
      requiresIntensiviste: requiresIntensiviste,
      joursBloquees: joursBloquees ?? [],
    );
    
    _realm.write(() {
      _realm.add(service);
    });
    
    return service;
  }
  
  void updateService(Service service) {
    _realm.write(() {
      _realm.add(service, update: true);
    });
  }
  
  void deleteService(Service service) {
    _realm.write(() {
      _realm.delete(service);
    });
  }
  
  // =============== SCHEDULE CRUD OPERATIONS ===============
  List<Schedule> getAllSchedules() {
    return _realm.all<Schedule>().toList();
  }
  
  List<Schedule> getSchedulesByMonth(int year, int month) {
    DateTime startDate = DateTime(year, month, 1);
    DateTime endDate = DateTime(year, month + 1, 0); // Last day of month
    
    return _realm.query<Schedule>(
      'date >= \$0 AND date <= \$1 SORT(date ASC)',
      [startDate, endDate],
    ).toList();
  }
  
  List<Schedule> getSchedulesByService(Service service, int year, int month) {
    DateTime startDate = DateTime(year, month, 1);
    DateTime endDate = DateTime(year, month + 1, 0); // Last day of month
    
    return _realm.query<Schedule>(
      'serviceId == \$0 AND date >= \$1 AND date <= \$2 SORT(date ASC)',
      [service.id, startDate, endDate],
    ).toList();
  }
  
  List<Schedule> getSchedulesByDoctor(Doctor doctor) {
    return _realm.query<Schedule>('doctorId == \$0 SORT(date ASC)', [doctor.id]).toList();
  }
  
  Schedule createSchedule({
    required Doctor doctor, 
    required Service service, 
    required DateTime date
  }) {
    final schedule = _createScheduleInstance(
      id: ObjectId(),
      doctorId: doctor.id,
      serviceId: service.id,
      date: date,
    );
    
    _realm.write(() {
      _realm.add(schedule);
    });
    
    return schedule;
  }
  
  void updateSchedule(Schedule schedule) {
    _realm.write(() {
      _realm.add(schedule, update: true);
    });
  }
  
  void deleteSchedule(Schedule schedule) {
    _realm.write(() {
      _realm.delete(schedule);
    });
  }
  
  // =============== HELPER METHODS FOR RELATIONSHIPS ===============
  Doctor? getDoctorById(ObjectId id) {
    return _realm.find<Doctor>(id);
  }
  
  Service? getServiceById(ObjectId id) {
    return _realm.find<Service>(id);
  }
  
  bool canDoctorWorkInService(Doctor doctor, Service service) {
    // Check if doctor has any of the required privileges
    for (final privilege in doctor.privileges) {
      if (service.privileges.contains(privilege)) {
        return true;
      }
    }
    return false;
  }
  
  void close() {
    _realm.close();
  }
}
