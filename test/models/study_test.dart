import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:sprout/models/study.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockTimestamp extends Mock implements Timestamp {}

void main() {
  group('Study Model Tests', () {
    test('should create Study from Firestore document', () {
      final mockDoc = MockDocumentSnapshot();
      final mockTimestamp = MockTimestamp();
      final testDate = DateTime(2024, 1, 1);

      when(mockDoc.id).thenReturn('study-123');
      when(mockDoc.data()).thenReturn({
        'title': 'Animal Words',
        'description': 'Study about animal vocabulary',
        'wordList': ['dog', 'cat', 'bird'],
        'imageUrls': {
          'dog': 'https://example.com/dog.jpg',
          'cat': 'https://example.com/cat.jpg',
        },
        'active': true,
        'createdAt': mockTimestamp,
      });
      when(mockTimestamp.toDate()).thenReturn(testDate);

      final study = Study.fromFirestore(mockDoc);

      expect(study.id, 'study-123');
      expect(study.title, 'Animal Words');
      expect(study.description, 'Study about animal vocabulary');
      expect(study.wordList, ['dog', 'cat', 'bird']);
      expect(study.imageUrls['dog'], 'https://example.com/dog.jpg');
      expect(study.imageUrls['cat'], 'https://example.com/cat.jpg');
      expect(study.active, true);
      expect(study.createdAt, testDate);
    });

    test('should handle missing fields with defaults', () {
      final mockDoc = MockDocumentSnapshot();

      when(mockDoc.id).thenReturn('study-456');
      when(mockDoc.data()).thenReturn(<String, dynamic>{});

      final study = Study.fromFirestore(mockDoc);

      expect(study.id, 'study-456');
      expect(study.title, '');
      expect(study.description, '');
      expect(study.wordList, isEmpty);
      expect(study.imageUrls, isEmpty);
      expect(study.active, false);
      expect(study.createdAt, isA<DateTime>());
    });

    test('should convert Study to Firestore format', () {
      final testDate = DateTime(2024, 1, 1);
      final study = Study(
        id: 'study-789',
        title: 'Color Words',
        description: 'Study about colors',
        wordList: ['red', 'blue', 'green'],
        imageUrls: {
          'red': 'https://example.com/red.jpg',
          'blue': 'https://example.com/blue.jpg',
        },
        active: true,
        createdAt: testDate,
      );

      final firestoreData = study.toFirestore();

      expect(firestoreData['title'], 'Color Words');
      expect(firestoreData['description'], 'Study about colors');
      expect(firestoreData['wordList'], ['red', 'blue', 'green']);
      expect(firestoreData['imageUrls']['red'], 'https://example.com/red.jpg');
      expect(firestoreData['imageUrls']['blue'], 'https://example.com/blue.jpg');
      expect(firestoreData['active'], true);
      expect(firestoreData['createdAt'], isA<Timestamp>());
    });

    test('should handle null values in Firestore data', () {
      final mockDoc = MockDocumentSnapshot();

      when(mockDoc.id).thenReturn('study-null');
      when(mockDoc.data()).thenReturn({
        'title': null,
        'description': null,
        'wordList': null,
        'imageUrls': null,
        'active': null,
        'createdAt': null,
      });

      final study = Study.fromFirestore(mockDoc);

      expect(study.id, 'study-null');
      expect(study.title, '');
      expect(study.description, '');
      expect(study.wordList, isEmpty);
      expect(study.imageUrls, isEmpty);
      expect(study.active, false);
      expect(study.createdAt, isA<DateTime>());
    });
  });
} 