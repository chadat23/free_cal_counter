import 'package:flutter_test/flutter_test.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';

void main() {
  group('NavigationProvider', () {
    test('initial tab index should be 0', () {
      final provider = NavigationProvider();
      expect(provider.selectedIndex, 0);
    });

    test('changeTab should update the selected index and notify listeners', () {
      final provider = NavigationProvider();
      bool notified = false;
      provider.addListener(() {
        notified = true;
      });

      provider.changeTab(1);

      expect(provider.selectedIndex, 1);
      expect(notified, isTrue);
    });
  });
}
