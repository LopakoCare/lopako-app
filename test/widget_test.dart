// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lopako_app_lis/app.dart';
import 'package:lopako_app_lis/firebase_options.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Initialize Firebase for testing
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Build our app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verify that the initial loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
