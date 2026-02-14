import 'package:flutter/foundation.dart';
import 'package:meal_of_record/models/food.dart' as model;
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/open_food_facts_service.dart';
import 'package:meal_of_record/services/search_service.dart';
import 'package:meal_of_record/models/search_mode.dart';

class SearchProvider extends ChangeNotifier {
  final DatabaseService databaseService;
  final OffApiService offApiService;
  final SearchService searchService;

  SearchProvider({
    required this.databaseService,
    required this.offApiService,
    required this.searchService,
  });

  List<model.Food> _searchResults = [];
  List<model.Food> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _currentQuery = '';

  String get currentQuery => _currentQuery;

  SearchMode _searchMode = SearchMode.text;
  SearchMode get searchMode => _searchMode;

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  // Barcode search state
  bool _isBarcodeSearch = false;
  bool get isBarcodeSearch => _isBarcodeSearch;

  String? _lastScannedBarcode;
  String? get lastScannedBarcode => _lastScannedBarcode;

  void clearBarcodeSearchState() {
    _isBarcodeSearch = false;
    _lastScannedBarcode = null;
  }

  void clearSearch() {
    textSearch('');
  }

  void setSearchMode(SearchMode mode) {
    _searchMode = mode;
    _searchResults = []; // Clear results when switching modes
    _clearErrorMessage();
    notifyListeners();
  }

  void _clearErrorMessage() {
    _errorMessage = null;
  }

  void setSelectedCategoryId(int? id) {
    _selectedCategoryId = id;
    textSearch(_currentQuery); // Re-trigger search with new category
  }

  // Always performs a local search
  Future<void> textSearch(String query) async {
    _currentQuery = query;
    _isLoading = true;
    _clearErrorMessage();
    notifyListeners();

    try {
      if (_searchMode == SearchMode.recipe) {
        if (query.isEmpty) {
          _searchResults = await searchService.getAllRecipesAsFoods(
            categoryId: _selectedCategoryId,
          );
        } else {
          _searchResults = await searchService.searchRecipesOnly(
            query,
            categoryId: _selectedCategoryId,
          );
        }
      } else {
        _searchResults = await searchService.searchLocal(
          query,
          categoryId: _selectedCategoryId,
        );
      }
    } catch (e) {
      _errorMessage = 'Failed to search for food: ${e.toString()}';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Performs a one-time external search for the current query
  Future<void> performOffSearch() async {
    if (_currentQuery.isEmpty) return;

    _isLoading = true;
    _clearErrorMessage();
    notifyListeners();

    try {
      _searchResults = await searchService.searchOff(_currentQuery);
    } catch (e) {
      _errorMessage = 'Failed to search for food: ${e.toString()}';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> barcodeSearch(String barcode) async {
    _isLoading = true;
    _isBarcodeSearch = true;
    _lastScannedBarcode = barcode;
    _clearErrorMessage();
    notifyListeners();

    try {
      // First check local database using the new barcodes table
      List<model.Food> foods = await databaseService.getFoodsByBarcode(barcode);

      _searchResults = foods;

      // Switch to text mode to display results
      _searchMode = SearchMode.text;
    } catch (e) {
      _errorMessage = 'Failed to search by barcode: ${e.toString()}';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> barcodeOffSearch(String barcode) async {
    _isLoading = true;
    _isBarcodeSearch = true;
    _lastScannedBarcode = barcode;
    _clearErrorMessage();
    notifyListeners();

    try {
      final offFood = await offApiService.fetchFoodByBarcode(barcode);
      if (offFood != null) {
        _searchResults = [offFood];
      } else {
        _searchResults = [];
      }

      // Switch to text mode to display results
      _searchMode = SearchMode.text;
    } catch (e) {
      _errorMessage = 'Failed to search Open Food Facts: ${e.toString()}';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
