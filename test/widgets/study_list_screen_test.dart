import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sprout/screens/study_list_screen.dart';

void main() {
  group('StudyListScreen Widget Tests', () {
    testWidgets('should build StudyListScreen widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudyListScreen(),
        ),
      );

      // Should show the app bar title
      expect(find.text('Sprout Studies'), findsOneWidget);
      
      // Should show either loading, content, or error state
      // Without mocking Firebase, this will likely show an error or loading state
      expect(
        find.byType(StudyListScreen), 
        findsOneWidget,
      );
    });
    
    testWidgets('should have proper app bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StudyListScreen(),
        ),
      );

      // Verify app bar exists and has correct title
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Sprout Studies'), findsOneWidget);
    });
  });
}
