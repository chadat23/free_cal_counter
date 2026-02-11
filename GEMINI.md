# Gemini Instructions for Meal of Record Flutter App

This file provides directives for Gemini when assisting with development of the Meal of Record Flutter application. All code suggestions must respect the existing project structure and patterns. **Do NOT suggest architectural changes or reorganize existing code** unless explicitly requested.

## Project Structure & Architecture

Follow this exact folder structure - do not suggest moving files between directories:

lib/
├── config/
│   ├── api_config.dart          # Application-wide configuration
│   └── app_router.dart          # Navigation routing configuration
├── models/
│   ├── food.dart                # Food data model
│   ├── food_serving.dart        # Food serving model  
│   └── logged_food.dart         # Logged food entries
├── providers/
│   ├── log_provider.dart        # Manages food log state
│   ├── log_queue_provider.dart  # Handles queued log operations
│   └── navigation_provider.dart # Navigation state management
├── screens/
│   ├── add_food_screen.dart     # Add food entry screen
│   └── home_screen.dart         # Main home screen
├── services/
│   ├── database_service.dart    # SQLite database operations
│   └── open_food_facts_service.dart # OpenFoodFacts API integration
├── widgets/
│   └── food_search_bar.dart     # Reusable search component
└── main.dart                    # Application entry point

> To maintain organizational clarity, creating subdirectories within existing folders (e.g., `lib/screens`, `lib/widgets`) to group related files is encouraged. The top-level directory structure (`lib/config`, `lib/models`, etc.) should remain unchanged.

## State Management (Provider)

Use Provider package exclusively with ChangeNotifier pattern matching existing implementation
Respect existing providers: NavigationProvider, LogProvider, LogQueueProvider
All stateful screens should use ChangeNotifierProvider or MultiProvider setup from main.dart

Pattern to follow for new ChangeNotifiers:

class ExampleProvider extends ChangeNotifier {
  // Private state
  List<Food> _foods = [];
  
  // Public getters
  List<Food> get foods => List.unmodifiable(_foods);
  bool get isLoading => _isLoading;
  
  // Async operations with proper notifyListeners
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _foods = await _databaseService.getFoods();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

Always call notifyListeners() after state changes
Use Consumer<ProviderType> for targeted widget rebuilding
Never use setState() - all state changes go through providers

## Database Operations

Use existing DatabaseService in lib/services/database_service.dart for ALL database operations
The database uses a pre-populated foods.db asset from etl/foods.db
Never bypass DatabaseService - all CRUD operations must go through its methods

Expected DatabaseService pattern:

final foods = await DatabaseService.instance.getFoodsBySearch(query);
final success = await DatabaseService.instance.saveLoggedFood(loggedFood);

Handle the asset copying and initialization through existing DatabaseService methods
Use transactions for multiple database operations

## Navigation

Use existing NavigationProvider for all navigation state
Routing is configured in config/app_router.dart - do not modify routing logic
For screen navigation, follow existing patterns using NavigationProvider methods
Never suggest direct Navigator calls - route through NavigationProvider

## Testing Strategy (TDD Required)

Always write tests before implementation code. The goal is to prevent breaking changes and catch regressions early.

### Unit Tests (lib/models, lib/services, lib/providers)

Test isolation: Mock DatabaseService and OpenFoodFactsService for service tests
Coverage targets: 80%+ for business logic, model validations, provider methods

Mocking pattern using mockito:

test('should return foods for valid search query', () async {
  // Arrange
  when(databaseService.getFoodsBySearch('apple'))
      .thenAnswer((_) async => [mockFood]);
  
  // Act
  final result = await logProvider.searchFoods('apple');
  
  // Assert
  expect(result, hasLength(1));
  verify(databaseService.getFoodsBySearch('apple')).called(1);
});

Test edge cases: null values, empty results, invalid inputs, error conditions
Location: test/models/, test/services/, test/providers/

### Widget Tests (lib/screens, lib/widgets)

Test UI behavior, provider integration, and user interactions
Verify screens render correctly with different provider states
Test loading states, error states, and success states

Pattern:

testWidgets('displays food search results', (tester) async {
  // Arrange
  await tester.pumpWidget(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => mockLogProvider)],
      child: MaterialApp(home: SearchScreen()),
    ),
  );
  
  // Act
  await tester.enterText(find.byType(TextField), 'apple');
  await tester.pumpAndSettle();
  
  // Assert
  expect(find.text('Apple'), findsOneWidget);
});

Location: test/screens/, test/widgets/

### Integration Tests (Future Implementation)

End-to-end user flows: search food → add to log → view daily summary
Test with actual DatabaseService using test database
Critical paths only - focus on high-risk functionality
Location: integration_test/

Testing Workflow:
1. Write comprehensive failing tests first (unit + widget)
2. Implement minimal code to make all tests pass
3. Refactor for clarity while keeping tests green
4. Run flutter test and fix any regressions before suggesting changes

## Existing Code Patterns & Standards

Respect ALL existing patterns - do not suggest "better" alternatives:

### Code Style

Formatting: Follow dart format exactly (run dart format . after changes)
Naming: 
- Classes: PascalCase (Food, DatabaseService)
- Variables/Functions: camelCase (foodList, getFoods)
- Files: snake_case.dart (database_service.dart)

Async/Await: Use async/await consistently for all asynchronous operations
Null Safety: Enforce strict null safety - use ? for nullable, avoid !

### Comments

Add comments sparingly - only explain WHY complex logic exists, not WHAT it does
Focus on business decisions, not implementation details

Example:

// Cache frequent searches to improve performance on slow networks
// Used in food search to reduce OpenFoodFacts API calls
final _searchCache = <String, List<Food>>{};

### Widget Patterns

Separation of Concerns: Keep screens focused on UI, delegate logic to providers/services
Stateless vs Stateful: Use StatelessWidget unless local state is absolutely required
Reusable Components: New widgets go in lib/widgets/ if used in multiple screens
Error Handling: Show loading indicators and handle errors via SnackBar/Dialog

### Provider Integration

Always wrap screens with appropriate providers from main.dart MultiProvider
Access services through providers, not directly in widgets

Example screen setup:

class AddFoodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LogProvider, NavigationProvider>(
      builder: (context, logProvider, navProvider, child) {
        return Scaffold(
          // UI using logProvider and navProvider
        );
      },
    );
  }
}

## Core Services Integration

### DatabaseService

Single source of truth for all database operations
Mock it in unit tests using mockito
Never create duplicate database helper classes
Handle initialization through existing DatabaseService.instance

### OpenFoodFactsService

Use for API lookups when local database search fails
Implement caching to avoid repeated API calls
Handle rate limiting and network errors gracefully
Mock API responses in tests with realistic data

## Preventing Breaking Changes

Your #1 priority: Never break existing functionality

Before suggesting changes: Analyze impact on existing screens, providers, and services
Always test first: Write tests that verify current behavior passes before implementing changes
Small increments: Suggest incremental improvements, not large refactors
Verify existing flows: After changes, ensure core user flows still work:
- Food search and display
- Adding foods to log
- Viewing food logs
- Navigation between screens

## Response Guidelines for Gemini

Understand first: Analyze existing code patterns before suggesting changes
Respect structure: All new code must fit existing architecture
TDD workflow:
1. Show failing tests that capture current desired behavior
2. Implement minimal passing solution
3. Refactor while keeping tests green

Code format: Use ```dart blocks for all Flutter/Dart code
Test inclusion: Always provide matching test code
No unsolicited advice: Do not suggest architectural improvements or package changes
Error prevention: Explain how changes won't break existing functionality
Android focus: Test suggestions should consider Android performance and UX patterns

## Quality Standards

Run flutter analyze - fix all lints using very_good_analysis
Target 80%+ test coverage for new features
Use flutter test --coverage to verify coverage
Format all code with dart format .
Test on Android emulator (API 28+) for performance

## Feature Requests and Scope Control

All work must stay aligned with explicitly requested features, tasks, or goals.

- Do not add unrelated functionality or speculative enhancements that were not
  requested.
- You may implement supporting sub‑features **when they are clearly and
  unavoidably required** for the requested feature to function as intended.
- Use your best judgment: if the need for a small supporting change is obvious
  and in line with the established architecture, proceed — but document the
  rationale briefly in your explanation or code comments.

### Clarifying Questions and Intent Confirmation

Before beginning work, Gemini should:
1. Confirm its understanding of the requested feature and intended outcome unless it's obvious.
2. Ask clarifying questions only **when scope, intent, or edge conditions are
   ambiguous.**
3. Skip redundant clarifications when the request is sufficiently explicit or
   the solution path is self‑evident within existing patterns.

> The goal is to minimize misunderstanding — not to create bureaucracy.
> Seek enough clarity to guarantee that new code directly supports current
> objectives, while avoiding unnecessary hand‑holding on well‑defined tasks.

## Common Development Commands

flutter test                    # Run all tests
flutter test --coverage         # Generate coverage report
flutter analyze                 # Check code quality
dart format .                   # Format all Dart files
flutter pub deps                # Show dependency tree

## "Handling Deviations from `gemini.md`:

If an ideal change or solution appears to be at odds with the directives outlined in this gemini.md file, Gemini must not proceed with the change. Instead, Gemini will:

1. Describe the Proposed Change: Provide a high-level description of the ideal change and its benefits.
2. Identify Conflicting Directives: Clearly state which specific gemini.md directives are in conflict.
3. Explain the Conflict: Detail how the proposed change differs from or contradicts the existing directives.
4. Propose `gemini.md` Update: Suggest how the gemini.md file itself could be updated to accommodate the proposed change, considering the current project phase or evolving needs.
5. Outline Proposed Resolution: Offer a high-level description of how the conflict could be resolved, leading to the implementation of the ideal change."

Important: This file exists to maintain consistency and prevent regressions. All suggestions must preserve existing functionality while following TDD principles. When in doubt, ask for clarification about specific implementation details.

## Updating This File (Governance Evolution)

The `gemini.md` file is a living governance document. 
While its directives are binding for all daily development tasks, 
its structure and architectural decisions may be updated as the project evolves.

### Error Handling Patterns
- Network errors: Show retry-enabled SnackBar with offline fallback
- Validation errors: Inline field errors, disable submit until resolved  
- Database errors: Log + show generic "Something went wrong" message
- Never let exceptions bubble to users unhandled

### LLM Code Review Checklist
Before accepting any generated code:
- [ ] All existing tests pass
- [ ] New functionality has corresponding tests  
- [ ] No new lint warnings introduced
- [ ] Follows existing naming/structure patterns
- [ ] Error handling matches established patterns

### Change Process:
1. Identify the limitation or rigidity in current directives.
2. Write a short proposal describing:
   - The specific directive(s) affected
   - The reason the current guidance is limiting
   - The long-term value or flexibility gained by changing it
3. Run regression tests and confirm that no core use cases are broken.
4. The update becomes effective once approved by maintainers.

### GIT
Git can be used to investage stuff but not to stage, commit, or push.
If it's an appropreate time to commit stuff, feel free to make a suggestion to the user but there's no obligation to do so.

Gemini should continue following the latest committed version of this file.

Last Updated: October 2025