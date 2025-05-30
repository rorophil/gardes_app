import 'package:flutter_test/flutter_test.dart';
import 'package:gardes_app/main.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App should initialize and run', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app has initialized correctly
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
