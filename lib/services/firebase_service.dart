import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/study.dart';
import '../models/user_demographics.dart';
import '../models/recording_response.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static FirebaseService get instance => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Authentication
  Future<void> signInAnonymously() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
    } catch (e) {
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  // Studies
  Stream<List<Study>> getActiveStudies() {
    return _firestore
        .collection('studies')
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Study.fromFirestore(doc)).toList());
  }

  Future<Study?> getStudy(String studyId) async {
    try {
      final doc = await _firestore.collection('studies').doc(studyId).get();
      if (doc.exists) {
        return Study.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get study: $e');
    }
  }

  // User Demographics
  Future<void> saveUserDemographics(UserDemographics demographics) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(userId)
          .set(demographics.toFirestore());
    } catch (e) {
      throw Exception('Failed to save demographics: $e');
    }
  }

  Future<UserDemographics?> getUserDemographics() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserDemographics.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get demographics: $e');
    }
  }

  // Recording and Upload
  Future<String> uploadRecording({
    required File audioFile,
    required String studyId,
    required String word,
    required DateTime timestamp,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Create file path: recordings/{studyId}/{userId}/{word}_{timestamp}.wav
      final timestampStr = timestamp.toUtc().toIso8601String()
          .replaceAll(':', '')
          .replaceAll('-', '')
          .replaceAll('.', '');
      final fileName = '${word}_$timestampStr.wav';
      final filePath = 'recordings/$studyId/$userId/$fileName';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(filePath);
      await ref.putFile(audioFile);

      return filePath;
    } catch (e) {
      throw Exception('Failed to upload recording: $e');
    }
  }

  Future<void> saveRecordingResponse(RecordingResponse response) async {
    try {
      await _firestore
          .collection('responses')
          .add(response.toFirestore());
    } catch (e) {
      throw Exception('Failed to save recording response: $e');
    }
  }

  // Combined upload and save
  Future<void> uploadAndSaveRecording({
    required File audioFile,
    required String studyId,
    required String word,
    required DateTime timestamp,
    required double duration,
    required DeviceInfo deviceInfo,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Upload file
      final filePath = await uploadRecording(
        audioFile: audioFile,
        studyId: studyId,
        word: word,
        timestamp: timestamp,
      );

      // Save metadata
      final response = RecordingResponse(
        userId: userId,
        studyId: studyId,
        word: word,
        timestamp: timestamp,
        filePath: filePath,
        duration: duration,
        deviceInfo: deviceInfo,
      );

      await saveRecordingResponse(response);
    } catch (e) {
      throw Exception('Failed to upload and save recording: $e');
    }
  }
} 