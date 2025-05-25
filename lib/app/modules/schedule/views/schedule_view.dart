// Schedule view
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:realm/realm.dart';
import '../controllers/schedule_view_controller.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/doctor_model.dart';
import '../../../data/models/schedule_model.dart';
//import '../../../global_widgets/app_widgets.dart';

class ScheduleView extends GetView<ScheduleViewController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          'Planning - ${controller.getMonthName(controller.selectedMonth.value)} ${controller.selectedYear.value}'
        )),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: controller.loadSchedules,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Controls
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Month selector
                        Expanded(
                          child: Row(
                            children: [
                              const Text('Période:'),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: controller.selectedYear.value,
                                items: List<int>.generate(5, (i) => DateTime.now().year + i - 1)
                                    .map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (int? value) {
                                  if (value != null) {
                                    controller.changeMonth(value, controller.selectedMonth.value);
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              DropdownButton<int>(
                                value: controller.selectedMonth.value,
                                items: List<int>.generate(12, (i) => i + 1)
                                    .map((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(controller.getMonthName(value)),
                                  );
                                }).toList(),
                                onChanged: (int? value) {
                                  if (value != null) {
                                    controller.changeMonth(controller.selectedYear.value, value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        // Service selector
                        Expanded(
                          child: Row(
                            children: [
                              const Text('Services:'),
                              const SizedBox(width: 8),
                              PopupMenuButton<List<Service>>(
                                tooltip: 'Sélectionner les services',
                                onSelected: controller.changeDisplayedServices,
                                itemBuilder: (context) {
                                  return [
                                    // Add menu items for different combinations of services
                                    // Limited to 3 services max
                                    ...List.generate(
                                      controller.services.length,
                                      (i) => PopupMenuItem<List<Service>>(
                                        value: [controller.services[i]],
                                        child: Text(controller.services[i].nom),
                                      ),
                                    ),
                                  ];
                                },
                                child: Chip(
                                  label: const Text('Choisir les services'),
                                  avatar: const Icon(Icons.local_hospital),
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Main content - services and doctors
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Services schedules
                      Expanded(
                        flex: 3,
                        child: _buildSchedulesTables(),
                      ),
                      
                      // Doctors list
                      Expanded(
                        flex: 1,
                        child: _buildDoctorsList(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
  
  Widget _buildSchedulesTables() {
    // Get days in month
    final daysInMonth = DateTime(
      controller.selectedYear.value, 
      controller.selectedMonth.value + 1, 
      0
    ).day;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.displayedServices.map((service) {
          return Card(
            margin: const EdgeInsets.only(right: 8),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Service header
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.indigo.shade100,
                    child: Text(
                      service.nom,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Days list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      return _buildDaySchedule(service, day);
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildDaySchedule(Service service, int day) {
    final schedule = controller.getScheduleForDay(service, day);
    final date = DateTime(controller.selectedYear.value, controller.selectedMonth.value, day);
    
    // Determine background color based on weekday
    Color backgroundColor = Colors.transparent;
    if (date.weekday == DateTime.friday) {
      backgroundColor = Colors.orange.withOpacity(0.1);
    } else if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      backgroundColor = Colors.red.withOpacity(0.1);
    }
    
    return DragTarget<Doctor>(
      onWillAcceptWithDetails: (doctor) => controller.acceptDoctorDrop(service, day),
      onAcceptWithDetails: (doctor) => controller.completeDoctorDrop(service, day),
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // Day number and weekday
              Container(
                width: 35,
                alignment: Alignment.center,
                child: Text(
                  '${day.toString().padLeft(2, '0')}\n${controller.getDayOfWeek(day)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: date.weekday == DateTime.saturday || 
                               date.weekday == DateTime.sunday 
                        ? FontWeight.bold 
                        : FontWeight.normal,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Doctor assignment
              Expanded(
                child: schedule != null
                    ? Draggable<Schedule>(
                        data: schedule,
                        onDragStarted: () => controller.startDragSchedule(schedule),
                        onDragEnd: (details) => controller.endDrag(),
                        feedback: Material(
                          elevation: 4,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.white,
                            child: Text(
                              _getDoctorDisplayName(schedule),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        child: Text(
                          _getDoctorDisplayName(schedule),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const Text('Non assigné', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDoctorsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.indigo.shade100,
              child: const Text(
                'Médecins disponibles',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Expanded(
              child: ListView.builder(
                itemCount: controller.availableDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = controller.availableDoctors[index];
                  return _buildDoctorItem(doctor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDoctorItem(Doctor doctor) {
    return Draggable<Doctor>(
      data: doctor,
      onDragStarted: () => controller.startDragDoctor(doctor),
      onDragEnd: (details) => controller.endDrag(),
      feedback: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Text(
            '${doctor.nom} ${doctor.prenom}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: ListTile(
        title: Text('${doctor.nom} ${doctor.prenom}'),
        subtitle: Text(_getPrivilegesText(doctor)),
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
      ),
    );
  }
  
  String _getPrivilegesText(Doctor doctor) {
    List<String> privileges = [];
    if (doctor.isAnesthesiste) privileges.add('A');
    if (doctor.isPediatrique) privileges.add('P');
    if (doctor.isSamu) privileges.add('S');
    if (doctor.isIntensiviste) privileges.add('I');
    
    return privileges.isEmpty ? 'Aucun' : privileges.join(', ');
  }
  
  // Récupère le nom du médecin à afficher à partir de l'ID
  String _getDoctorDisplayName(Schedule schedule) {
    final doctor = controller.getDoctorById(schedule.doctorId);
    if (doctor == null) {
      return 'Médecin inconnu';
    }
    return '${doctor.nom} ${doctor.prenom}';
  }
}
