// Admin dashboard view
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
//import '../../../global_widgets/app_widgets.dart';

class AdminDashboardView extends GetView<AdminController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Administrateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 800) {
              // Desktop layout - grid
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: _buildDashboardItems(),
              );
            } else {
              // Mobile layout - column
              return ListView(
                children: _buildDashboardItems().map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: item,
                  );
                }).toList(),
              );
            }
          },
        ),
      ),
    );
  }

  List<Widget> _buildDashboardItems() {
    return [
      _buildDashboardCard(
        'Gestion des Médecins',
        Icons.person,
        Colors.blue,
        'Créer, modifier ou supprimer des médecins',
        controller.goToDoctorManagement,
      ),
      _buildDashboardCard(
        'Gestion des Services',
        Icons.local_hospital,
        Colors.green,
        'Gérer les services et leurs privilèges requis',
        controller.goToServiceManagement,
      ),
      _buildDashboardCard(
        'Génération des Plannings',
        Icons.calendar_month,
        Colors.orange,
        'Créer automatiquement les plannings de garde',
        controller.goToScheduleGeneration,
      ),
      _buildDashboardCard(
        'Voir les Plannings',
        Icons.view_list,
        Colors.purple,
        'Consulter et modifier les plannings existants',
        controller.goToScheduleView,
      ),
    ];
  }

  Widget _buildDashboardCard(String title, IconData icon, Color color, String description, VoidCallback onPressed) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 60,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
