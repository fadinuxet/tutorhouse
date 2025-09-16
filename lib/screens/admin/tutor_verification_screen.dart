import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/tutor_profile.dart';
import '../../services/sample_data_service.dart';

class TutorVerificationScreen extends StatefulWidget {
  const TutorVerificationScreen({super.key});

  @override
  State<TutorVerificationScreen> createState() => _TutorVerificationScreenState();
}

class _TutorVerificationScreenState extends State<TutorVerificationScreen> {
  List<TutorProfile> _pendingTutors = [];
  List<TutorProfile> _verifiedTutors = [];
  List<TutorProfile> _rejectedTutors = [];
  
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Verified', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _loadTutors();
  }

  void _loadTutors() {
    // In a real app, this would fetch from your backend
    // For demo, we'll simulate pending tutors
    final allTutors = SampleDataService.getSampleTutors();
    
    setState(() {
      _pendingTutors = allTutors.where((tutor) => !tutor.isVerified).toList();
      _verifiedTutors = allTutors.where((tutor) => tutor.isVerified).toList();
      _rejectedTutors = []; // Empty for demo
    });
  }

  List<TutorProfile> get _filteredTutors {
    switch (_selectedFilter) {
      case 'Pending':
        return _pendingTutors;
      case 'Verified':
        return _verifiedTutors;
      case 'Rejected':
        return _rejectedTutors;
      default:
        return [..._pendingTutors, ..._verifiedTutors, ..._rejectedTutors];
    }
  }

  void _verifyTutor(TutorProfile tutor, bool approved) {
    setState(() {
      if (approved) {
        _pendingTutors.remove(tutor);
        _verifiedTutors.add(tutor);
      } else {
        _pendingTutors.remove(tutor);
        _rejectedTutors.add(tutor);
      }
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          approved 
            ? 'Tutor verified successfully!' 
            : 'Tutor application rejected.',
        ),
        backgroundColor: approved ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        title: const Text(
          'Tutor Verification',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppConstants.textPrimary),
            onPressed: _loadTutors,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                final count = _getCountForFilter(filter);
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? AppConstants.primaryColor 
                          : AppConstants.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                            ? AppConstants.primaryColor 
                            : AppConstants.textSecondary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            filter,
                            style: TextStyle(
                              color: isSelected 
                                ? AppConstants.textPrimary 
                                : AppConstants.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            count.toString(),
                            style: TextStyle(
                              color: isSelected 
                                ? AppConstants.textPrimary 
                                : AppConstants.textSecondary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Tutors list
          Expanded(
            child: _filteredTutors.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTutors.length,
                    itemBuilder: (context, index) {
                      final tutor = _filteredTutors[index];
                      return _buildTutorCard(tutor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedFilter == 'Pending' 
              ? Icons.pending_actions
              : _selectedFilter == 'Verified'
                ? Icons.verified
                : Icons.cancel,
            size: 64,
            color: AppConstants.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'Pending'
              ? 'No pending verifications'
              : _selectedFilter == 'Verified'
                ? 'No verified tutors'
                : 'No rejected tutors',
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorCard(TutorProfile tutor) {
    final isPending = _selectedFilter == 'Pending';
    final isVerified = _selectedFilter == 'Verified';
    final isRejected = _selectedFilter == 'Rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending 
            ? Colors.orange.withOpacity(0.3)
            : isVerified 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  'https://picsum.photos/80/80?random=${tutor.id.hashCode}',
                ),
                child: tutor.bio != null
                    ? Text(
                        tutor.bio!.split(' ').take(2).map((word) => word[0]).join(''),
                        style: const TextStyle(
                          color: AppConstants.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Tutor info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor',
                      style: const TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'ID: ${tutor.id}',
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isPending 
                            ? Icons.pending
                            : isVerified 
                              ? Icons.verified
                              : Icons.cancel,
                          size: 16,
                          color: isPending 
                            ? Colors.orange
                            : isVerified 
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPending 
                            ? 'Pending Review'
                            : isVerified 
                              ? 'Verified'
                              : 'Rejected',
                          style: TextStyle(
                            color: isPending 
                              ? Colors.orange
                              : isVerified 
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending 
                    ? Colors.orange.withOpacity(0.2)
                    : isVerified 
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isPending 
                    ? 'PENDING'
                    : isVerified 
                      ? 'VERIFIED'
                      : 'REJECTED',
                  style: TextStyle(
                    color: isPending 
                      ? Colors.orange
                      : isVerified 
                        ? Colors.green
                        : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Details
          _buildDetailRow('Bio', tutor.bio ?? 'No bio provided'),
          _buildDetailRow('Subjects', tutor.subjects.join(', ')),
          _buildDetailRow('Hourly Rate', '£${tutor.hourlyRate.toStringAsFixed(2)}'),
          _buildDetailRow('Experience', '${tutor.experienceYears ?? 0} years'),
          _buildDetailRow('Qualifications', tutor.qualifications.join(', ')),
          _buildDetailRow('Rating', '${tutor.rating.toStringAsFixed(1)}/5.0 (${tutor.totalRatings} reviews)'),

          const SizedBox(height: 16),

          // Documents section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification Documents',
                  style: TextStyle(
                    color: AppConstants.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDocumentItem('ID Document', 'uploaded', true),
                _buildDocumentItem('Teaching Certificate', 'uploaded', true),
                _buildDocumentItem('Background Check', 'uploaded', true),
                _buildDocumentItem('References', 'uploaded', true),
              ],
            ),
          ),

          // Action buttons
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verifyTutor(tutor, false),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _verifyTutor(tutor, true),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String name, String status, bool isUploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file,
            size: 16,
            color: isUploaded ? Colors.green : AppConstants.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            status,
            style: TextStyle(
              color: isUploaded ? Colors.green : AppConstants.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  int _getCountForFilter(String filter) {
    switch (filter) {
      case 'Pending':
        return _pendingTutors.length;
      case 'Verified':
        return _verifiedTutors.length;
      case 'Rejected':
        return _rejectedTutors.length;
      default:
        return _pendingTutors.length + _verifiedTutors.length + _rejectedTutors.length;
    }
  }
}
