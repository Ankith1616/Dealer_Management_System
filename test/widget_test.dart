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

    // Let GoRouter initialize and start navigating
    await tester.pump();

    // Advance the virtual clock by 1 second to resolve the mock repository network delays (max 500ms)
    await tester.pump(const Duration(seconds: 1));

    // Wait for all route transitions and animations to finish settling
    await tester.pumpAndSettle();

    // Verify that the app starts up without crash
    expect(tester.takeException(), isNull);
  });
}
