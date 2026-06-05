import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:colorcraft_paints/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: ColorCraftApp(),
      ),
    );

    // Verify that the app starts up without crash
    expect(tester.takeException(), isNull);
  });
}
