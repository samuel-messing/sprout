import 'package:cloud_firestore/cloud_firestore.dart';

class RecordingResponse {
  final String? id;
  final String userId;
  final String studyId;
  final String word;
  final DateTime timestamp;
  final String filePath;
  final double duration;
  final DeviceInfo deviceInfo;

  RecordingResponse({
    this.id,
    required this.userId,
    required this.studyId,
    required this.word,
    required this.timestamp,
    required this.filePath,
    required this.duration,
    required this.deviceInfo,
  });

  factory RecordingResponse.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecordingResponse(
      id: doc.id,
      userId: data['userId'] ?? '',
      studyId: data['studyId'] ?? '',
      word: data['word'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      filePath: data['filePath'] ?? '',
      duration: (data['duration'] ?? 0.0).toDouble(),
      deviceInfo: DeviceInfo.fromMap(data['deviceInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'studyId': studyId,
      'word': word,
      'timestamp': Timestamp.fromDate(timestamp),
      'filePath': filePath,
      'duration': duration,
      'deviceInfo': deviceInfo.toMap(),
    };
  }
}

class DeviceInfo {
  final String platform;
  final String osVersion;
  final String model;
  final String manufacturer;

  DeviceInfo({
    required this.platform,
    required this.osVersion,
    required this.model,
    required this.manufacturer,
  });

  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      platform: map['platform'] ?? '',
      osVersion: map['osVersion'] ?? '',
      model: map['model'] ?? '',
      manufacturer: map['manufacturer'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'osVersion': osVersion,
      'model': model,
      'manufacturer': manufacturer,
    };
  }
} 