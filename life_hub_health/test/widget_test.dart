import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_hub_health/app/app.dart';

void main() {
  testWidgets('App should build with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: const App(),
      ),
    );

    // Verify the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
