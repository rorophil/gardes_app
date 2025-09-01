// Service management view
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_management_controller.dart';
import '../../../data/models/service_hive_model.dart';

/// Vue de gestion des services médicaux
///
/// Cette vue permet aux administrateurs de gérer la liste des services.
/// Les fonctionnalités incluent :
/// - Affichage de la liste complète des services
/// - Ajout de nouveaux services
/// - Modification des informations existantes
/// - Suppression de services (avec confirmation)
/// - Gestion des privilèges requis (IADE, IBODE, DES, etc.)
/// - Configuration des jours bloqués par service
///
/// Chaque service est affiché avec ses informations principales,
/// ses privilèges requis et des actions rapides pour l'édition
/// ou la gestion des jours bloqués.
class ServiceManagementView extends GetView<ServiceManagementController> {
  /// Constructeur de la vue de gestion des services
  const ServiceManagementView({super.key});

  /// Construit l'interface utilisateur de gestion des services
  ///
  /// Affiche une liste des services avec boutons d'action
  /// et gestion des états de chargement/vide
  ///
  /// Returns : Widget Scaffold contenant l'interface de gestion
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: controller.loadServices,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_hospital_outlined,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun service trouvé',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.createService,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un service'),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Add button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: controller.createService,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un service'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Services list
                Expanded(child: _buildServicesList()),
              ],
            ),
          );
        }
      }),
    );
  }

  Widget _buildServicesList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          // Desktop layout - data table
          return _buildDataTable();
        } else {
          // Mobile layout - list view
          return _buildListView();
        }
      },
    );
  }

  Widget _buildDataTable() {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nom du Service')),
            DataColumn(label: Text('Privilèges Requis')),
            DataColumn(label: Text('Actions')),
          ],
          rows:
              controller.services.map((service) {
                return DataRow(
                  cells: [
                    DataCell(Text(service.nom)),
                    DataCell(Text(_getPrivilegesText(service))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => controller.editService(service),
                            tooltip: 'Modifier',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.calendar_month,
                              color: Colors.green,
                            ),
                            onPressed:
                                () => controller.manageBlockedDays(service),
                            tooltip: 'Gérer les jours bloqués',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteService(service),
                            tooltip: 'Supprimer',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: controller.services.length,
      itemBuilder: (context, index) {
        final service = controller.services[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: Text(service.nom),
            subtitle: Text('Privilèges: ${_getPrivilegesText(service)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => controller.editService(service),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.green),
                  onPressed: () => controller.manageBlockedDays(service),
                  tooltip: 'Gérer les jours bloqués',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteService(service),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPrivilegesText(ServiceHive service) {
    List<String> privileges = [];
    if (service.requiresAnesthesiste) privileges.add('Anesthésiste');
    if (service.requiresPediatrique) privileges.add('Pédiatrique');
    if (service.requiresSamu) privileges.add('SAMU');
    if (service.requiresIntensiviste) privileges.add('Intensiviste');

    return privileges.isEmpty ? 'Aucun' : privileges.join(', ');
  }
}
