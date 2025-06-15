import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:sprout/services/firebase_service.dart';
import 'package:sprout/models/study.dart';
import 'package:sprout/models/user_demographics.dart';
import 'package:sprout/models/recording_response.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  User,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  FirebaseStorage,
  Reference,
  UploadTask,
])
import 'firebase_service_test.mocks.dart';

void main() {
  group('FirebaseService Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseStorage mockStorage;
    late FirebaseService firebaseService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockFirestore = MockFirebaseFirestore();
      mockStorage = MockFirebaseStorage();
      
      // Setup basic mocks
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-user-id');
      
      firebaseService = FirebaseService.instance;
    });

    group('Authentication', () {
      test('should sign in anonymously when no current user', () async {
        when(mockAuth.currentUser).thenReturn(null);
        when(mockAuth.signInAnonymously()).thenAnswer(
          (_) async => MockUserCredential(),
        );

        await firebaseService.signInAnonymously();

        verify(mockAuth.signInAnonymously()).called(1);
      });

      test('should not sign in when user already exists', () async {
        when(mockAuth.currentUser).thenReturn(mockUser);

        await firebaseService.signInAnonymously();

        verifyNever(mockAuth.signInAnonymously());
      });

      test('should throw exception when sign in fails', () async {
        when(mockAuth.currentUser).thenReturn(null);
        when(mockAuth.signInAnonymously()).thenThrow(Exception('Sign in failed'));

        expect(
          () => firebaseService.signInAnonymously(),
          throwsException,
        );
      });
    });

    group('Studies', () {
      test('should get active studies stream', () async {
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockQuery = MockQuery<Map<String, dynamic>>();
        final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('studies')).thenReturn(mockCollection);
        when(mockCollection.where('active', isEqualTo: true)).thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true)).thenReturn(mockQuery);
        when(mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockSnapshot));
        when(mockSnapshot.docs).thenReturn([mockDoc]);
        
        // Mock document data
        when(mockDoc.id).thenReturn('study-1');
        when(mockDoc.data()).thenReturn({
          'title': 'Test Study',
          'description': 'A test study',
          'wordList': ['dog', 'cat'],
          'imageUrls': {'dog': 'https://example.com/dog.jpg'},
          'active': true,
          'createdAt': Timestamp.now(),
        });

        final stream = firebaseService.getActiveStudies();
        final studies = await stream.first;

        expect(studies, isA<List<Study>>());
        expect(studies.length, 1);
        expect(studies.first.title, 'Test Study');
      });
    });

    group('User Demographics', () {
      test('should save user demographics', () async {
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDoc);
        when(mockDoc.set(any)).thenAnswer((_) async {});

        final demographics = UserDemographics(
          age: 5,
          gender: 'Female',
          languages: ['English'],
          createdAt: DateTime.now(),
        );

        await firebaseService.saveUserDemographics(demographics);

        verify(mockDoc.set(any)).called(1);
      });

      test('should get user demographics', () async {
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDoc = MockDocumentReference<Map<String, dynamic>>();
        final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc('test-user-id')).thenReturn(mockDoc);
        when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.data()).thenReturn({
          'demographics': {
            'age': 5,
            'gender': 'Female',
            'languages': ['English'],
          },
          'createdAt': Timestamp.now(),
        });

        final demographics = await firebaseService.getUserDemographics();

        expect(demographics, isA<UserDemographics>());
        expect(demographics!.age, 5);
        expect(demographics.gender, 'Female');
      });
    });

    group('Recording Upload', () {
      test('should upload recording file', () async {
        final mockRef = MockReference();
        final mockUploadTask = MockUploadTask();
        final mockFile = MockFile();

        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(any)).thenReturn(mockRef);
        when(mockRef.putFile(any)).thenReturn(mockUploadTask);
        when(mockUploadTask.then(any)).thenAnswer((_) async => MockTaskSnapshot());

        final timestamp = DateTime.now();
        final filePath = await firebaseService.uploadRecording(
          audioFile: mockFile,
          studyId: 'study-1',
          word: 'dog',
          timestamp: timestamp,
        );

        expect(filePath, contains('recordings/study-1/test-user-id/dog_'));
        verify(mockRef.putFile(mockFile)).called(1);
      });

      test('should save recording response', () async {
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();

        when(mockFirestore.collection('responses')).thenReturn(mockCollection);
        when(mockCollection.add(any)).thenAnswer((_) async => MockDocumentReference());

        final response = RecordingResponse(
          userId: 'test-user-id',
          studyId: 'study-1',
          word: 'dog',
          timestamp: DateTime.now(),
          filePath: 'recordings/study-1/test-user-id/dog_123.wav',
          duration: 2.5,
          deviceInfo: DeviceInfo(
            platform: 'android',
            osVersion: '13',
            model: 'Pixel 7',
            manufacturer: 'Google',
          ),
        );

        await firebaseService.saveRecordingResponse(response);

        verify(mockCollection.add(any)).called(1);
      });
    });
  });
}

// Additional mock classes
class MockUserCredential extends Mock implements UserCredential {}
class MockQuery<T> extends Mock implements Query<T> {}
class MockTaskSnapshot extends Mock implements TaskSnapshot {}
class MockFile extends Mock implements File {} 