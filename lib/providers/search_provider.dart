import 'dart:io';

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

  /// Converts raw exceptions into user-friendly error messages.
  static String _friendlyError(Object error, {bool isOffSearch = false}) {
    final message = error.toString().toLowerCase();

    // Network connectivity issues
    if (error is SocketException ||
        message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('connection refused') ||
        message.contains('network is unreachable')) {
      return 'No internet connection. Check your network and try again.';
    }

    // Timeouts
    if (error is HttpException ||
        message.contains('timeout') ||
        message.contains('timed out')) {
      return 'The request timed out. Please try again.';
    }

    // Open Food Facts server issues (HTML error pages instead of JSON, 5xx, etc.)
    if (message.contains('json expected') ||
        message.contains('server error') ||
        message.contains('temporarily unavailable') ||
        message.contains('502') ||
        message.contains('503') ||
        message.contains('500')) {
      return 'Open Food Facts is temporarily unavailable. Please try again later.';
    }

    // FormatException from bad JSON
    if (error is FormatException || message.contains('formatexception')) {
      if (isOffSearch) {
        return 'Open Food Facts returned an unexpected response. Please try again later.';
      }
      return 'Something went wrong reading the data. Please try again.';
    }

    // Generic fallback — still friendly, no raw exception dump
    if (isOffSearch) {
      return 'Could not reach Open Food Facts. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }

  SearchResults? _suggestions;

  List<model.Food> _searchResults = [];
  List<model.Food> get searchResults => _searchResults;

  Map<int, String?> _displayNotes = {};
  Map<int, String?> get displayNotes => _displayNotes;

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

  /// Pre-loads solo food suggestions. Called once when search opens.
  Future<void> loadSuggestions() async {
    try {
      _suggestions = await searchService.getSuggestions();
    } catch (_) {
      _suggestions = null;
    }
    // Apply immediately if query is still empty and in text mode
    if (_currentQuery.isEmpty &&
        _searchMode != SearchMode.recipe &&
        _suggestions != null &&
        _suggestions!.foods.isNotEmpty) {
      _applySearchResults(_suggestions!);
      notifyListeners();
    }
  }

  void _applySearchResults(SearchResults results) {
    _searchResults = results.foods;
    _displayNotes = results.displayNotes;
  }

  void setSearchMode(SearchMode mode) {
    _searchMode = mode;
    _searchResults = [];
    _displayNotes = {};
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
    _clearErrorMessage();

    // Show cached suggestions when query is empty in text/scan mode
    if (query.isEmpty && _searchMode != SearchMode.recipe) {
      if (_suggestions != null && _suggestions!.foods.isNotEmpty) {
        _applySearchResults(_suggestions!);
      } else {
        _searchResults = [];
        _displayNotes = {};
      }
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final SearchResults results;
      if (_searchMode == SearchMode.recipe) {
        if (query.isEmpty) {
          results = await searchService.getAllRecipesAsFoods(
            categoryId: _selectedCategoryId,
          );
        } else {
          results = await searchService.searchRecipesOnly(
            query,
            categoryId: _selectedCategoryId,
          );
        }
      } else {
        results = await searchService.searchLocal(
          query,
          categoryId: _selectedCategoryId,
        );
      }
      _applySearchResults(results);
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _searchResults = [];
      _displayNotes = {};
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
      final results = await searchService.searchOff(_currentQuery);
      _applySearchResults(results);
    } catch (e) {
      _errorMessage = _friendlyError(e, isOffSearch: true);
      _searchResults = [];
      _displayNotes = {};
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
      _errorMessage = _friendlyError(e);
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
      _errorMessage = _friendlyError(e, isOffSearch: true);
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
