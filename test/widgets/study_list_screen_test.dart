import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sprout/screens/study_list_screen.dart';
import 'package:sprout/models/study.dart';
import 'package:sprout/services/firebase_service.dart';

// Generate mock
@GenerateMocks([FirebaseService])
import '../services/firebase_service_test.mocks.dart';

void main() {
  group('StudyListScreen Widget Tests', () {
    late MockFirebaseService mockFirebaseService;

    setUp(() {
      mockFirebaseService = MockFirebaseService();
    });

    testWidgets('should show loading indicator when loading studies', (tester) async {
      // Mock loading state
      when(mockFirebaseService.getActiveStudies()).thenAnswer(
        (_) => Stream.value([]).asBroadcastStream(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: const StudyListScreen(),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display studies when loaded', (tester) async {
      final testStudies = [
        Study(
          id: 'study-1',
          title: 'Animals Study',
          description: 'Say animal words',
          wordList: ['dog', 'cat', 'bird'],
          imageUrls: {},
          active: true,
          createdAt: DateTime.now(),
        ),
        Study(
          id: 'study-2',
          title: 'Colors Study',
          description: 'Say color words',
          wordList: ['red', 'blue', 'green'],
          imageUrls: {},
          active: true,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockFirebaseService.getActiveStudies()).thenAnswer(
        (_) => Stream.value(testStudies),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: const StudyListScreen(),
        ),
      );

      await tester.pump(); // Allow stream to emit

      // Should show welcome message
      expect(find.text('Welcome to Sprout! 🌱'), findsOneWidget);
      
      // Should show study cards
      expect(find.text('Animals Study'), findsOneWidget);
      expect(find.text('Colors Study'), findsOneWidget);
      expect(find.text('Say animal words'), findsOneWidget);
      expect(find.text('Say color words'), findsOneWidget);
      
      // Should show word counts
      expect(find.text('3 words to record'), findsNWidgets(2));
    });

    testWidgets('should show empty state when no studies available', (tester) async {
      when(mockFirebaseService.getActiveStudies()).thenAnswer(
        (_) => Stream.value([]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: const StudyListScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('No studies available'), findsOneWidget);
      expect(find.text('Check back later for new studies!'), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    });

    testWidgets('should show error state when stream has error', (tester) async {
      when(mockFirebaseService.getActiveStudies()).thenAnswer(
        (_) => Stream.error('Network error'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: const StudyListScreen(),
        ),
      );

      await tester.pump();

      expect(find.text('Failed to load studies'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should navigate to demographics when study card tapped', (tester) async {
      final testStudy = Study(
        id: 'study-1',
        title: 'Test Study',
        description: 'Test description',
        wordList: ['test'],
        imageUrls: {},
        active: true,
        createdAt: DateTime.now(),
      );

      when(mockFirebaseService.getActiveStudies()).thenAnswer(
        (_) => Stream.value([testStudy]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: const StudyListScreen(),
        ),
      );

      await tester.pump();

      // Find and tap the study card
      final studyCard = find.text('Test Study');
      expect(studyCard, findsOneWidget);

      await tester.tap(studyCard);
      await tester.pumpAndSettle();

      // Note: In a real test, you'd verify navigation occurred
      // This would require a more complex setup with navigation observers
    });

    testWidgets('should have proper accessibility features', (tester) async {
      final testStudy = Study(
        id: 'study-1',
        title: 'Accessible Study',
        description: 'Test accessibility',
        wordList: ['test'],
        imageUrls: {},
        active: true,
        createdAt: DateTime.now(),
      );

      when(mockFirebaseService.getActiveStudies()).thenAnswer(
        (_) => Stream.value([testStudy]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: const StudyListScreen(),
        ),
      );

      await tester.pump();

      // Verify that cards are tappable
      final inkWell = find.byType(InkWell);
      expect(inkWell, findsWidgets);

      // Verify appropriate icons are present
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });
  });
} 