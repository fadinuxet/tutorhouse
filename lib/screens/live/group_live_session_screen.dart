import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/agora_service_stub.dart' as agora_service;
import '../../models/tutor_profile.dart';

class GroupLiveSessionScreen extends StatefulWidget {
  final TutorProfile tutor;
  final String subject;

  const GroupLiveSessionScreen({
    super.key,
    required this.tutor,
    required this.subject,
  });

  @override
  State<GroupLiveSessionScreen> createState() => _GroupLiveSessionScreenState();
}

class _GroupLiveSessionScreenState extends State<GroupLiveSessionScreen> {
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  int _viewerCount = 0;
  List<String> _questions = [];
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _chatController = ScrollController();

  @override
  void initState() {
    super.initState();
    _joinGroupSession();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _chatController.dispose();
    _leaveGroupSession();
    super.dispose();
  }

  Future<void> _joinGroupSession() async {
    // Simulate joining group session
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isJoined = true;
      _viewerCount = 127; // Mock viewer count
    });
  }

  Future<void> _leaveGroupSession() async {
    if (_isJoined) {
      setState(() {
        _isJoined = false;
      });
    }
  }

  void _submitQuestion() {
    if (_questionController.text.trim().isNotEmpty) {
      setState(() {
        _questions.add(_questionController.text.trim());
      });
      _questionController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatController.hasClients) {
        _chatController.animateTo(
          _chatController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live video stream
          if (_isJoined)
            Center(
              child: agora_service.AgoraService.getRemoteVideoView(0) ??
                Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Text(
                      'Live Group Session\n(Web not supported)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: AppConstants.primaryColor),
            ),

          // Top overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 16,
                right: 16,
                bottom: 16,
              ),
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
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Tutor info
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
                          '${widget.subject} • Group Q&A',
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
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

          // Bottom Q&A panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Q&A header
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.quiz,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Q&A Session',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_questions.length} questions',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Questions list
                  Expanded(
                    child: ListView.builder(
                      controller: _chatController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _questions[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Question input
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _questionController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ask a question...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _submitQuestion(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _submitQuestion,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor,
                              borderRadius: BorderRadius.circular(25),
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

          // Right side controls
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.4 + 16,
            child: Column(
              children: [
                // Mute button
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  onTap: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Video button
                _buildControlButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  onTap: () {
                    setState(() {
                      _isVideoEnabled = !_isVideoEnabled;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Book 1-to-1 button
                _buildControlButton(
                  icon: Icons.calendar_today,
                  backgroundColor: AppConstants.primaryColor,
                  onTap: () {
                    // TODO: Navigate to booking screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Book 1-to-1 session'),
                        backgroundColor: AppConstants.primaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
