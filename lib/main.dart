import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/data/providers/dependency_injection.dart';
import 'app/routes/app_routes.dart';
import 'app/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencyInjection.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gestion des Gardes Médicales',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.LOGIN,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
    );
  }
}

// No need for the MyHomePage class anymore as we are using GetX route management
