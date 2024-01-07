import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ioc_container_example/main.dart';

class FakeSettingsService extends SettingsService {
  @override
  final bool isLightMode;

  FakeSettingsService({required this.isLightMode});
}

void main() {
  group('Theme Switcher App', () {
    setUp(() {
      //Replace the existing settings service
      builder.addSingleton<SettingsService>(
          (c) => FakeSettingsService(isLightMode: false));

      serviceLocator = builder.toContainer();
    });

    testWidgets('Toggle theme changes brightness', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      final finder = find.byType(MaterialApp);
      final app = tester.widget<MaterialApp>(finder);

      //Expect dark because that's what the fake settings service returns
      expect(app.theme!.brightness, Brightness.dark);

      final toggleButton = find.byType(FloatingActionButton);
      expect(toggleButton, findsOneWidget);

      //Tap the toggle button
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      final finder2 = find.byType(MaterialApp);
      final app2 = tester.widget<MaterialApp>(finder2);

      //Expect light because we changed the theme
      expect(app2.theme!.brightness, Brightness.light);
    });
  });
}
