/// Définition des routes de l'application
/// Centralise toutes les routes et leurs liaisons (bindings) associées
import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_dashboard_view.dart';
import '../modules/admin/views/doctor_management_view.dart';
import '../modules/admin/views/doctor_form_view.dart';
import '../modules/admin/views/service_management_view.dart';
import '../modules/admin/views/service_form_view.dart';
import '../modules/doctor/bindings/doctor_binding.dart';
import '../modules/doctor/views/doctor_dashboard_view.dart';
import '../modules/doctor/views/availability_view.dart';
import '../modules/schedule/bindings/schedule_binding.dart';
import '../modules/schedule/views/schedule_generation_view.dart';
import '../modules/schedule/views/schedule_view.dart';

class AppRoutes {
  // Constantes des routes de l'application
  static const String LOGIN = '/login';
  static const String ADMIN_DASHBOARD = '/admin';
  static const String DOCTOR_MANAGEMENT = '/admin/doctors';
  static const String DOCTOR_FORM = '/admin/doctors/form';
  static const String SERVICE_MANAGEMENT = '/admin/services';
  static const String SERVICE_FORM = '/admin/services/form';
  static const String DOCTOR_DASHBOARD = '/doctor';
  static const String DOCTOR_AVAILABILITY = '/doctor/availability';
  static const String SCHEDULE_GENERATION = '/schedule/generate';
  static const String SCHEDULE_VIEW = '/schedule/view';

  /// Liste des pages de l'application avec leurs liaisons
  /// Chaque page est associée à sa route, sa vue et ses dépendances
  static final routes = [
    // Route de connexion
    GetPage(name: LOGIN, page: () => LoginView(), binding: AuthBinding()),
    // Routes d'administration
    GetPage(
      name: ADMIN_DASHBOARD,
      page: () => AdminDashboardView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: DOCTOR_MANAGEMENT,
      page: () => DoctorManagementView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: DOCTOR_FORM,
      page: () => DoctorFormView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: SERVICE_MANAGEMENT,
      page: () => ServiceManagementView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: SERVICE_FORM,
      page: () => ServiceFormView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: DOCTOR_DASHBOARD,
      page: () => DoctorDashboardView(),
      binding: DoctorBinding(),
    ),
    GetPage(
      name: DOCTOR_AVAILABILITY,
      page: () => AvailabilityView(),
      binding: DoctorBinding(),
    ),
    GetPage(
      name: SCHEDULE_GENERATION,
      page: () => ScheduleGenerationView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: SCHEDULE_VIEW,
      page: () => ScheduleView(),
      binding: ScheduleBinding(),
    ),
  ];
}
