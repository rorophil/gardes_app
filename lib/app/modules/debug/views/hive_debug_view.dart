/// Vue de debug pour visualiser les tables Hive
/// Interface d'administration pour explorer les données locales
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/hive_debug_controller.dart';

class HiveDebugView extends GetView<HiveDebugController> {
  const HiveDebugView({super.key});

  @override
  Widget build(BuildContext context) {
    // Vérification du mode debug
    if (!controller.isDebugMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debug non disponible')),
        body: const Center(
          child: Text(
            'Interface de debug disponible uniquement en mode développement',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Hive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadAllData,
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportData();
                  break;
                case 'test_data':
                  controller.createTestData();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Exporter les données'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'test_data',
                    child: Row(
                      children: [
                        Icon(Icons.science),
                        SizedBox(width: 8),
                        Text('Créer données de test'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            // Sidebar avec navigation
            Container(
              width: 250,
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: _buildSidebar(),
            ),

            // Contenu principal
            Expanded(child: _buildMainContent()),
          ],
        );
      }),
    );
  }

  Widget _buildSidebar() {
    return Column(
      children: [
        // Statistiques
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistiques',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Obx(
                () => _buildStatItem(
                  'Médecins',
                  controller.totalDoctors.value,
                  Icons.person,
                ),
              ),
              Obx(
                () => _buildStatItem(
                  'Services',
                  controller.totalServices.value,
                  Icons.local_hospital,
                ),
              ),
              Obx(
                () => _buildStatItem(
                  'Plannings',
                  controller.totalSchedules.value,
                  Icons.calendar_month,
                ),
              ),
            ],
          ),
        ),

        const Divider(),

        // Navigation des tables
        Expanded(
          child: ListView(
            children: [
              Obx(
                () => _buildTableTile(
                  'Médecins',
                  'doctors',
                  Icons.person,
                  controller.totalDoctors.value,
                ),
              ),
              Obx(
                () => _buildTableTile(
                  'Services',
                  'services',
                  Icons.local_hospital,
                  controller.totalServices.value,
                ),
              ),
              Obx(
                () => _buildTableTile(
                  'Plannings',
                  'schedules',
                  Icons.calendar_month,
                  controller.totalSchedules.value,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text('$label: $count'),
        ],
      ),
    );
  }

  Widget _buildTableTile(
    String title,
    String tableKey,
    IconData icon,
    int count,
  ) {
    final isSelected = controller.selectedTable.value == tableKey;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text('$count éléments'),
      selected: isSelected,
      onTap: () => controller.selectTable(tableKey),
      trailing:
          count > 0
              ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'clear') {
                    controller.clearTable(tableKey);
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'clear',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Vider la table'),
                          ],
                        ),
                      ),
                    ],
              )
              : null,
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      switch (controller.selectedTable.value) {
        case 'doctors':
          return _buildDoctorsTable();
        case 'services':
          return _buildServicesTable();
        case 'schedules':
          return _buildSchedulesTable();
        default:
          return const Center(
            child: Text('Sélectionnez une table à visualiser'),
          );
      }
    });
  }

  Widget _buildDoctorsTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table: Médecins (${controller.doctors.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Prénom')),
                DataColumn(label: Text('Login')),
                DataColumn(label: Text('Anesthésiste')),
                DataColumn(label: Text('Pédiatrique')),
                DataColumn(label: Text('SAMU')),
                DataColumn(label: Text('Intensiviste')),
                DataColumn(label: Text('Max Gardes')),
                DataColumn(label: Text('Jours Min')),
                DataColumn(label: Text('Indisponibilités')),
              ],
              rows:
                  controller.doctors.map((doctor) {
                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              doctor.id,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(doctor.nom)),
                        DataCell(Text(doctor.prenom)),
                        DataCell(Text(doctor.login)),
                        DataCell(
                          Icon(
                            doctor.isAnesthesiste ? Icons.check : Icons.close,
                            color:
                                doctor.isAnesthesiste
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        DataCell(
                          Icon(
                            doctor.isPediatrique ? Icons.check : Icons.close,
                            color:
                                doctor.isPediatrique
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        DataCell(
                          Icon(
                            doctor.isSamu ? Icons.check : Icons.close,
                            color: doctor.isSamu ? Colors.green : Colors.red,
                          ),
                        ),
                        DataCell(
                          Icon(
                            doctor.isIntensiviste ? Icons.check : Icons.close,
                            color:
                                doctor.isIntensiviste
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        DataCell(Text(doctor.maxGardesParMois.toString())),
                        DataCell(Text(doctor.joursMinEntreGardes.toString())),
                        DataCell(
                          Text(doctor.joursIndisponibles.length.toString()),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table: Services (${controller.services.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Anesthésiste')),
                DataColumn(label: Text('Pédiatrique')),
                DataColumn(label: Text('SAMU')),
                DataColumn(label: Text('Intensiviste')),
                DataColumn(label: Text('Jours Bloqués')),
              ],
              rows:
                  controller.services.map((service) {
                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              service.id,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(Text(service.nom)),
                        DataCell(
                          Icon(
                            service.requiresAnesthesiste
                                ? Icons.check
                                : Icons.close,
                            color:
                                service.requiresAnesthesiste
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        DataCell(
                          Icon(
                            service.requiresPediatrique
                                ? Icons.check
                                : Icons.close,
                            color:
                                service.requiresPediatrique
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        DataCell(
                          Icon(
                            service.requiresSamu ? Icons.check : Icons.close,
                            color:
                                service.requiresSamu
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        DataCell(
                          Icon(
                            service.requiresIntensiviste
                                ? Icons.check
                                : Icons.close,
                            color:
                                service.requiresIntensiviste
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        DataCell(Text(service.joursBloquees.length.toString())),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulesTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Table: Plannings (${controller.schedules.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Médecin')),
                DataColumn(label: Text('Service')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Priorité')),
              ],
              rows:
                  controller.schedules.map((schedule) {
                    final doctor = controller.doctors.firstWhereOrNull(
                      (d) => d.id == schedule.doctorId,
                    );
                    final service = controller.services.firstWhereOrNull(
                      (s) => s.id == schedule.serviceId,
                    );

                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 100,
                            child: Text(
                              schedule.id,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(doctor?.displayName ?? 'Médecin inconnu'),
                        ),
                        DataCell(Text(service?.nom ?? 'Service inconnu')),
                        DataCell(Text(schedule.dateString)),
                        DataCell(Text(schedule.priority.toString())),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    final data = controller.exportData();
    Clipboard.setData(ClipboardData(text: data));
    Get.snackbar(
      'Succès',
      'Données exportées dans le presse-papier',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
    );
  }
}
