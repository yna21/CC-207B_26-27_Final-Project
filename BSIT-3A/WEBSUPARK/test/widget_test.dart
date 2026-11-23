import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:websupark/main.dart';

void main() {
  testWidgets('App starts on the login screen', (tester) async {
    await tester.pumpWidget(const WebsuParkApp());

    expect(find.text('WEBSUPARK'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('Empty login shows validation errors', (tester) async {
    await tester.pumpWidget(const WebsuParkApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('A sample driver can sign in and reaches the driver shell',
      (tester) async {
    await tester.pumpWidget(const WebsuParkApp());

    await tester.enterText(
        find.byType(TextFormField).at(0), 'yana@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Sample123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Parking Availability'), findsOneWidget);
    expect(find.text('Other Areas'), findsOneWidget);
    expect(find.text('Assignment'), findsOneWidget);
  });
}