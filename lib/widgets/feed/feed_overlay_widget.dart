import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../models/video_content.dart';
import '../../models/tutor_profile.dart';
import '../../services/sample_data_service.dart';

class FeedOverlayWidget extends StatefulWidget {
  final VideoContent video;
  final VoidCallback onBookTrial;
  final VoidCallback onFollow;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final bool hasBookedTrial;
  final String? trialBookedDate;

  const FeedOverlayWidget({
    super.key,
    required this.video,
    required this.onBookTrial,
    required this.onFollow,
    required this.onLike,
    required this.onShare,
    this.hasBookedTrial = false,
    this.trialBookedDate,
  });

  @override
  State<FeedOverlayWidget> createState() => _FeedOverlayWidgetState();
}

class _FeedOverlayWidgetState extends State<FeedOverlayWidget> {
  TutorProfile? tutor;

  @override
  void initState() {
    super.initState();
    _loadTutor();
  }

  Future<void> _loadTutor() async {
    try {
      final tutors = SampleDataService.getSampleTutors();
      final foundTutor = tutors.firstWhere(
        (t) => t.id == widget.video.tutorId,
        orElse: () => TutorProfile(
          id: widget.video.tutorId,
          userId: widget.video.tutorId,
          fullName: 'Unknown Tutor',
          bio: 'Tutor',
          introVideoUrl: widget.video.videoUrl,
          subjects: [widget.video.subject ?? 'Maths'],
          yearLevels: ['Year 10', 'Year 11'],
          hourlyRate: 25.0,
          currency: 'GBP',
          qualifications: [],
          isVerified: false,
          rating: 0.0,
          totalRatings: 0,
          totalSessions: 0,
          createdAt: DateTime.now(),
        ),
      );
      
      if (mounted) {
        setState(() {
          tutor = foundTutor;
        });
      }
    } catch (e) {
      print('Error loading tutor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient (non-interactive)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),
        ),
        
        // Safe area content
        SafeArea(
          child: Column(
            children: [
              const Spacer(),
              
              // Bottom Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left Side - Tutor Info (non-interactive)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tutor Name
                          Text(
                            tutor?.bio?.split(' ').take(2).join(' ') ?? 'Tutor',
                            style: const TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          // Rating
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tutor?.ratingDisplay ?? '4.9',
                                style: const TextStyle(
                                  color: AppConstants.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${tutor?.totalRatings ?? 127} reviews)',
                                style: const TextStyle(
                                  color: AppConstants.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          
                          // Show year levels if available
                          if (tutor?.yearLevels?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              tutor!.yearLevels!.join(', '),
                              style: const TextStyle(
                                color: AppConstants.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 8),
                          
                          // Subject
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.video.subject ?? 'Maths',
                              style: const TextStyle(
                                color: AppConstants.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Price
                          Text(
                            tutor?.hourlyRateDisplay ?? '£25/hour',
                            style: const TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Right Side - Action Buttons (interactive)
                    Column(
                      children: [
                        // Like Button
                        _ActionButton(
                          icon: Icons.favorite_border,
                          label: '${widget.video.likeCount}',
                          onTap: widget.onLike,
                        ),
                        const SizedBox(height: 16),
                        
                        // Follow Button
                        _ActionButton(
                          icon: Icons.person_add_outlined,
                          label: 'Follow',
                          onTap: widget.onFollow,
                        ),
                        const SizedBox(height: 16),
                        
                        // Share Button
                        _ActionButton(
                          icon: Icons.share_outlined,
                          label: 'Share',
                          onTap: widget.onShare,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Book Trial Button (interactive) or Trial Booked indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: widget.hasBookedTrial
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Trial Booked',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.trialBookedDate != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.trialBookedDate!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ElevatedButton(
                            onPressed: widget.onBookTrial,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Book Trial - 30 min',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppConstants.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}