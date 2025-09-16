import 'package:flutter/material.dart';
import '../models/video_content.dart';
import '../models/tutor_profile.dart';
import '../services/sample_data_service.dart';
import '../config/constants.dart';
import '../screens/live/live_viewer_screen.dart';
import '../screens/live/group_live_session_screen.dart';
import '../screens/auth/mobile_auth_screen.dart';
import '../screens/tutor/tutor_onboarding_screen.dart';

class FeedOverlayWidget extends StatelessWidget {
  final VideoContent video;
  final VoidCallback onBookTrial;
  final VoidCallback onFollow;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const FeedOverlayWidget({
    super.key,
    required this.video,
    required this.onBookTrial,
    required this.onFollow,
    required this.onLike,
    required this.onShare,
  });

  void _showSignInPrompt(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Text(
          'Sign In Required',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please sign in to $action',
              style: const TextStyle(color: AppConstants.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you a student or tutor?',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TutorOnboardingScreen(),
                ),
              );
            },
            icon: const Icon(Icons.school, size: 18),
            label: const Text('Become a Tutor'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.secondaryColor,
              side: const BorderSide(color: AppConstants.secondaryColor),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MobileAuthScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person, size: 18),
            label: const Text('Sign In as Student'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get tutor information
    final tutor = SampleDataService.getTutorById(video.tutorId);
    
    return Stack(
      children: [
        // Bottom overlay with tutor info and CTAs
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 80, 16), // Right padding for action buttons
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tutor name and rating
                Row(
                  children: [
                    // Tutor avatar
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppConstants.primaryColor,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/80/80?random=${video.tutorId.hashCode}',
                      ),
                      child: tutor?.bio != null
                          ? Text(
                              tutor!.bio!.split(' ').take(2).map((word) => word[0]).join(''),
                              style: const TextStyle(
                                color: AppConstants.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutor?.bio?.split(' ').take(2).join(' ') ?? 'Tutor',
                            style: const TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              ...List.generate(5, (index) => Icon(
                                Icons.star,
                                color: index < (tutor?.rating?.round() ?? 5)
                                    ? AppConstants.accentColor
                                    : Colors.grey[600],
                                size: 14,
                              )),
                              const SizedBox(width: 6),
                              Text(
                                '${tutor?.rating?.toStringAsFixed(1) ?? '4.5'} (${tutor?.totalRatings ?? 127})',
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
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                      // Subject and experience
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppConstants.primaryColor),
                            ),
                            child: Text(
                              video.subject ?? 'Subject',
                              style: const TextStyle(
                                color: AppConstants.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Live status indicator
                          if (video.isLive) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                    size: 8,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${tutor?.experienceYears ?? 5} years exp',
                            style: const TextStyle(
                              color: AppConstants.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                
                const SizedBox(height: 16),
                
                // Price and CTA buttons
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutor?.hourlyRateDisplay ?? '£25/hour',
                            style: const TextStyle(
                              color: AppConstants.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
            // Primary CTA - Book Now, Watch Live, or Join Q&A
            if (video.isLive) ...[
              // Live options
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showSignInPrompt(context, 'watch live streams'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: AppConstants.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.live_tv, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Watch Live',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showSignInPrompt(context, 'join live Q&A sessions'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Join Free Q&A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Regular booking
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showSignInPrompt(context, 'book a session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: AppConstants.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Book Session',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Right side action buttons
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            children: [
              // Tutor Avatar (clickable)
              _ActionButton(
                icon: Icons.person,
                onTap: () {
                  // TODO: Navigate to tutor profile
                },
                isCircular: true,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppConstants.primaryColor,
                  backgroundImage: NetworkImage(
                    'https://picsum.photos/80/80?random=${video.tutorId.hashCode}',
                  ),
                  child: tutor?.bio != null
                      ? Text(
                          tutor!.bio!.split(' ').take(2).map((word) => word[0]).join(''),
                          style: const TextStyle(
                            color: AppConstants.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Like Button
              _ActionButton(
                icon: Icons.favorite_outline,
                count: video.likeCount,
                onTap: onLike,
                isActive: false, // TODO: Check if user has liked
              ),
              
              const SizedBox(height: 20),
              
              // Save/Bookmark Button
              _ActionButton(
                icon: Icons.bookmark_outline,
                onTap: () {
                  // TODO: Implement save functionality
                },
                isActive: false,
              ),
              
              const SizedBox(height: 20),
              
              // Share Button
              _ActionButton(
                icon: Icons.share_outlined,
                onTap: onShare,
              ),
              
              const SizedBox(height: 20),
              
              // Follow Button
              _ActionButton(
                icon: Icons.person_add_outlined,
                onTap: onFollow,
                isActive: false, // TODO: Check if user is following
              ),
              
              const SizedBox(height: 20),
              
              // More Button
              _ActionButton(
                icon: Icons.more_vert,
                onTap: () {
                  // TODO: Show more options
                },
              ),
            ],
          ),
        ),
        
        // Top header with app branding
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tutorhouse',
                    style: TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: Search functionality
                        },
                        icon: const Icon(
                          Icons.search,
                          color: AppConstants.textPrimary,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Notifications
                        },
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppConstants.textPrimary,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: Profile
                        },
                        icon: const Icon(
                          Icons.person_outline,
                          color: AppConstants.textPrimary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _watchLive(BuildContext context, TutorProfile? tutor) {
    if (tutor != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LiveViewerScreen(
            video: video,
            tutor: tutor,
          ),
        ),
      );
    }
  }

  void _joinGroupSession(BuildContext context, TutorProfile? tutor) {
    if (tutor != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GroupLiveSessionScreen(
            tutor: tutor,
            subject: video.subject ?? 'General',
          ),
        ),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData? icon;
  final int? count;
  final VoidCallback onTap;
  final bool isActive;
  final bool isCircular;
  final Widget? child;

  const _ActionButton({
    this.icon,
    this.count,
    required this.onTap,
    this.isActive = false,
    this.isCircular = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: isCircular ? EdgeInsets.zero : const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCircular ? Colors.transparent : Colors.black.withOpacity(0.6),
              shape: isCircular ? BoxShape.circle : BoxShape.circle,
            ),
            child: child ?? Icon(
              icon,
              color: isActive ? AppConstants.accentColor : AppConstants.textPrimary,
              size: isCircular ? 48 : 24,
            ),
          ),
          if (count != null) ...[
            const SizedBox(height: 4),
            Text(
              _formatCount(count!),
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}