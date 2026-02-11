import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/widgets/screen_background.dart';

void main() {
  group('ScreenBackground', () {
    testWidgets('renders its child and has correct background color', (
      WidgetTester tester,
    ) async {
      const Key testKey = Key('testChild');

      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenBackground(child: Text('Test Child', key: testKey)),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);

      final Scaffold scaffold = tester.widget(find.byType(Scaffold));
      expect(scaffold.backgroundColor, null);
    });

    testWidgets('renders AppBar when provided', (WidgetTester tester) async {
      const Key appBarKey = Key('testAppBar');

      await tester.pumpWidget(
        MaterialApp(
          home: ScreenBackground(
            appBar: AppBar(key: appBarKey, title: const Text('Test App Bar')),
            child: const Text('Test Child'),
          ),
        ),
      );

      expect(find.byKey(appBarKey), findsOneWidget);
      expect(find.text('Test App Bar'), findsOneWidget);
    });

    testWidgets('content respects SafeArea padding', (
      WidgetTester tester,
    ) async {
      const double topPadding = 50.0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(top: topPadding)),
          child: const MaterialApp(
            home: ScreenBackground(child: Text('Test Child')),
          ),
        ),
      );

      // Find the SafeArea widget within ScreenBackground
      final Finder safeAreaFinder = find.descendant(
        of: find.byType(ScreenBackground),
        matching: find.byType(SafeArea),
      );
      expect(safeAreaFinder, findsOneWidget);

      // Find the child of ScreenBackground (Text('Test Child'))
      final Finder childFinder = find.text('Test Child');
      expect(childFinder, findsOneWidget);

      // Get the render object of the child
      final RenderBox renderBox = tester.renderObject(childFinder);

      // Verify that the child's top is below the simulated padding
      // The SafeArea should push the content down by topPadding
      expect(
        renderBox.localToGlobal(Offset.zero).dy,
        greaterThanOrEqualTo(topPadding),
      );
    });
  });
}
