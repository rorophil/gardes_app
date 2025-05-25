// Schedule generation view
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/schedule_generation_controller.dart';
import '../../../global_widgets/app_widgets.dart';
//import '../../../data/models/service_model.dart';

class ScheduleGenerationView extends GetView<ScheduleGenerationController> {
  const ScheduleGenerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Génération des Plannings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: controller.loadServices,
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
                // Month selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Période de planning',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text('Année:'),
                            const SizedBox(width: 16),
                            Obx(() => DropdownButton<int>(
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
                            )),
                            const SizedBox(width: 32),
                            const Text('Mois:'),
                            const SizedBox(width: 16),
                            Obx(() => DropdownButton<int>(
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
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Services selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Services à planifier',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sélectionnez les services pour lesquels vous souhaitez générer un planning:',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        
                        if (controller.services.isEmpty)
                          const Center(
                            child: Text('Aucun service disponible'),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.services.map((service) {
                              return Obx(() => FilterChip(
                                label: Text(service.nom),
                                selected: controller.selectedServices.contains(service),
                                onSelected: (selected) => controller.toggleServiceSelection(service),
                              ));
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Generate button
                Center(
                  child: Obx(() {
                    if (controller.isGenerating.value) {
                      return Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            controller.generationStatus.value,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    } else {
                      return AppButton(
                        text: 'Générer les plannings',
                        onPressed: controller.generateSchedules,
                        icon: Icons.calendar_month,
                      );
                    }
                  }),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
