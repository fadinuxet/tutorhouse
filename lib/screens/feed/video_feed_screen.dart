import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/constants.dart';
import '../../models/video_content.dart';
import '../../models/live_session.dart';
import '../../models/tutor_profile.dart';
import '../../services/sample_data_service.dart';
import '../../services/feed_content_service.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../providers/tutor_provider.dart';
import '../../main.dart';
import '../../widgets/feed/video_player_widget.dart';
import '../../widgets/feed/feed_overlay_widget.dart';
import '../../widgets/feed/live_session_widget.dart';
import '../auth/mobile_auth_screen.dart';
import '../booking/mobile_booking_flow.dart';

class VideoFeedScreen extends ConsumerStatefulWidget {
  final int? initialIndex;
  
  const VideoFeedScreen({super.key, this.initialIndex});

  @override
  ConsumerState<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends ConsumerState<VideoFeedScreen> with WidgetsBindingObserver {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isLoading = false;
  List<dynamic> _feedContent = []; // Mixed content: videos + live sessions
  List<TutorProfile> _tutors = [];
  
  // Cache for booking status to avoid excessive rebuilds
  Map<String, bool> _trialBookingCache = {};
  Map<String, String?> _trialBookingDateCache = {};

  @override
  void initState() {
    super.initState();
    print('🎬 VideoFeedScreen initState called');
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
    _loadVideos();
  }
  
  @override
  void didUpdateWidget(VideoFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh booking cache when widget updates (e.g., after login)
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshBookingCache();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh the screen when authentication state changes
    print('🔄 Dependencies changed, refreshing booking status...');
    // Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshBookingCache();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed, refreshing booking status...');
      // Use addPostFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _refreshBookingCache();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    print('🎬 Loading mixed content...');
    setState(() {
      _isLoading = true;
    });

    try {
      // Load mixed content (videos + live sessions)
      print('🎬 Getting mixed feed...');
      final feedContent = await FeedContentService.getMixedFeed();
      print('🎬 Got ${feedContent.length} items');
      
      print('🎬 Getting sample tutors...');
      final tutors = await SampleDataService.getSampleTutors();
      print('🎬 Got ${tutors.length} tutors');
      
      print('🎬 Setting state...');
      setState(() {
        _feedContent = feedContent;
        _tutors = tutors;
        _isLoading = false;
      });
      print('🎬 Mixed feed state updated successfully');
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      print('❌ Error loading content: $e');
      print('❌ Stack trace: $stackTrace');
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showBookingBottomSheet(VideoContent video) {
    // Check if user is logged in
    if (AuthService.isAuthenticated) {
      // Check if user has already booked a trial with this tutor
      final currentUser = AuthService.currentUser;
      if (currentUser != null && !BookingService.canBookTrial(currentUser.id, video.tutorId)) {
        // User has already booked a trial with this tutor
        _showTrialAlreadyBookedDialog(video);
        return;
      }
      
      // User is logged in and can book trial, go directly to booking
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileBookingFlow(
            video: video,
            currentVideoIndex: _currentIndex,
          ),
        ),
      );
    } else {
      // User is not logged in, show signup requirement dialog
      _showSignupRequiredDialog(video);
    }
  }

  void _showSignupRequiredDialog(VideoContent video) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Sign Up to Book Trial',
          style: TextStyle(
            color: AppConstants.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add,
              color: AppConstants.primaryColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'To book a trial session with ${_getTutorName(video.tutorId)}, please create a free account.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'We\'ll send you and your tutor a confirmation email with all the meeting details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'You can continue browsing videos as a guest anytime!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to signup screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MobileAuthScreen(showSignUp: true),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  void _showTrialAlreadyBookedDialog(VideoContent video) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Trial Already Booked',
          style: TextStyle(
            color: AppConstants.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.orange,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'You have already booked a trial session with ${_getTutorName(video.tutorId)}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can only book one trial per tutor. Book a paid session to continue learning!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  bool _hasBookedTrialWithTutor(String tutorId, TutorProvider tutorProvider) {
    print('🔍 _hasBookedTrialWithTutor called for tutor: $tutorId');
    
    // Use cached result if available
    if (_trialBookingCache.containsKey(tutorId)) {
      final hasBooking = _trialBookingCache[tutorId]!;
      print('🔍 Cache result: $hasBooking');
      return hasBooking;
    }
    
    // Use TutorProvider to check booking status
    final hasBooking = tutorProvider.hasBookedTrialWithTutor(tutorId);
    
    // Cache the result
    _trialBookingCache[tutorId] = hasBooking;
    
    print('🔍 TutorProvider result: $hasBooking');
    
    return hasBooking;
  }

  String? _getTrialBookingDate(String tutorId, TutorProvider tutorProvider) {
    // Use cached result if available
    if (_trialBookingDateCache.containsKey(tutorId)) {
      return _trialBookingDateCache[tutorId];
    }
    
    // Use TutorProvider to get booking date
    final bookingDate = tutorProvider.getBookedTrialDate(tutorId);
    
    // Cache the result
    if (bookingDate != null) {
      _trialBookingDateCache[tutorId] = bookingDate;
    }
    
    return bookingDate;
  }
  
  // Refresh booking cache when needed
  void _refreshBookingCache() {
    _trialBookingCache.clear();
    _trialBookingDateCache.clear();
    setState(() {});
  }

  void _toggleFollow(String tutorId) {
    // TODO: Implement follow functionality
    print('Toggle follow for tutor: $tutorId');
  }

  void _toggleLike(String videoId) {
    // TODO: Implement like functionality
    print('Toggle like for video: $videoId');
  }

  void _shareVideo(VideoContent video) {
    // TODO: Implement share functionality
    print('Share video: ${video.id}');
  }

  void _shareLiveSession(LiveSession session) {
    // TODO: Implement live session sharing
    print('Share live session: ${session.id}');
  }

  void _raiseHand(String sessionId) {
    // TODO: Implement raise hand functionality
    print('Raising hand for session: $sessionId');
  }

  void _handleJoinLiveSession(LiveSession session) {
    // This is handled by the LiveSessionWidget itself
    print('Joining live session: ${session.title}');
  }

  String _getTutorName(String tutorId) {
    final tutor = _tutors.firstWhere(
      (t) => t.id == tutorId,
      orElse: () => TutorProfile(
        id: tutorId,
        userId: tutorId,
        fullName: 'Unknown Tutor',
        bio: 'Tutor',
        introVideoUrl: '',
        subjects: [],
        yearLevels: [],
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
    return tutor.bio?.split(' ').take(2).join(' ') ?? 'this tutor';
  }

  @override
  Widget build(BuildContext context) {
    // Watch the tutor provider to avoid ref.read() during build
    final tutorProviderValue = ref.watch(tutorProvider);
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Content Area Logic
          _feedContent.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: _onPageChanged,
                  itemCount: _feedContent.length,
                  itemBuilder: (context, index) {
                    final content = _feedContent[index];
                    
                    // Check if it's a video or live session
                    if (content is VideoContent) {
                      return Stack(
                        children: [
                          // Video Player
                          VideoPlayerWidget(
                            video: content,
                            isPlaying: index == _currentIndex,
                          ),
                          // Feed Overlay
                          FeedOverlayWidget(
                            video: content,
                            onBookTrial: () => _showBookingBottomSheet(content),
                            onFollow: () => _followTutor(content.tutorId),
                            onLike: () => _toggleLike(content.id),
                            onShare: () => _shareVideo(content),
                            hasBookedTrial: _hasBookedTrialWithTutor(content.tutorId, tutorProviderValue),
                            trialBookedDate: _getTrialBookingDate(content.tutorId, tutorProviderValue),
                          ),
                        ],
                      );
                    } else if (content is LiveSession) {
                      return Stack(
                        children: [
                          // Live Session Display
                          LiveSessionWidget(
                            session: content,
                            onJoin: () => _raiseHand(content.id),
                            onFollow: () => _followTutor(content.tutorId),
                            onShare: () => _shareLiveSession(content),
                          ),
                          
                          // Live Session Overlay - Simple version for live sessions
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left side - Tutor info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          content.tutor.fullName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          content.subject,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${content.currentParticipants} viewers',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Right side - Action buttons
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Raise Hand button
                                      if (AuthService.isAuthenticated)
                                        MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () => _raiseHand(content.id),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppConstants.primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.pan_tool,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 12),
                                      
                                      // Follow button
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () => _followTutor(content.tutorId),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.person_add,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Share button
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () => _shareLiveSession(content),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.share,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(
                        child: Text(
                          'Unknown content type',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  },
                )
              : _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No content available',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),

          // Top Navigation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      const Text(
                        'Tutorhouse',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Action Buttons
                      Row(
                        children: [
                          // Sign In/Profile Button
                          if (AuthService.isAuthenticated) ...[
                            // Show user profile info when logged in
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to profile or show user menu
                                  print('Profile button pressed!');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppConstants.surfaceColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppConstants.primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: AppConstants.primaryColor,
                                        child: Text(
                                          AuthService.currentUser?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AuthService.currentUser?.fullName ?? 'User',
                                        style: const TextStyle(
                                          color: AppConstants.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Show Sign In button when not logged in
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  print('Sign In button pressed!');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MobileAuthScreen(showSignUp: false),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 12),
                          
                          // Search Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: IconButton(
                              onPressed: () {
                                // TODO: Implement search
                              },
                              icon: const Icon(
                                Icons.search,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ),
                          
                          // Notifications Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: IconButton(
                              onPressed: () {
                                // TODO: Implement notifications
                              },
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ),
                          
                          // Profile Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: IconButton(
                              onPressed: () {
                                // TODO: Navigate to profile
                              },
                              icon: const Icon(
                                Icons.person_outline,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
    
    /* COMMENTED OUT FOR BINARY SEARCH DEBUGGING
    // Watch the tutor provider to avoid ref.read() during build
    final tutorProviderValue = ref.watch(tutorProvider);
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Mixed Content Feed
          _feedContent.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: _onPageChanged,
                  itemCount: _feedContent.length,
                  itemBuilder: (context, index) {
                    final content = _feedContent[index];
                    
                    // Check if it's a video or live session
                    if (content is VideoContent) {
                      return Stack(
                        children: [
                          // Video Player
                          VideoPlayerWidget(
                            video: content,
                            isPlaying: index == _currentIndex,
                          ),
                          // Overlay
                          FeedOverlayWidget(
                            video: content,
                            onBookTrial: () => _showBookingBottomSheet(content),
                            onFollow: () => _followTutor(content.tutorId),
                            onLike: () => _toggleLike(content.id),
                            onShare: () => _shareVideo(content),
                            hasBookedTrial: _hasBookedTrialWithTutor(content.tutorId, tutorProviderValue),
                            trialBookedDate: _getTrialBookingDate(content.tutorId, tutorProviderValue),
                          ),
                        ],
                      );
                    } else if (content is LiveSession) {
                      return LiveSessionWidget(
                        session: content,
                        onJoin: () => _handleJoinLiveSession(content),
                        onFollow: () => _followTutor(content.tutorId),
                        onShare: () => _shareLiveSession(content),
                      );
                    } else {
                      // Fallback for unknown content type
                      return Container(
                        color: Colors.black,
                        child: const Center(
                          child: Text(
                            'Unknown content type',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                )
              : _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.primaryColor,
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 64,
                            color: AppConstants.textSecondary,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No videos available',
                            style: TextStyle(
                              color: AppConstants.textSecondary,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),

          // Top Navigation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      const Text(
                        'Tutorhouse',
                        style: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Action Buttons
                      Row(
                        children: [
                          // Sign In/Profile Button
                          if (AuthService.isAuthenticated) ...[
                            // Show user profile info when logged in
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to profile or show user menu
                                  print('Profile button pressed!');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppConstants.surfaceColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppConstants.primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: AppConstants.primaryColor,
                                        child: Text(
                                          AuthService.currentUser?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        AuthService.currentUser?.fullName ?? 'User',
                                        style: const TextStyle(
                                          color: AppConstants.textPrimary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Show Sign In button when not logged in
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  print('Sign In button pressed!');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MobileAuthScreen(showSignUp: false),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 12),
                          
                          // Search Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: IconButton(
                              onPressed: () {
                                // TODO: Implement search
                              },
                              icon: const Icon(
                                Icons.search,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ),
                          
                          // Notifications Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: IconButton(
                              onPressed: () {
                                // TODO: Implement notifications
                              },
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ),
                          
                          // Profile Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: IconButton(
                              onPressed: () {
                                // TODO: Navigate to profile
                              },
                              icon: const Icon(
                                Icons.person_outline,
                                color: AppConstants.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
    */
  }
Future<void> _followTutor(String tutorId) async {
    debugPrint('follow $tutorId');
  }
}