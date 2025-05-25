// Doctor availability view
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/availability_controller.dart';
//import '../../../global_widgets/app_widgets.dart';

class AvailabilityView extends GetView<AvailabilityController> {
  const AvailabilityView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Jours Indisponibles'),
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
                  children: const [
                    Text(
                      'Gestion des indisponibilités',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sélectionnez les jours où vous n\'êtes pas disponible pour les gardes. Cliquez sur une date pour la marquer comme indisponible.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Month selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'Sélectionner le mois:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Obx(() => DropdownButton<int>(
                      value: controller.selectedYear.value,
                      items: List<int>.generate(5, (i) => DateTime.now().year + i - 2)
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
                    const SizedBox(width: 16),
                    Obx(() => DropdownButton<int>(
                      value: controller.selectedMonth.value,
                      items: List<int>.generate(12, (i) => i + 1)
                          .map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(_getMonthName(value)),
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
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Calendar
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() => _buildCalendar(
                    controller.selectedYear.value,
                    controller.selectedMonth.value,
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCalendar(int year, int month) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);
    final dayOffset = firstDayOfMonth.weekday % 7;
    
    return Column(
      children: [
        // Days of week header
        Row(
          children: const [
            Expanded(child: Text('Lun', textAlign: TextAlign.center)),
            Expanded(child: Text('Mar', textAlign: TextAlign.center)),
            Expanded(child: Text('Mer', textAlign: TextAlign.center)),
            Expanded(child: Text('Jeu', textAlign: TextAlign.center)),
            Expanded(child: Text('Ven', textAlign: TextAlign.center)),
            Expanded(child: Text('Sam', textAlign: TextAlign.center, style: TextStyle(color: Colors.red))),
            Expanded(child: Text('Dim', textAlign: TextAlign.center, style: TextStyle(color: Colors.red))),
          ],
        ),
        
        const Divider(),
        
        // Calendar grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth + dayOffset,
            itemBuilder: (context, index) {
              if (index < dayOffset) {
                return Container(); // Empty cell for days before first day of month
              }
              
              final day = index - dayOffset + 1;
              final date = DateTime(year, month, day);
              final isUnavailable = controller.isDateUnavailable(date);
              
              return InkWell(
                onTap: () => controller.toggleDateAvailability(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isUnavailable ? Colors.red.withOpacity(0.2) : null,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontWeight: isUnavailable ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isUnavailable)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.cancel,
                            size: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        const Divider(),
        
        // Legend
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                border: Border.all(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 8),
            const Text('= Jour indisponible'),
          ],
        ),
      ],
    );
  }
  
  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Janvier';
      case 2: return 'Février';
      case 3: return 'Mars';
      case 4: return 'Avril';
      case 5: return 'Mai';
      case 6: return 'Juin';
      case 7: return 'Juillet';
      case 8: return 'Août';
      case 9: return 'Septembre';
      case 10: return 'Octobre';
      case 11: return 'Novembre';
      case 12: return 'Décembre';
      default: return '';
    }
  }
}
