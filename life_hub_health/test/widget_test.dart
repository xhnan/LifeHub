import 'package:flutter_test/flutter_test.dart';
import 'package:life_hub_health/app/app.dart';

void main() {
  testWidgets('App should build', (WidgetTester tester) async {
    await tester.pumpWidget(App());
  });
}
