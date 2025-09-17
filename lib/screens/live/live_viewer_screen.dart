import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/constants.dart';
import '../../services/agora_live_service_simple.dart';
import '../../models/tutor_profile.dart';
import '../../models/video_content.dart';
import '../../models/live_session.dart';
import '../../models/user.dart' as app_user;

// Simple chat message model
class ChatMessage {
  final String id;
  final String userId;
  final String userName;
  final String message;
  final DateTime timestamp;
  final bool isFromTutor;
  final bool isQuestion;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    required this.message,
    required this.timestamp,
    this.isFromTutor = false,
    this.isQuestion = false,
  });
}

class LiveViewerScreen extends StatefulWidget {
  final String sessionId;
  final String tutorName;
  final VideoContent? video;
  final TutorProfile? tutor;

  const LiveViewerScreen({
    super.key,
    required this.sessionId,
    required this.tutorName,
    this.video,
    this.tutor,
  });

  @override
  State<LiveViewerScreen> createState() => _LiveViewerScreenState();
}

class _LiveViewerScreenState extends State<LiveViewerScreen> {
  bool _isJoined = false;
  bool _isInitialized = false;
  int _viewerCount = 0;
  String _status = 'Click the play button to join the live session';
  // Live session limits
  static const int _maxParticipants = 50; // Maximum users who can join AND raise hands
  
  // Live session service
  final AgoraLiveService _liveService = AgoraLiveService();
  
  // UI state
  bool _isHandRaised = false;
  bool _isMuted = true;
  String? _currentSpeaker;
  bool _hasJoinedLive = false; // Track if user has joined the live session
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();
  
  // Chat system
  int _selectedChatTab = 0; // 0 = Chat with all, 1 = Ask tutor
  final List<ChatMessage> _chatMessages = [];
  final List<ChatMessage> _tutorQuestions = [];
  bool _isChatVisible = false;
  
  // Speaking time management
  DateTime? _speakingStartTime;
  static const int _maxSpeakingTime = 60; // 1 minute max speaking time
  Timer? _speakingTimer;

  @override
  void initState() {
    super.initState();
    
    _initializeAgora();
    _setupLiveService();
    // DON'T auto-join - let user click Join Live button first
    
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();
    _speakingTimer?.cancel(); // Cancel timer on dispose
    _liveService.dispose();
    _leaveChannel();
    super.dispose();
  }

  Future<void> _initializeAgora() async {
    setState(() {
      _status = 'Initializing...';
    });

    // For demo purposes, simulate successful initialization
    // In production, this would call the real Agora service
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isInitialized = true;
      _status = 'Connected! You can speak and participate freely'; // Updated status
      _isJoined = true; // Set joined to true for demo
      _viewerCount = 42; // Demo viewer count
    });
    
  }

  Future<void> _joinChannel() async {
    if (!_isInitialized) return;

    // Check if session is full
    if (_viewerCount >= _maxParticipants) {
      setState(() {
        _isJoined = false;
        _status = 'Session is full! Maximum ${_maxParticipants} participants reached.';
      });
      return;
    }

    // For demo purposes, simulate successful join
    // In production, this would call the real Agora service
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _isJoined = true;
      _hasJoinedLive = true; // User has joined the live session
      _status = 'Connected! You can speak and participate freely'; // Updated status
      _viewerCount = 42; // Demo viewer count
    });
    
  }

  Future<void> _leaveChannel() async {
    if (_isJoined) {
      // For demo purposes, simulate leaving channel
      // In production, this would call the real Agora service
      await Future.delayed(const Duration(milliseconds: 200));
      
      setState(() {
        _isJoined = false;
        _hasJoinedLive = false; // User has left the live session
        _isHandRaised = false; // Reset hand raised state
        _isChatVisible = false; // Hide chat when leaving
        _status = 'Disconnected from live stream';
        
        // Clear all chat messages when session ends
        _chatMessages.clear();
        _tutorQuestions.clear();
      });
      
      
      // Show disconnect message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected from live session'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _setupLiveService() {
    // Listen to live service events
    _liveService.raisedHandStream.listen((hand) {
      // Handle raised hand events
    });

    _liveService.messageStream.listen((message) {
      // Handle message events
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

    _liveService.currentSpeakerStream.listen((speaker) {
      setState(() {
        _currentSpeaker = speaker;
      });
    });
  }

  Future<void> _raiseHand() async {
    if (!_isJoined) {
      return;
    }

    
    // Create a demo user for now
    final user = app_user.User(
      id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'demo@tutorhouse.com',
      fullName: 'Demo Student',
      userType: app_user.UserType.student,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // For demo purposes, simulate raising hand
    try {
      await _liveService.raiseHand(user);
    } catch (e) {
      // Continue anyway for demo purposes
    }
    
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

    
    // Create a demo user for now
    final user = app_user.User(
      id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'demo@tutorhouse.com',
      fullName: 'Demo Student',
      userType: app_user.UserType.student,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    try {
      await _liveService.lowerHand(user);
    } catch (e) {
      // Continue anyway for demo purposes
    }
    
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

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    
    // For demo purposes, simulate mute/unmute
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMuted ? 'Microphone muted' : 'Microphone unmuted'),
        backgroundColor: _isMuted ? Colors.red : Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  // Start speaking timer when user is approved to speak
  void _startSpeakingTimer() {
    _speakingStartTime = DateTime.now();
    _speakingTimer?.cancel();
    _speakingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_speakingStartTime != null) {
        final elapsed = DateTime.now().difference(_speakingStartTime!).inSeconds;
        final remaining = _maxSpeakingTime - elapsed;
        
        if (remaining <= 0) {
          // Time's up - automatically stop speaking
          _stopSpeaking();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your speaking time is up!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (remaining <= 10) {
          // Warning when 10 seconds left
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$remaining seconds left to speak'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    });
  }
  
  // Stop speaking (called by tutor or when time expires)
  void _stopSpeaking() {
    _speakingTimer?.cancel();
    _speakingStartTime = null;
    _currentSpeaker = null;
    setState(() {});
  }
  
  // Get remaining speaking time
  int get _remainingSpeakingTime {
    if (_speakingStartTime == null) return 0;
    final elapsed = DateTime.now().difference(_speakingStartTime!).inSeconds;
    return (_maxSpeakingTime - elapsed).clamp(0, _maxSpeakingTime);
  }
  
  // Check if user is currently speaking
  bool get _isCurrentlySpeaking => _currentSpeaker != null && _speakingStartTime != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          if (_hasJoinedLive)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.grey],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tutor info
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/80/80?random=${widget.sessionId.hashCode}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.tutorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Live Session',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
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
                              color: Colors.blue,
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
                        if (_isCurrentlySpeaking) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.mic, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Speaking: ${_remainingSpeakingTime}s',
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
                      ],
                    ),
                    
                    // Helpful instruction text
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Raise hand to speak (requires approval by tutor)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
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
                      _hasJoinedLive ? _status : 'Click the Join button to join the live session',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    if (!_isInitialized) ...[
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _initializeAgora,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Connect'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Chat overlay (when visible)
          if (_isChatVisible && _hasJoinedLive)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85), // Semi-transparent black
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with tabs
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3), // Semi-transparent header
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Chat',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // White text
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isChatVisible = false;
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white, // White close icon
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Tab buttons
                          Row(
                            children: [
                              Expanded(
                                child: _buildChatTab(0, 'Chat with all'),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildChatTab(1, 'Ask tutor'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Chat messages
                    Expanded(
                      child: _selectedChatTab == 0 ? _buildChatMessages() : _buildTutorQuestions(),
                    ),
                    // Message input
                    _buildMessageInput(),
                  ],
                ),
              ),
            ),

          // Bottom action buttons
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _hasJoinedLive ? [
                // Chat button
                _buildActionButton(
                  icon: Icons.chat,
                  backgroundColor: _isChatVisible ? Colors.orange : Colors.blue,
                  onTap: () {
                    setState(() {
                      _isChatVisible = !_isChatVisible;
                    });
                  },
                ),
                
                // Raise Hand icon (toggle indicator) - GRAY INITIALLY
                _buildActionButton(
                  icon: _isHandRaised ? Icons.pan_tool : Icons.pan_tool_outlined,
                  backgroundColor: _isHandRaised ? Colors.blue : Colors.grey, // GRAY INITIALLY
                  onTap: () {
                    setState(() {
                      _isHandRaised = !_isHandRaised;
                    });
                  },
                ),
                
                // Leave Live button (disconnect)
                _buildActionButton(
                  icon: Icons.exit_to_app,
                  backgroundColor: Colors.red,
                  onTap: () {
                    _leaveChannel();
                    Navigator.pop(context);
                  },
                ),
              ] : [
                // Join Live button (when not joined yet)
                _buildJoinButton(),
                
                // Leave button
                _buildActionButton(
                  icon: Icons.close,
                  backgroundColor: Colors.grey,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
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
      onTap: () {
        onTap();
      },
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

  Widget _buildJoinButton() {
    return GestureDetector(
      onTap: () {
        _joinChannel();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Join',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildChatTab(int index, String title) {
    final isSelected = _selectedChatTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChatTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    return ListView.builder(
      controller: _messageScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        final message = _chatMessages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildTutorQuestions() {
    return ListView.builder(
      controller: _messageScrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _tutorQuestions.length,
      itemBuilder: (context, index) {
        final message = _tutorQuestions[index];
        return _buildMessageBubble(message, isQuestion: true);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, {bool isQuestion = false}) {
    final isMe = message.userId == 'current_user'; // In real app, compare with actual user ID
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: message.isFromTutor ? Colors.orange : Colors.blue,
              child: Text(
                message.userName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe 
                    ? AppConstants.primaryColor 
                    : (message.isFromTutor ? Colors.orange.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(20),
                border: message.isFromTutor ? Border.all(color: Colors.orange.withValues(alpha: 0.5)) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Text(
                      message.userName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: message.isFromTutor ? Colors.orange[300] : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppConstants.primaryColor,
              child: const Text(
                'Me',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white), // White text
              decoration: InputDecoration(
                hintText: _selectedChatTab == 0 
                    ? 'Type a message...' 
                    : 'Ask a question to the tutor...',
                hintStyle: const TextStyle(color: Colors.white60), // Light white hint
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: AppConstants.primaryColor),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      userName: 'Me',
      message: text,
      timestamp: DateTime.now(),
      isQuestion: _selectedChatTab == 1,
    );

    setState(() {
      if (_selectedChatTab == 0) {
        _chatMessages.add(message);
      } else {
        _tutorQuestions.add(message);
      }
    });

    _messageController.clear();
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_messageScrollController.hasClients) {
        _messageScrollController.animateTo(
          _messageScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedChatTab == 0 
              ? 'Message sent to chat' 
              : 'Question sent to tutor',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}