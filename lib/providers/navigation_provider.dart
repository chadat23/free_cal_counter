import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  bool _shouldFocusSearch = false;
  bool _showConsumed = true;
  int _weightRangeDays = 7;
  String _weightRangeLabel = '1 wk';

  int get selectedIndex => _selectedIndex;
  bool get shouldFocusSearch => _shouldFocusSearch;
  bool get showConsumed => _showConsumed;
  int get weightRangeDays => _weightRangeDays;
  String get weightRangeLabel => _weightRangeLabel;

  void setShowConsumed(bool value) {
    _showConsumed = value;
    notifyListeners();
  }

  void setWeightRange(String label, int days) {
    _weightRangeLabel = label;
    _weightRangeDays = days;
    notifyListeners();
  }

  void changeTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void goToSearch() {
    _previousIndex = _selectedIndex;
    _shouldFocusSearch = true;
    notifyListeners();
  }

  void goToDataManagement() {
    _previousIndex = _selectedIndex;
    notifyListeners();
  }

  void resetSearchFocus() {
    _shouldFocusSearch = false;
    // No need to notify listeners for this change
  }

  void goBack() {
    _selectedIndex = _previousIndex;
    notifyListeners();
  }
}
