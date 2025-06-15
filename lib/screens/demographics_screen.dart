import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/study.dart';
import '../models/user_demographics.dart';
import '../services/firebase_service.dart';
import '../widgets/loading_widget.dart';
import 'word_prompt_screen.dart';

class DemographicsScreen extends StatefulWidget {
  final Study study;

  const DemographicsScreen({
    super.key,
    required this.study,
  });

  @override
  State<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends State<DemographicsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _languagesController = TextEditingController();
  
  String _selectedGender = '';
  bool _isLoading = false;
  
  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _checkExistingDemographics();
  }

  Future<void> _checkExistingDemographics() async {
    try {
      final existingDemographics = await FirebaseService.instance.getUserDemographics();
      if (existingDemographics != null) {
        // Skip demographics if already collected
        _navigateToWordPrompt();
      }
    } catch (e) {
      // Continue to show demographics form if error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About You'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Saving information...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Card(
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
                                    Icons.person_outline,
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
                                        widget.study.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'First, tell us a bit about yourself',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Age Field
                    const Text(
                      'Age',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Enter age (e.g., 5)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.cake_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter age';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 1 || age > 18) {
                          return 'Please enter a valid age (1-18)';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Gender Field
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(_genderOptions.map((gender) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RadioListTile<String>(
                        title: Text(gender),
                        value: gender,
                        groupValue: _selectedGender,
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value ?? '';
                          });
                        },
                        activeColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _selectedGender == gender 
                                ? const Color(0xFF4CAF50) 
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ))),
                    
                    const SizedBox(height: 24),
                    
                    // Languages Field
                    const Text(
                      'Languages spoken at home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _languagesController,
                      decoration: InputDecoration(
                        hintText: 'e.g., English, Spanish',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.language_outlined),
                        helperText: 'Separate multiple languages with commas',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter at least one language';
                        }
                        return null;
                      },
                      maxLines: 2,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Privacy Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.privacy_tip_outlined,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your information is used for research purposes only and will be kept confidential.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveDemographics,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Continue to Study',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveDemographics() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a gender')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final languages = _languagesController.text
          .split(',')
          .map((lang) => lang.trim())
          .where((lang) => lang.isNotEmpty)
          .toList();

      final demographics = UserDemographics(
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        languages: languages,
        createdAt: DateTime.now(),
      );

      await FirebaseService.instance.saveUserDemographics(demographics);
      
      _navigateToWordPrompt();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving information: $e')),
      );
    }
  }

  void _navigateToWordPrompt() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WordPromptScreen(study: widget.study),
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _languagesController.dispose();
    super.dispose();
  }
} 