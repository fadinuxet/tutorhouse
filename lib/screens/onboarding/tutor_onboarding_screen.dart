import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/constants.dart';

class TutorOnboardingScreen extends StatefulWidget {
  const TutorOnboardingScreen({super.key});

  @override
  State<TutorOnboardingScreen> createState() => _TutorOnboardingScreenState();
}

class _TutorOnboardingScreenState extends State<TutorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _subjectsController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _experienceController = TextEditingController();
  
  File? _introVideo;
  List<String> _selectedSubjects = [];
  bool _isLoading = false;
  int _currentStep = 0;

  final List<String> _availableSubjects = [
    'GCSE Math',
    'A-Level Math',
    'GCSE Physics',
    'A-Level Physics',
    'GCSE Chemistry',
    'A-Level Chemistry',
    'GCSE Biology',
    'A-Level Biology',
    'GCSE English',
    'A-Level English',
    'GCSE History',
    'A-Level History',
    'GCSE Geography',
    'A-Level Geography',
    'Computer Science',
    'Economics',
    'Psychology',
    'Statistics',
  ];

  @override
  void dispose() {
    _bioController.dispose();
    _subjectsController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 60),
      );
      
      if (pickedFile != null) {
        setState(() {
          _introVideo = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep == 0 && _introVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record your intro video first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_currentStep == 1 && _selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one subject'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_currentStep == 2 && !_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Upload video to Supabase Storage
      // TODO: Create tutor profile in database
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Onboarding completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to main app
        Navigator.of(context).pushReplacementNamed('/feed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of 4'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / 4,
              backgroundColor: AppConstants.surfaceColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
            ),
            
            const SizedBox(height: 32),
            
            // Step content
            Expanded(
              child: _buildStepContent(),
            ),
            
            const SizedBox(height: 24),
            
            // Navigation buttons
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 3 ? _completeOnboarding : _nextStep,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentStep == 3 ? 'Complete' : 'Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVideoStep();
      case 1:
        return _buildSubjectsStep();
      case 2:
        return _buildProfileStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildVideoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Record Your Intro Video',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a 60-second video introducing yourself and your teaching style. This will be the first thing students see!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        
        Center(
          child: GestureDetector(
            onTap: _pickVideo,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppConstants.primaryColor,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _introVideo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const Icon(
                        Icons.play_circle_filled,
                        size: 60,
                        color: AppConstants.primaryColor,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam,
                          size: 60,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to Record',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Max 60 seconds',
                          style: TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tips for a great intro video:',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Introduce yourself and your background\n'
                '• Mention your teaching experience\n'
                '• Explain your teaching approach\n'
                '• Keep it engaging and friendly\n'
                '• Make sure you have good lighting',
                style: TextStyle(
                  color: AppConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Your Subjects',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the subjects you can teach. You can add more later.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSubjects.map((subject) {
            final isSelected = _selectedSubjects.contains(subject);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSubjects.remove(subject);
                  } else {
                    _selectedSubjects.add(subject);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppConstants.primaryColor : AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppConstants.primaryColor : AppConstants.textSecondary,
                  ),
                ),
                child: Text(
                  subject,
                  style: TextStyle(
                    color: isSelected ? AppConstants.textPrimary : AppConstants.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProfileStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Your Profile',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell students about yourself and your experience.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell students about your teaching experience and approach...',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please write a bio';
              }
              if (value.length < 50) {
                return 'Bio must be at least 50 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _hourlyRateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Hourly Rate (£)',
              prefixText: '£ ',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your hourly rate';
              }
              final rate = double.tryParse(value);
              if (rate == null || rate < 10) {
                return 'Rate must be at least £10';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _experienceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Years of Experience',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your experience';
              }
              final years = int.tryParse(value);
              if (years == null || years < 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Make sure everything looks good before completing your profile.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppConstants.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Intro Video:',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _introVideo != null ? 'Video recorded ✓' : 'No video recorded',
                style: TextStyle(
                  color: _introVideo != null ? Colors.green : Colors.red,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                'Subjects:',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(_selectedSubjects.join(', ')),
              
              const SizedBox(height: 16),
              
              Text(
                'Bio:',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(_bioController.text),
              
              const SizedBox(height: 16),
              
              Text(
                'Hourly Rate:',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('£${_hourlyRateController.text}/hour'),
              
              const SizedBox(height: 16),
              
              Text(
                'Experience:',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text('${_experienceController.text} years'),
            ],
          ),
        ),
      ],
    );
  }
}
