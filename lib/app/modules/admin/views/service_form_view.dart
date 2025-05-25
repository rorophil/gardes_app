// Service form view
// Vue pour l'ajout et la modification d'un service,
// ainsi que la gestion des jours bloqués
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_form_controller.dart';
import '../../../global_widgets/app_widgets.dart';

class ServiceFormView extends GetView<ServiceFormController> {
  const ServiceFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          if (controller.isBlockedDaysMode.value) {
            return AppBar(
              title: Text('Jours Bloqués - ${controller.currentService.value?.nom ?? ""}'),
            );
          } else {
            return AppBar(
              title: Text(
                controller.isEditing.value 
                    ? 'Modifier un Service' 
                    : 'Ajouter un Service'
              ),
            );
          }
        }),
      ),
      body: Obx(() {
        if (controller.isBlockedDaysMode.value) {
          return _buildBlockedDaysContent();
        } else {
          return _buildServiceFormContent();
        }
      }),
    );
  }
  
  Widget _buildServiceFormContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nom du service (champ obligatoire)
                      AppTextField(
                        label: 'Nom du Service',
                        controller: controller.nomController,
                        validator: controller.validateRequiredField,
                      ),
                      
                      const SizedBox(height: 24),
                      const Text(
                        'Privilèges Requis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Sélection des privilèges requis pour ce service
                      Obx(() => Column(
                        children: [
                          AppCheckbox(
                            label: 'Anesthésiste',
                            value: controller.requiresAnesthesiste.value,
                            onChanged: (value) => 
                              controller.requiresAnesthesiste.value = value ?? false,
                          ),
                          AppCheckbox(
                            label: 'Pédiatrique',
                            value: controller.requiresPediatrique.value,
                            onChanged: (value) => 
                              controller.requiresPediatrique.value = value ?? false,
                          ),
                          AppCheckbox(
                            label: 'SAMU',
                            value: controller.requiresSamu.value,
                            onChanged: (value) => 
                              controller.requiresSamu.value = value ?? false,
                          ),
                          AppCheckbox(
                            label: 'Intensiviste',
                            value: controller.requiresIntensiviste.value,
                            onChanged: (value) => 
                              controller.requiresIntensiviste.value = value ?? false,
                          ),
                        ],
                      )),
                      
                      const SizedBox(height: 32),
                      
                      // Save button
                      AppButton(
                        text: 'Enregistrer',
                        icon: Icons.save,
                        onPressed: controller.saveService,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildBlockedDaysContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélecteur de mois et année
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
          
          // Calendrier pour sélectionner les jours bloqués
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
    );
  }
  
  Widget _buildCalendar(int year, int month) {
    // Calcul des jours dans le mois et du premier jour du mois
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);
    final dayOffset = firstDayOfMonth.weekday % 7;
    
    return Column(
      children: [
        // En-tête des jours de la semaine
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
        
        // Grille du calendrier avec les jours cliquables
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: daysInMonth + dayOffset,
            itemBuilder: (context, index) {
              if (index < dayOffset) {
                return Container(); // Cellule vide pour les jours avant le premier jour du mois
              }
              
              final day = index - dayOffset + 1;
              final date = DateTime(year, month, day);
              final isBlocked = controller.isDateBlocked(date);
              
              // Case du calendrier cliquable pour bloquer/débloquer un jour
              return InkWell(
                onTap: () => controller.toggleDateBlock(date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isBlocked ? Colors.red.withOpacity(0.2) : null,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          day.toString(),
                          style: TextStyle(
                            fontWeight: isBlocked ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isBlocked)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.block,
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
            const Text('= Jour bloqué (pas de garde)'),
          ],
        ),
      ],
    );
  }
  
  // Fonction d'aide pour obtenir le nom du mois en français
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
