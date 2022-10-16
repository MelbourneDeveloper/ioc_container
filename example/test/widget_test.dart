import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

///This does exactly the same thing as AppChangeNotifier
///but it shows you how you can use Mock/Fake instead of the real service
class FakeAppChangeNotifier extends ChangeNotifier
    implements AppChangeNotifier {
  int counter = 0;

  void increment() {
    counter++;
    notifyListeners();
  }
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final builder = compose(allowOverrides: true)
      ..addSingleton<AppChangeNotifier>((container) => FakeAppChangeNotifier());

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      container: builder.toContainer(),
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
