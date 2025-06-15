import 'package:cloud_firestore/cloud_firestore.dart';

class UserDemographics {
  final int age;
  final String gender;
  final List<String> languages;
  final DateTime createdAt;

  UserDemographics({
    required this.age,
    required this.gender,
    required this.languages,
    required this.createdAt,
  });

  factory UserDemographics.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final demographics = data['demographics'] as Map<String, dynamic>? ?? {};
    
    return UserDemographics(
      age: demographics['age'] ?? 0,
      gender: demographics['gender'] ?? '',
      languages: List<String>.from(demographics['languages'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'demographics': {
        'age': age,
        'gender': gender,
        'languages': languages,
      },
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 