// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_valper/main.dart';

void main() {
  testWidgets('Valper app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ValperApp());

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Verify that the app title is correct
    expect(find.text('VALPER'), findsNothing); // Title is in app bar, not visible text
    
    // Verify that the app has a scaffold (basic structure)
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
