import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meal_of_record/services/background_backup_worker.dart';
import 'package:meal_of_record/services/backup_config_service.dart';
import 'package:meal_of_record/config/app_router.dart';
import 'package:meal_of_record/providers/navigation_provider.dart';
import 'package:meal_of_record/providers/log_provider.dart';
import 'package:meal_of_record/providers/recipe_provider.dart';
import 'package:meal_of_record/providers/goals_provider.dart';
import 'package:meal_of_record/providers/weight_provider.dart';
import 'package:meal_of_record/services/database_service.dart';
import 'package:meal_of_record/services/emoji_service.dart';
import 'package:meal_of_record/services/open_food_facts_service.dart';
import 'package:meal_of_record/services/search_service.dart';
import 'package:meal_of_record/services/food_sorting_service.dart';
import 'package:meal_of_record/utils/debug_seeder.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      debugPrint('MyApp: Starting initialization...');

      await DatabaseService.instance.init();

      //if (kDebugMode) {
      //  await DebugSeeder.seed();
      //}

      // Set user agent for OpenFoodFacts API
      OpenFoodAPIConfiguration.userAgent = UserAgent(
        name: 'Meal of Record',
        version: '1.0',
      );

      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
      debugPrint('MyApp: Initialization complete.');

      // Fire-and-forget: attempt auto-backup if conditions are met
      tryAutoBackup();

      // Check for repeated backup failures from previous sessions
      _checkBackupWarning();
    } catch (e, stack) {
      debugPrint('MyApp: Initialization error: $e');
      debugPrint(stack.toString());
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _checkBackupWarning() async {
    try {
      final config = BackupConfigService.instance;
      final enabled = await config.isAutoBackupEnabled();
      if (!enabled) return;

      final failures = await config.getConsecutiveFailures();
      if (failures < 3) return;

      // Wait for the app to finish building before showing dialog
      await Future.delayed(const Duration(seconds: 2));

      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;

      showDialog(
        context: ctx,
        builder: (context) => AlertDialog(
          title: const Text('NAS Backup Issue'),
          content: Text(
            'Your backups haven\'t succeeded in the last $failures attempts. '
            'Check your NAS connection or settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('DISMISS'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                navigatorKey.currentState?.pushNamed(
                  AppRouter.dataManagementRoute,
                );
              },
              child: const Text('GO TO SETTINGS'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Backup warning check error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[200]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _initialize(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      return MaterialApp(
        theme: ThemeData.dark(),
        home: Scaffold(
          backgroundColor: Colors.grey[850],
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text(
                  'Cooking up your data...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Instantiate services that will be injected
    final databaseService = DatabaseService.instance;
    final offApiService = OffApiService();
    final searchService = SearchService(
      databaseService: databaseService,
      offApiService: offApiService,
      emojiForFoodName: emojiForFoodName,
      sortingService: FoodSortingService(),
    );

    final appRouter = AppRouter(
      databaseService: databaseService,
      offApiService: offApiService,
      searchService: searchService,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LogProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
        ChangeNotifierProvider(create: (_) => WeightProvider()),
      ],
      child: MaterialApp(
        title: 'Meal of Record',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[850],
          brightness: Brightness.dark,
        ),
        initialRoute: AppRouter.homeRoute,
        navigatorObservers: [routeObserver],
        onGenerateRoute: appRouter.generateRoute,
      ),
    );
  }
}
