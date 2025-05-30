# Tests du ScheduleViewController

Ce document décrit les différents tests pour les fonctionnalités de planification (schedule) de l'application de gestion des gardes médicales.

## Structure des tests

Nous avons organisé les tests en plusieurs fichiers pour mieux isoler et tester les différentes fonctionnalités :

1. `schedule_controller_test.dart` - Tests de base pour le ScheduleViewController
2. `schedule_controller_simple_test.dart` - Tests simplifiés des fonctionnalités sans dépendance à GetX
3. `schedule_view_controller_test.dart` - Tests pour le ScheduleViewController avec mocks automatiques
4. `schedule_view_controller_test_improvements.dart` - Version améliorée des tests pour le ScheduleViewController
5. `schedule_drag_drop_test.dart` - Tests spécifiques aux fonctionnalités de drag-and-drop
6. `schedule_service_test.dart` - Tests unitaires du ScheduleService

## Objets de test

Nous avons créé des implémentations spécifiques pour les tests :

- `TestDoctor` - Implémente l'interface Doctor pour les tests
- `TestService` - Implémente l'interface Service pour les tests

Ces classes gèrent correctement les `RealmList` et simulent les comportements des modèles Realm.

## Fonctionnalités testées

### ScheduleViewController
- Chargement des plannings
- Filtrage des médecins par service
- Opérations de drag-and-drop
- Changement de mois et d'année
- Formatage des noms de mois et jours

### ScheduleService
- Génération des plannings mensuels
- Échange de médecins entre plannings
- Changement de médecin dans un planning
- Gestion des jours bloqués et indisponibles

## Exécution des tests

Pour exécuter tous les tests :

```bash
flutter test
```

Pour exécuter un fichier de test spécifique :

```bash
flutter test test/app/modules/schedule/controllers/schedule_view_controller_test_improvements.dart
```

Pour exécuter les tests avec des journaux détaillés :

```bash
flutter test --verbose
```

## Problèmes connus et solutions

### Problème avec GetX dans les tests

GetX peut causer des problèmes lors des tests à cause de son système d'injection de dépendances. Pour résoudre ce problème :

1. Utilisez `Get.put()` dans le `setUp()` pour injecter les mocks
2. Utilisez `Get.reset()` dans le `tearDown()` pour nettoyer entre les tests
3. Pour les tests sans GetX, utilisez les versions simplifiées avec injection manuelle de dépendances

### Objets Realm dans les tests

Pour gérer les objets Realm dans les tests :

1. Utilisez des classes `Test*` qui implémentent les interfaces Realm
2. Initialisez correctement les `RealmList` pour éviter les erreurs de null safety
3. Implémentez les méthodes appropriées comme `isAvailableOn()`, `canTakeShiftOn()`, etc.

### Extensions de test utiles

Pour faciliter les tests, nous avons créé quelques extensions :

```dart
extension ScheduleTest on Schedule {
  Schedule withDoctorId(ObjectId doctorId) {
    return this..doctorId = doctorId;
  }
}
```

Ces extensions permettent de manipuler facilement les objets dans les tests.

## Amélioration de la couverture des tests

Pour améliorer la couverture, nous avons ajouté des tests pour :

1. Les cas limites et les cas d'erreur
2. Les interactions entre différents composants
3. Les fonctionnalités de drag-and-drop qui sont cruciales pour l'interface utilisateur
4. La vérification des permissions et contraintes métier
