import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/agora_service_stub.dart' as agora_service;
import '../../services/agora_live_service_simple.dart';
import '../../models/tutor_profile.dart';
import '../../models/live_session.dart';
import '../../models/user.dart' as app_user;

class LiveStreamingScreen extends StatefulWidget {
  final TutorProfile tutor;
  final String subject;

  const LiveStreamingScreen({
    super.key,
    required this.tutor,
    required this.subject,
  });

  @override
  State<LiveStreamingScreen> createState() => _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
  bool _isStreaming = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isInitialized = false;
  int _viewerCount = 0;
  String _status = 'Initializing...';
  
  // Live session service
  final AgoraLiveService _liveService = AgoraLiveService();
  
  // Raised hands management
  List<RaisedHand> _raisedHands = [];
  String? _currentSpeaker;
  List<LiveSessionMessage> _messages = [];
  final ScrollController _messageScrollController = ScrollController();
  bool _showRaisedHands = false;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
    _setupLiveService();
  }

  @override
  void dispose() {
    _messageScrollController.dispose();
    _liveService.dispose();
    _stopStreaming();
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
  }

  Future<void> _initializeAgora() async {
    setState(() {
      _status = 'Initializing Agora...';
    });

    final success = await agora_service.AgoraService.initialize();
    if (success) {
      setState(() {
        _isInitialized = true;
        _status = 'Ready to start streaming';
      });
    } else {
      setState(() {
        _status = 'Failed to initialize Agora. Please check your App ID.';
      });
    }
  }

  Future<void> _startStreaming() async {
    if (!_isInitialized) return;

    setState(() {
      _status = 'Starting stream...';
    });

    final channelName = 'live_${widget.tutor.id}';
    final success = await agora_service.AgoraService.joinChannelAsBroadcaster(channelName);
    
    if (success) {
      setState(() {
        _isStreaming = true;
        _status = 'Live streaming';
      });
    } else {
      setState(() {
        _status = 'Failed to start streaming';
      });
    }
  }

  Future<void> _stopStreaming() async {
    if (!_isStreaming) return;

    await agora_service.AgoraService.leaveChannel();
    setState(() {
      _isStreaming = false;
      _status = 'Stream ended';
    });
  }

  Future<void> _toggleMute() async {
    await agora_service.AgoraService.muteLocalAudioStream(_isMuted);
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  Future<void> _toggleVideo() async {
    await agora_service.AgoraService.enableLocalVideo(_isVideoEnabled);
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
    });
  }

  Future<void> _switchCamera() async {
    await agora_service.AgoraService.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video preview/stream
          if (_isInitialized)
            Center(
              child: agora_service.AgoraService.getLocalVideoView() ?? 
                Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Text(
                      'Camera Preview',
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
                    const CircularProgressIndicator(
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
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
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    // Live indicator
                    if (_isStreaming)
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
                    Colors.black.withValues(alpha: 0.8),
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
                              widget.subject,
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
                  
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Mute button
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        isActive: !_isMuted,
                        onTap: _toggleMute,
                      ),
                      
                      // Video toggle
                      _buildControlButton(
                        icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                        isActive: _isVideoEnabled,
                        onTap: _toggleVideo,
                      ),
                      
                      // Switch camera
                      _buildControlButton(
                        icon: Icons.switch_camera,
                        onTap: _switchCamera,
                      ),
                      
                      // Start/Stop streaming
                      _buildControlButton(
                        icon: _isStreaming ? Icons.stop : Icons.play_arrow,
                        isActive: _isStreaming,
                        backgroundColor: _isStreaming ? Colors.red : AppConstants.primaryColor,
                        onTap: _isStreaming ? _stopStreaming : _startStreaming,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Raised hands button
                  if (_isStreaming && _raisedHands.isNotEmpty)
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showRaisedHands = !_showRaisedHands;
                          });
                        },
                        icon: const Icon(Icons.pan_tool),
                        label: Text('Raised Hands (${_raisedHands.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Status text
                  Text(
                    _status,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Raised hands panel
          if (_showRaisedHands)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 300,
                color: Colors.black.withValues(alpha: 0.9),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white24),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.pan_tool, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Raised Hands',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showRaisedHands = false;
                              });
                            },
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    
                    // Raised hands list
                    Expanded(
                      child: ListView.builder(
                        itemCount: _raisedHands.length,
                        itemBuilder: (context, index) {
                          final hand = _raisedHands[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Text(
                                hand.userName.isNotEmpty ? hand.userName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              hand.userName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Raised ${_formatTime(hand.raisedAt)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _approveSpeaker(hand),
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  tooltip: 'Approve to speak',
                                ),
                                IconButton(
                                  onPressed: () => _removeRaisedHand(hand),
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  tooltip: 'Remove',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Current speaker info
                    if (_currentSpeaker != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white24),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.mic, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              'Someone is speaking',
                              style: TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => _muteCurrentSpeaker(),
                              icon: const Icon(Icons.mic_off, color: Colors.red),
                              tooltip: 'Mute speaker',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = true,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor ?? 
                 (isActive ? AppConstants.primaryColor : Colors.grey[600]),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  // Helper methods for raised hands management
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  Future<void> _approveSpeaker(RaisedHand hand) async {
    // Create a demo user object
    final user = app_user.User(
      id: hand.userId,
      email: 'demo@tutorhouse.com',
      fullName: hand.userName,
      userType: app_user.UserType.student,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _liveService.approveSpeaker(user);
    
    // Remove from raised hands list
    setState(() {
      _raisedHands.removeWhere((h) => h.userId == hand.userId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${hand.userName} can now speak'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeRaisedHand(RaisedHand hand) {
    setState(() {
      _raisedHands.removeWhere((h) => h.userId == hand.userId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${hand.userName} from raised hands'),
        backgroundColor: Colors.grey,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _muteCurrentSpeaker() async {
    if (_currentSpeaker != null) {
      // Create a demo user object
      final user = app_user.User(
        id: _currentSpeaker!,
        email: 'demo@tutorhouse.com',
        fullName: 'Current Speaker',
        userType: app_user.UserType.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _liveService.muteSpeaker(user, 'Current Speaker');
      setState(() {
        _currentSpeaker = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speaker muted'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
  
  // Stop current speaker (tutor takes over)
  Future<void> _stopCurrentSpeaker() async {
    if (_currentSpeaker != null) {
      // For demo purposes, simulate stopping speaker
      setState(() {
        _currentSpeaker = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speaker stopped - tutor has control'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  // Set speaking time limit for all speakers
  void _setSpeakingTimeLimit(int minutes) {
    // This would be sent to all participants
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Speaking time limit set to $minutes minutes'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
