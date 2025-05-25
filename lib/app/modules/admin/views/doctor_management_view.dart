// Doctor management view
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/doctor_management_controller.dart';
import '../../../data/models/doctor_model.dart';

class DoctorManagementView extends GetView<DoctorManagementController> {
  const DoctorManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Médecins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: controller.loadDoctors,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.doctors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_off,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucun médecin trouvé',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.createDoctor,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter un médecin'),
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
                    onPressed: controller.createDoctor,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un médecin'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                // Doctors list
                Expanded(
                  child: _buildDoctorsList(),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
  
  Widget _buildDoctorsList() {
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
            DataColumn(label: Text('Nom')),
            DataColumn(label: Text('Prénom')),
            DataColumn(label: Text('Login')),
            DataColumn(label: Text('Privilèges')),
            DataColumn(label: Text('Max Gardes/Mois')),
            DataColumn(label: Text('Actions')),
          ],
          rows: controller.doctors.map((doctor) {
            return DataRow(
              cells: [
                DataCell(Text(doctor.nom)),
                DataCell(Text(doctor.prenom)),
                DataCell(Text(doctor.login)),
                DataCell(Text(_getPrivilegesText(doctor))),
                DataCell(Text(doctor.maxGardesParMois.toString())),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => controller.editDoctor(doctor),
                      tooltip: 'Modifier',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => controller.deleteDoctor(doctor),
                      tooltip: 'Supprimer',
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildListView() {
    return ListView.builder(
      itemCount: controller.doctors.length,
      itemBuilder: (context, index) {
        final doctor = controller.doctors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ListTile(
            title: Text('${doctor.nom} ${doctor.prenom}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Login: ${doctor.login}'),
                Text('Privilèges: ${_getPrivilegesText(doctor)}'),
                Text('Max gardes/mois: ${doctor.maxGardesParMois}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => controller.editDoctor(doctor),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteDoctor(doctor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  String _getPrivilegesText(Doctor doctor) {
    List<String> privileges = [];
    if (doctor.isAnesthesiste) privileges.add('Anesthésiste');
    if (doctor.isPediatrique) privileges.add('Pédiatrique');
    if (doctor.isSamu) privileges.add('SAMU');
    if (doctor.isIntensiviste) privileges.add('Intensiviste');
    
    return privileges.isEmpty ? 'Aucun' : privileges.join(', ');
  }
}
