import 'package:flutter/material.dart';
import '../models/study.dart';
import '../services/firebase_service.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import 'demographics_screen.dart';

class StudyListScreen extends StatelessWidget {
  const StudyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sprout Studies'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Study>>(
        stream: FirebaseService.instance.getActiveStudies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Loading studies...');
          }

          if (snapshot.hasError) {
            return ErrorDisplayWidget(
              message: 'Failed to load studies',
              error: snapshot.error.toString(),
              onRetry: () {
                // Trigger rebuild by navigating back and forth
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const StudyListScreen()),
                );
              },
            );
          }

          final studies = snapshot.data ?? [];

          if (studies.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No studies available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for new studies!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Sprout! 🌱',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Help us learn about language development by participating in these fun recording activities.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: studies.length,
                    itemBuilder: (context, index) {
                      final study = studies[index];
                      return StudyCard(
                        study: study,
                        onTap: () => _navigateToStudy(context, study),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToStudy(BuildContext context, Study study) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DemographicsScreen(study: study),
      ),
    );
  }
}

class StudyCard extends StatelessWidget {
  final Study study;
  final VoidCallback onTap;

  const StudyCard({
    super.key,
    required this.study,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Color(0xFF4CAF50),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          study.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${study.wordList.length} words to record',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                study.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tap to start',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 