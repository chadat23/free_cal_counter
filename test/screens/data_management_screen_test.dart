import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_cal_counter1/screens/data_management_screen.dart';
import 'package:free_cal_counter1/services/backup_config_service.dart';
import 'package:free_cal_counter1/services/google_drive_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([GoogleDriveService, BackupConfigService, GoogleSignInAccount])
import 'data_management_screen_test.mocks.dart';

void main() {
  late MockGoogleDriveService mockDriveService;
  late MockBackupConfigService mockConfigService;

  setUp(() {
    mockDriveService = MockGoogleDriveService();
    mockConfigService = MockBackupConfigService();

    // Default stubs
    when(mockDriveService.refreshCurrentUser()).thenAnswer((_) async => null);
    when(
      mockConfigService.isAutoBackupEnabled(),
    ).thenAnswer((_) async => false);
    when(mockConfigService.getRetentionCount()).thenAnswer((_) async => 7);
    when(mockConfigService.getLastBackupTime()).thenAnswer((_) async => null);
  });

  Widget createSubject() {
    return MaterialApp(
      home: DataManagementScreen(
        googleDriveService: mockDriveService,
        backupConfigService: mockConfigService,
      ),
    );
  }

  group('DataManagementScreen Backup Toggle', () {
    testWidgets('shows dialog when sign-in fails', (tester) async {
      // Arrange
      when(mockDriveService.signIn()).thenAnswer((_) async => null);
      when(mockDriveService.currentUser).thenReturn(null);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle(); // Initial load

      // Act
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Assert
      // Currently fails because it shows a SnackBar, not a Dialog
      expect(find.text('Sign In Required'), findsOneWidget);
      expect(find.textContaining('You need a Google account'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets('shows error dialog when sign-in throws exception', (
      tester,
    ) async {
      // Arrange
      when(mockDriveService.signIn()).thenThrow(Exception('Network Error'));
      when(mockDriveService.currentUser).thenReturn(null);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Act
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sign In Failed'), findsOneWidget);
      expect(find.textContaining('Network Error'), findsOneWidget);
      expect(find.text('RETRY'), findsOneWidget);
    });

    testWidgets('shows account dialog when account text is tapped', (
      tester,
    ) async {
      // Arrange
      final mockUser = MockGoogleSignInAccount();
      when(mockUser.email).thenReturn('test@example.com');
      // Mock ID as well if accessed
      // when(mockUser.id).thenReturn('123');

      when(mockDriveService.currentUser).thenReturn(mockUser);
      // Ensure refresh returns the user so it loads into state
      when(
        mockDriveService.refreshCurrentUser(),
      ).thenAnswer((_) async => mockUser);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Act
      final accountFinder = find.text('Account: test@example.com');
      expect(accountFinder, findsOneWidget);
      await tester.tap(accountFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Google Account'), findsOneWidget);
      expect(find.text('Signed in as test@example.com'), findsOneWidget);
      expect(find.text('SIGN OUT'), findsOneWidget);
    });
  });

  group('Backup to Cloud card visibility', () {
    testWidgets('shows Backup to Cloud card when signed in', (tester) async {
      // Arrange
      final mockUser = MockGoogleSignInAccount();
      when(mockUser.email).thenReturn('test@example.com');
      when(mockDriveService.currentUser).thenReturn(mockUser);
      when(
        mockDriveService.refreshCurrentUser(),
      ).thenAnswer((_) async => mockUser);

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Backup to Cloud'), findsOneWidget);
      expect(find.text('Restore from Cloud'), findsOneWidget);
    });

    testWidgets('hides Backup to Cloud card when not signed in', (
      tester,
    ) async {
      // Arrange — default stubs have refreshCurrentUser returning null

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Backup to Cloud'), findsNothing);
      expect(find.text('Restore from Cloud'), findsNothing);
    });
  });
}
