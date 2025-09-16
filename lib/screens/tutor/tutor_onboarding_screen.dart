import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import '../../config/constants.dart';
import '../../models/tutor_profile.dart';
import '../../constants/british_curricula.dart';
import 'video_recording_screen.dart';

class TutorOnboardingScreen extends StatefulWidget {
  const TutorOnboardingScreen({super.key});

  @override
  State<TutorOnboardingScreen> createState() => _TutorOnboardingScreenState();
}

class _TutorOnboardingScreenState extends State<TutorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  int _currentStep = 0;
  final int _totalSteps = 4;

  // Personal Information
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Professional Information
  final List<String> _selectedSubjects = [];
  final List<String> _selectedYearLevels = [];
  final _hourlyRateController = TextEditingController();
  final _experienceController = TextEditingController();
  final List<String> _qualifications = [];
  final _qualificationController = TextEditingController();
  String _selectedCurrency = 'GBP';
  
  // Documents
  String? _idDocumentPath;
  String? _teachingCertificatePath;
  String? _backgroundCheckPath;
  String? _referencesPath;
  
  // Video
  String? _introVideoPath;
  VideoPlayerController? _videoController;

  // Use British curricula subjects
  final List<String> _availableSubjects = BritishCurricula.subjects;
  final List<String> _availableYearLevels = BritishCurricula.yearLevels;
  final List<Map<String, dynamic>> _availableCurrencies = BritishCurricula.currencies;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    _qualificationController.dispose();
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitApplication();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickFile(String type) async {
    try {
      // Define allowed extensions based on file type
      List<String> allowedExtensions;
      String fileTypeDescription;
      
      switch (type) {
        case 'id':
        case 'teaching':
        case 'background':
        case 'references':
          allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];
          fileTypeDescription = 'documents';
          break;
        case 'video':
          allowedExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'];
          fileTypeDescription = 'videos';
          break;
        default:
          allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];
          fileTypeDescription = 'documents';
      }

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null) {
        // For web compatibility, use bytes instead of path
        final file = result.files.single;
        final fileName = file.name;
        final fileSize = file.size;
        
        // Validate file type for videos
        if (type == 'video') {
          final fileExtension = fileName.split('.').last.toLowerCase();
          if (!allowedExtensions.contains(fileExtension)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select a valid video file (${allowedExtensions.join(', ')})'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        
        // In a real app, you would upload the bytes to your server
        // For demo purposes, we'll just store the file name
        setState(() {
          switch (type) {
            case 'id':
              _idDocumentPath = fileName;
              break;
            case 'teaching':
              _teachingCertificatePath = fileName;
              break;
            case 'background':
              _backgroundCheckPath = fileName;
              break;
            case 'references':
              _referencesPath = fileName;
              break;
            case 'video':
              _introVideoPath = fileName;
              _initializeVideoPlayer(fileName);
              break;
          }
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileTypeDescription file "$fileName" selected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _recordVideo() async {
    try {
      final result = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => VideoRecordingScreen(
            maxDurationMinutes: 60, // Max 60 minutes as requested
            onVideoRecorded: (videoPath) {
              if (videoPath != null) {
                setState(() {
                  _introVideoPath = videoPath;
                });
                _initializeVideoPlayer(videoPath);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video recorded successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording video: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _initializeVideoPlayer(String videoPath) async {
    try {
      // Dispose previous controller
      _videoController?.dispose();
      
      // For demo purposes, we'll create a mock video controller
      // In a real app, you would use the actual video file
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
      );
      
      await _videoController!.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing video player: $e');
      // For demo, we'll just show a placeholder
    }
  }

  void _addQualification() {
    if (_qualificationController.text.trim().isNotEmpty) {
      setState(() {
        _qualifications.add(_qualificationController.text.trim());
        _qualificationController.clear();
      });
    }
  }

  void _removeQualification(int index) {
    setState(() {
      _qualifications.removeAt(index);
    });
  }

  void _toggleSubject(String subject) {
    setState(() {
      if (_selectedSubjects.contains(subject)) {
        _selectedSubjects.remove(subject);
      } else {
        _selectedSubjects.add(subject);
      }
    });
  }

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppConstants.surfaceColor,
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                'Application Submitted!',
                style: TextStyle(color: AppConstants.textPrimary),
              ),
            ],
          ),
          content: const Text(
            'Your tutor application has been submitted for review. You\'ll receive an email notification once it\'s been processed (usually within 24-48 hours).',
            style: TextStyle(color: AppConstants.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back
              },
              child: const Text(
                'OK',
                style: TextStyle(color: AppConstants.primaryColor),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        title: Text(
          'Become a Tutor',
          style: const TextStyle(color: AppConstants.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppConstants.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          right: index < _totalSteps - 1 ? 8 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? AppConstants.primaryColor
                              : AppConstants.textSecondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildPersonalInfoStep(),
                _buildProfessionalInfoStep(),
                _buildDocumentsStep(),
                _buildVideoStep(),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppConstants.primaryColor),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_currentStep == _totalSteps - 1 ? 'Submit' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us about yourself',
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell students about your teaching experience and approach...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please write a brief bio';
                }
                if (value.length < 50) {
                  return 'Bio must be at least 50 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Information',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your teaching expertise and qualifications',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Subjects
          const Text(
            'Subjects you teach:',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSubjects.map((subject) {
              final isSelected = _selectedSubjects.contains(subject);
              return GestureDetector(
                onTap: () => _toggleSubject(subject),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppConstants.primaryColor 
                        : AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? AppConstants.primaryColor 
                          : AppConstants.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    subject,
                    style: TextStyle(
                      color: isSelected 
                          ? AppConstants.textPrimary 
                          : AppConstants.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Hourly rate
          TextFormField(
            controller: _hourlyRateController,
            decoration: const InputDecoration(
              labelText: 'Hourly Rate (£)',
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your hourly rate';
              }
              final rate = double.tryParse(value);
              if (rate == null || rate < 10) {
                return 'Minimum rate is £10/hour';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Experience
          TextFormField(
            controller: _experienceController,
            decoration: const InputDecoration(
              labelText: 'Years of Teaching Experience',
              prefixIcon: Icon(Icons.work),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your experience';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Qualifications
          const Text(
            'Qualifications:',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _qualificationController,
                  decoration: const InputDecoration(
                    hintText: 'Add a qualification...',
                    prefixIcon: Icon(Icons.school),
                  ),
                  onFieldSubmitted: (_) => _addQualification(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addQualification,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._qualifications.asMap().entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.value)),
                  IconButton(
                    onPressed: () => _removeQualification(entry.key),
                    icon: const Icon(Icons.close, size: 16),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Documents',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload required documents for verification',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          _buildDocumentUpload(
            'ID Document',
            'Upload a clear photo of your government-issued ID',
            _idDocumentPath,
            () => _pickFile('id'),
          ),
          const SizedBox(height: 16),

          _buildDocumentUpload(
            'Teaching Certificate',
            'Upload your teaching qualification or degree certificate',
            _teachingCertificatePath,
            () => _pickFile('teaching'),
          ),
          const SizedBox(height: 16),

          _buildDocumentUpload(
            'Background Check',
            'Upload your DBS check or equivalent background verification',
            _backgroundCheckPath,
            () => _pickFile('background'),
          ),
          const SizedBox(height: 16),

          _buildDocumentUpload(
            'References',
            'Upload reference letters from previous employers or clients',
            _referencesPath,
            () => _pickFile('references'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Introduction Video',
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Record or upload a video introducing yourself to students (max 60 minutes)',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Supported video formats: MP4, MOV, AVI, MKV, WebM, M4V',
            style: TextStyle(
              color: AppConstants.textSecondary.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),

          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.textSecondary.withOpacity(0.3),
              ),
            ),
            child: _introVideoPath != null && _videoController != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Video player
                        Positioned.fill(
                          child: _videoController!.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                                  ),
                                ),
                        ),
                        // Play/Pause overlay
                        Positioned.fill(
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_videoController!.value.isPlaying) {
                                    _videoController!.pause();
                                  } else {
                                    _videoController!.play();
                                  }
                                });
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Video info overlay
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _introVideoPath!.split('/').last,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _introVideoPath != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.video_file, size: 48, color: Colors.green),
                          const SizedBox(height: 8),
                          const Text(
                            'Video uploaded successfully!',
                            style: TextStyle(color: AppConstants.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _introVideoPath!.split('/').last,
                            style: TextStyle(
                              color: AppConstants.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam, size: 48, color: AppConstants.textSecondary),
                          const SizedBox(height: 8),
                          const Text(
                            'No video uploaded yet',
                            style: TextStyle(color: AppConstants.textSecondary),
                          ),
                        ],
                      ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _recordVideo,
                  icon: const Icon(Icons.videocam),
                  label: const Text('Record Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickFile('video'),
                  icon: const Icon(Icons.upload),
                  label: Text(_introVideoPath != null ? 'Change Video File' : 'Upload Video File'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: const BorderSide(color: AppConstants.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Video should be 1-2 minutes long, introducing yourself and your teaching style.',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUpload(String title, String description, String? filePath, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: filePath != null 
              ? Colors.green.withOpacity(0.3)
              : AppConstants.textSecondary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                filePath != null ? Icons.check_circle : Icons.upload_file,
                color: filePath != null ? Colors.green : AppConstants.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (filePath != null)
                Text(
                  'Uploaded',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(filePath != null ? Icons.refresh : Icons.upload),
              label: Text(filePath != null ? 'Change File' : 'Upload File'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: filePath != null 
                      ? Colors.green 
                      : AppConstants.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
