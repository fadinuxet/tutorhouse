import 'package:flutter/material.dart';
import 'dart:async';
import '../../config/constants.dart';
import '../../services/agora_service.dart' as agora_service;
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
  
  // Live session service
  // Using AgoraService directly instead of AgoraLiveService
  
  // UI state
  bool _isHandRaised = false;
  bool _isMuted = true;
  String? _currentSpeaker;
  
  // Chat state
  bool _isChatVisible = false;
  int _selectedChatTab = 0; // 0 = Chat with all, 1 = Ask tutor
  final List<ChatMessage> _chatMessages = [];
  final List<ChatMessage> _tutorQuestions = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messageScrollController = ScrollController();
  
  // Speaking timer
  Timer? _speakingTimer;
  DateTime? _speakingStartTime;
  static const int _maxSpeakingTime = 60; // 1 minute max speaking time

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageScrollController.dispose();
    _speakingTimer?.cancel();
    // Clean up Agora service
    agora_service.AgoraService.leaveChannel();
    super.dispose();
  }

  Future<void> _initializeAgora() async {
    try {
      await agora_service.AgoraService.initialize();
      _setupLiveService();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing Agora: $e');
    }
  }

  void _setupLiveService() {
    // Listen to Agora service events
    agora_service.AgoraService.userJoinedStream.listen((uid) {
      print('User joined: $uid');
    });

    agora_service.AgoraService.userOfflineStream.listen((uid) {
      print('User left: $uid');
    });

    agora_service.AgoraService.connectionStateStream.listen((isConnected) {
      setState(() {
        _status = isConnected ? 'Connected to live session' : 'Disconnected from live session';
      });
    });
  }

  Widget _buildVideoView() {
    if (!_isJoined) {
      // Show placeholder when not joined
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off,
                size: 80,
                color: Colors.white54,
              ),
              SizedBox(height: 16),
              Text(
                'Video will appear here when you join',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // For demo purposes, show a placeholder video
    // In a real app, this would use AgoraVideoView
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Placeholder video background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.withValues(alpha: 0.3),
                  Colors.purple.withValues(alpha: 0.3),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.videocam,
                    size: 100,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Live Video Stream',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tutor: ${widget.tutorName}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Live indicator
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    color: Colors.white,
                    size: 12,
                  ),
                  SizedBox(width: 4),
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
          ),
        ],
      ),
    );
  }

  Future<void> _raiseHand() async {
    if (!_isJoined) {
      return;
    }

    // For demo purposes, simulate raising hand
    print('Hand raised for session: ${widget.sessionId}');
    
    setState(() {
      _isHandRaised = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hand raised! Waiting for tutor approval...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _lowerHand() async {
    if (!_isJoined || !_isHandRaised) return;

    // For demo purposes, simulate lowering hand
    print('Hand lowered for session: ${widget.sessionId}');
    
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

  Future<void> _joinChannel() async {
    try {
      await agora_service.AgoraService.joinChannelAsAudience(
        widget.sessionId,
        token: null,
      );
      
      setState(() {
        _isJoined = true;
        _status = 'Connected to live session';
      });
    } catch (e) {
      print('Error joining channel: $e');
      setState(() {
        _status = 'Failed to join live session';
      });
    }
  }

  Future<void> _leaveChannel() async {
    try {
      await agora_service.AgoraService.leaveChannel();
      
      setState(() {
        _isJoined = false;
        _isHandRaised = false;
        _isChatVisible = false;
        _status = 'Left live session';
      });
      
      // Clear chat messages
      _chatMessages.clear();
      _tutorQuestions.clear();
    } catch (e) {
      print('Error leaving channel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          if (_isJoined)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.grey],
                ),
              ),
              child: Stack(
                children: [
                  // Video display area
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: _buildVideoView(),
                  ),
                  
                  // Overlay with tutor info
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              'https://picsum.photos/32/32?random=${widget.sessionId.hashCode}',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.tutorName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Live Now',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Raise Hand button
                        GestureDetector(
                          onTap: _isHandRaised ? _lowerHand : _raiseHand,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isHandRaised ? Colors.blue : Colors.grey[600],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pan_tool,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        
                        // Chat button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isChatVisible = !_isChatVisible;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isChatVisible ? Colors.blue : Colors.grey[600],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        
                        // Leave button
                        GestureDetector(
                          onTap: _leaveChannel,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            // Pre-join screen
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
                    
                    // Join button
                    ElevatedButton.icon(
                      onPressed: _joinChannel,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Join Live'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
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
          
          // Chat overlay
          if (_isChatVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Chat header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isChatVisible = false;
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Chat tabs
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedChatTab = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedChatTab == 0 ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Chat with all',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedChatTab = 1;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _selectedChatTab == 1 ? Colors.blue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Ask tutor',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Chat messages
                    Expanded(
                      child: ListView.builder(
                        controller: _messageScrollController,
                        itemCount: _selectedChatTab == 0 ? _chatMessages.length : _tutorQuestions.length,
                        itemBuilder: (context, index) {
                          final message = _selectedChatTab == 0 
                              ? _chatMessages[index] 
                              : _tutorQuestions[index];
                          return _buildMessageBubble(message);
                        },
                      ),
                    ),
                    
                    // Message input
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _sendMessage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
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
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: message.isFromTutor 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: message.isFromTutor ? Colors.blue : Colors.grey[700],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!message.isFromTutor)
                  Text(
                    message.userName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  message.message,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'demo_user',
      userName: 'You',
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isFromTutor: false,
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
  }
}
