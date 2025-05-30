import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gardes_app/app/routes/app_routes.dart';

void main() {
  group('AppRoutes Tests', () {
    test('should have all required routes defined', () {
      expect(AppRoutes.LOGIN, equals('/login'));
      expect(AppRoutes.ADMIN_DASHBOARD, equals('/admin'));
      expect(AppRoutes.DOCTOR_DASHBOARD, equals('/doctor'));
      expect(AppRoutes.SCHEDULE_VIEW, equals('/schedule'));
      expect(AppRoutes.SCHEDULE_GENERATION, equals('/schedule/generate'));
      expect(AppRoutes.SERVICE_MANAGEMENT, equals('/admin/services'));
      expect(AppRoutes.SERVICE_FORM, equals('/admin/services/form'));
      expect(AppRoutes.DOCTOR_MANAGEMENT, equals('/admin/doctors'));
      expect(AppRoutes.DOCTOR_FORM, equals('/admin/doctors/form'));
      expect(AppRoutes.DOCTOR_AVAILABILITY, equals('/doctor/availability'));
    });

    test('should have all routes mapped to pages', () {
      final routes = AppRoutes.routes;

      // Verify that all route constants are actually used in the routes list
      final routePaths = routes.map((page) => page.name).toList();

      expect(routePaths, contains(AppRoutes.LOGIN));
      expect(routePaths, contains(AppRoutes.ADMIN_DASHBOARD));
      expect(routePaths, contains(AppRoutes.DOCTOR_DASHBOARD));
      expect(routePaths, contains(AppRoutes.SCHEDULE_VIEW));
      expect(routePaths, contains(AppRoutes.SCHEDULE_GENERATION));
      expect(routePaths, contains(AppRoutes.SERVICE_MANAGEMENT));
      expect(routePaths, contains(AppRoutes.SERVICE_FORM));
      expect(routePaths, contains(AppRoutes.DOCTOR_MANAGEMENT));
      expect(routePaths, contains(AppRoutes.DOCTOR_FORM));
      expect(routePaths, contains(AppRoutes.DOCTOR_AVAILABILITY));
    });

    test('should have all routes with correct types', () {
      for (var route in AppRoutes.routes) {
        expect(route, isA<GetPage>());
        expect(route.name, isA<String>());
        expect(route.page, isA<Function>());
      }
    });
  });
}
