import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/agora_config.dart';
import '../../services/agora_service_stub.dart' as agora_service;
import '../../services/agora_live_service.dart';
import '../../models/tutor_profile.dart';
import '../../models/video_content.dart';
import '../../models/live_session.dart';
import '../../models/user.dart' as app_user;

class LiveViewerScreen extends StatefulWidget {
  final VideoContent video;
  final TutorProfile tutor;

  const LiveViewerScreen({
    super.key,
    required this.video,
    required this.tutor,
  });

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen> {
  bool _isJoined = false;
  bool _isInitialized = false;
  int _viewerCount = 0;
  String _status = 'Connecting...';
  List<int> _remoteUsers = [];
  
  // Live session service
  final AgoraLiveService _liveService = AgoraLiveService();
  
  // UI state
  bool _isHandRaised = false;
  bool _isMuted = true;
  String? _currentSpeaker;
  List<RaisedHand> _raisedHands = [];
  List<LiveSessionMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeAgora();
    _setupLiveService();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();
    _liveService.dispose();
    _leaveChannel();
    super.dispose();
  }

  void _setupLiveService() {
    // Listen to raised hands
    _liveService.raisedHandStream.listen((hand) {
      setState(() {
        _raisedHands.add(hand);
      });
    });

    // Listen to messages
    _liveService.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
      });
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_messageScrollController.hasClients) {
          _messageScrollController.animateTo(
            _messageScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });

    // Listen to current speaker
    _liveService.currentSpeakerStream.listen((speakerId) {
      setState(() {
        _currentSpeaker = speakerId;
      });
    });

    // Listen to audio status
    _liveService.audioStatusStream.listen((muted) {
      setState(() {
        _isMuted = muted;
      });
    });
  }

  Future<void> _initializeAgora() async {
    setState(() {
      _status = 'Initializing...';
    });

    final success = await agora_service.AgoraService.initialize();
    if (success) {
      setState(() {
        _isInitialized = true;
        _status = 'Connecting to live stream...';
      });
      await _joinChannel();
    } else {
      setState(() {
        _status = 'Failed to connect. Please try again.';
      });
    }
  }

  Future<void> _joinChannel() async {
    if (!_isInitialized) return;

    final channelName = AgoraConfig.getChannelName(widget.tutor.id);
    final success = await agora_service.AgoraService.joinChannelAsAudience(channelName);
    
    if (success) {
      setState(() {
        _isJoined = true;
        _status = 'Connected to live stream';
      });
      
      // Listen to user events
      agora_service.AgoraService.userJoinedStream.listen((uid) {
        setState(() {
          _remoteUsers.add(uid);
          _viewerCount = _remoteUsers.length;
        });
      });
      
      agora_service.AgoraService.userOfflineStream.listen((uid) {
        setState(() {
          _remoteUsers.remove(uid);
          _viewerCount = _remoteUsers.length;
        });
      });
    } else {
      setState(() {
        _status = 'Failed to join live stream';
      });
    }
  }

  Future<void> _leaveChannel() async {
    if (_isJoined) {
      await agora_service.AgoraService.leaveChannel();
      setState(() {
        _isJoined = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live video stream
          if (_isJoined && _remoteUsers.isNotEmpty)
            Center(
              child: agora_service.AgoraService.getRemoteVideoView(_remoteUsers.first) ??
                Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Text(
                      'Waiting for stream...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            )
          else
            Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isInitialized)
                      const CircularProgressIndicator(
                        color: AppConstants.primaryColor,
                      )
                    else
                      const Icon(
                        Icons.live_tv,
                        color: AppConstants.primaryColor,
                        size: 64,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    if (!_isInitialized) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeAgora,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
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
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    // Live indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 8,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tutor info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppConstants.primaryColor,
                        backgroundImage: NetworkImage(
                          'https://picsum.photos/80/80?random=${widget.tutor.id.hashCode}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.video.subject ?? 'Subject',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Viewer count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_viewerCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Raise Hand button
                      _buildActionButton(
                        icon: _isHandRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
                        backgroundColor: _isHandRaised ? Colors.orange : Colors.black54,
                        onTap: _isHandRaised ? _lowerHand : _raiseHand,
                      ),
                      
                      // Like button
                      _buildActionButton(
                        icon: Icons.favorite_outline,
                        onTap: () {
                          // TODO: Implement like functionality
                        },
                      ),
                      
                      // Share button
                      _buildActionButton(
                        icon: Icons.share,
                        onTap: () {
                          // TODO: Implement share functionality
                        },
                      ),
                      
                      // Follow button
                      _buildActionButton(
                        icon: Icons.person_add,
                        onTap: () {
                          // TODO: Implement follow functionality
                        },
                      ),
                      
                      // Book trial button
                      _buildActionButton(
                        icon: Icons.calendar_today,
                        backgroundColor: AppConstants.primaryColor,
                        onTap: () {
                          // TODO: Navigate to booking
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Status text
                  Column(
                    children: [
                      Text(
                        _status,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_isHandRaised) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pan_tool, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Hand Raised',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_currentSpeaker != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'You can speak!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // Raise hand functionality
  Future<void> _raiseHand() async {
    if (!_isJoined) return;

    // Create a demo user for now
    final user = app_user.User(
      id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'demo@tutorhouse.com',
      fullName: 'Demo Student',
      userType: app_user.UserType.student,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _liveService.raiseHand(user);
    setState(() {
      _isHandRaised = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hand raised! Waiting for tutor approval...'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _lowerHand() async {
    if (!_isJoined || !_isHandRaised) return;

    await _liveService.lowerHand();
    setState(() {
      _isHandRaised = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hand lowered'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 1),
      ),
    );
  }
}
