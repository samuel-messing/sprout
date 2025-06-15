import 'package:cloud_firestore/cloud_firestore.dart';

class Study {
  final String id;
  final String title;
  final String description;
  final List<String> wordList;
  final Map<String, String> imageUrls;
  final bool active;
  final DateTime createdAt;

  Study({
    required this.id,
    required this.title,
    required this.description,
    required this.wordList,
    required this.imageUrls,
    required this.active,
    required this.createdAt,
  });

  factory Study.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Study(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      wordList: List<String>.from(data['wordList'] ?? []),
      imageUrls: Map<String, String>.from(data['imageUrls'] ?? {}),
      active: data['active'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'wordList': wordList,
      'imageUrls': imageUrls,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 