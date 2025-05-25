// Doctor dashboard view
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_controller.dart';
import '../../../global_widgets/app_widgets.dart';
import '../../../data/models/schedule_model.dart';
//import '../../../data/models/service_model.dart';

class DoctorDashboardView extends GetView<DoctorController> {
  const DoctorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          'Bonjour ${controller.currentDoctor.value?.prenom ?? ""}'
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadSchedules,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      'Médecin: ${controller.currentDoctor.value?.nom ?? ""} ${controller.currentDoctor.value?.prenom ?? ""}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    const SizedBox(height: 8),
                    Obx(() {
                      final doctor = controller.currentDoctor.value;
                      if (doctor == null) return const SizedBox();
                      
                      List<String> privileges = [];
                      if (doctor.isAnesthesiste) privileges.add('Anesthésiste');
                      if (doctor.isPediatrique) privileges.add('Pédiatrique');
                      if (doctor.isSamu) privileges.add('SAMU');
                      if (doctor.isIntensiviste) privileges.add('Intensiviste');
                      
                      return Text(
                        'Privilèges: ${privileges.join(", ")}',
                        style: const TextStyle(fontSize: 16),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                const Text(
                  'Mes Gardes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                AppButton(
                  text: 'Gérer mes indisponibilités',
                  onPressed: controller.goToAvailability,
                  icon: Icons.calendar_today,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.schedules.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune garde planifiée',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                } else {
                  return _buildSchedulesList();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSchedulesList() {
    final schedulesByMonth = controller.getSchedulesByMonth();
    
    return ListView.builder(
      itemCount: schedulesByMonth.length,
      itemBuilder: (context, index) {
        final monthKey = schedulesByMonth.keys.elementAt(index);
        final monthSchedules = schedulesByMonth[monthKey]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(12),
                child: Text(
                  controller.formatMonth(monthKey),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthSchedules.length,
                itemBuilder: (context, idx) {
                  final schedule = monthSchedules[idx];
                  return _buildScheduleItem(schedule);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildScheduleItem(Schedule schedule) {
    final date = schedule.date;
    // Récupérer le service à partir de l'ID
    final service = controller.getServiceById(schedule.serviceId);
    
    Color badgeColor;
    if (date.weekday == DateTime.friday) {
      badgeColor = Colors.orange;
    } else if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      badgeColor = Colors.red;
    } else {
      badgeColor = Colors.green;
    }
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: badgeColor,
        child: Text(
          date.day.toString(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(service?.nom ?? 'Service inconnu'),
      subtitle: Text('${_getDayOfWeek(date.weekday)} ${_formatDate(date)}'),
    );
  }
  
  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday: return 'Lundi';
      case DateTime.tuesday: return 'Mardi';
      case DateTime.wednesday: return 'Mercredi';
      case DateTime.thursday: return 'Jeudi';
      case DateTime.friday: return 'Vendredi';
      case DateTime.saturday: return 'Samedi';
      case DateTime.sunday: return 'Dimanche';
      default: return '';
    }
  }
  
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
