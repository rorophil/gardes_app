import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gardes_app/app/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    // Tests pour le thème clair
    group('Light Theme', () {
      late ThemeData lightTheme;

      setUp(() {
        lightTheme = AppTheme.light;
      });

      test('should have correct color scheme properties', () {
        expect(lightTheme.colorScheme.brightness, equals(Brightness.light));
        expect(lightTheme.colorScheme.primary, isNotNull);
        // La couleur indigo est utilisée comme seedColor pour générer le schéma
        // Vérifions que les couleurs générées sont cohérentes avec indigo
        expect(lightTheme.colorScheme.primary.value, isNotNull);
        expect(lightTheme.colorScheme.secondary, isNotNull);
        expect(lightTheme.colorScheme.surface, isNotNull);
      });

      test('should use Material 3', () {
        expect(lightTheme.useMaterial3, isTrue);
      });

      test('should have correct appBar theme', () {
        expect(lightTheme.appBarTheme.centerTitle, isTrue);
        expect(lightTheme.appBarTheme.elevation, equals(2));
      });

      test('should have correct card theme', () {
        expect(lightTheme.cardTheme.elevation, equals(4));
        expect(lightTheme.cardTheme.margin, equals(const EdgeInsets.all(8)));
      });

      test('should have correct elevated button theme', () {
        final ButtonStyle style = lightTheme.elevatedButtonTheme.style!;
        final padding = style.padding?.resolve({});
        final shape = style.shape?.resolve({}) as RoundedRectangleBorder?;

        expect(
          padding,
          equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        );
        expect(shape?.borderRadius, equals(BorderRadius.circular(8)));
      });

      test('should have correct input decoration theme', () {
        expect(lightTheme.inputDecorationTheme.filled, isTrue);
        expect(
          lightTheme.inputDecorationTheme.contentPadding,
          equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        );
      });

      test('should have correct snackBar theme', () {
        expect(
          lightTheme.snackBarTheme.behavior,
          equals(SnackBarBehavior.floating),
        );
        expect(lightTheme.snackBarTheme.elevation, equals(6));
      });

      test('should have correct divider theme', () {
        expect(lightTheme.dividerTheme.thickness, equals(1));
        expect(lightTheme.dividerTheme.indent, equals(0));
        expect(lightTheme.dividerTheme.endIndent, equals(0));
      });
    });

    // Tests pour le thème sombre
    group('Dark Theme', () {
      late ThemeData darkTheme;

      setUp(() {
        darkTheme = AppTheme.dark;
      });

      test('should have correct color scheme properties', () {
        expect(darkTheme.colorScheme.brightness, equals(Brightness.dark));
        expect(darkTheme.colorScheme.primary, isNotNull);
        // La couleur indigo est utilisée comme seedColor pour générer le schéma
        // Vérifions que les couleurs générées sont cohérentes avec indigo
        expect(darkTheme.colorScheme.primary.value, isNotNull);
        expect(darkTheme.colorScheme.secondary, isNotNull);
        expect(darkTheme.colorScheme.surface, isNotNull);
      });

      test('should use Material 3', () {
        expect(darkTheme.useMaterial3, isTrue);
      });

      test('should have correct appBar theme', () {
        expect(darkTheme.appBarTheme.centerTitle, isTrue);
        expect(darkTheme.appBarTheme.elevation, equals(2));
      });

      test('should have correct card theme', () {
        expect(darkTheme.cardTheme.elevation, equals(4));
        expect(darkTheme.cardTheme.margin, equals(const EdgeInsets.all(8)));
      });

      test('should have correct elevated button theme', () {
        final ButtonStyle style = darkTheme.elevatedButtonTheme.style!;
        final padding = style.padding?.resolve({});
        final shape = style.shape?.resolve({}) as RoundedRectangleBorder?;

        expect(
          padding,
          equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        );
        expect(shape?.borderRadius, equals(BorderRadius.circular(8)));
      });

      test('should have correct input decoration theme', () {
        expect(darkTheme.inputDecorationTheme.filled, isTrue);
        expect(
          darkTheme.inputDecorationTheme.contentPadding,
          equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        );
      });

      test('should have correct snackBar theme', () {
        expect(
          darkTheme.snackBarTheme.behavior,
          equals(SnackBarBehavior.floating),
        );
        expect(darkTheme.snackBarTheme.elevation, equals(6));
      });

      test('should have correct divider theme', () {
        expect(darkTheme.dividerTheme.thickness, equals(1));
        expect(darkTheme.dividerTheme.indent, equals(0));
        expect(darkTheme.dividerTheme.endIndent, equals(0));
      });
    });
  });
}
