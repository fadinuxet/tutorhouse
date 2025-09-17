import 'dart:async';
import '../models/live_session.dart';
import '../models/user.dart' as app_user;

class AgoraLiveService {
  static final AgoraLiveService _instance = AgoraLiveService._internal();
  factory AgoraLiveService() => _instance;
  AgoraLiveService._internal();

  // Stream controllers for real-time updates
  final StreamController<RaisedHand> _raisedHandController = StreamController<RaisedHand>.broadcast();
  final StreamController<LiveSessionMessage> _messageController = StreamController<LiveSessionMessage>.broadcast();
  final StreamController<String?> _currentSpeakerController = StreamController<String?>.broadcast();
  final StreamController<bool> _audioStatusController = StreamController<bool>.broadcast();

  // Streams
  Stream<RaisedHand> get raisedHandStream => _raisedHandController.stream;
  Stream<LiveSessionMessage> get messageStream => _messageController.stream;
  Stream<String?> get currentSpeakerStream => _currentSpeakerController.stream;
  Stream<bool> get audioStatusStream => _audioStatusController.stream;

  // State variables
  bool _isJoined = false;
  bool _isMuted = true;
  bool _isHandRaised = false;
  String _userRole = 'audience';
  String? _channelId;
  String? _token;
  int? _uid;

  // Getters for current state
  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isHandRaised => _isHandRaised;
  String get userRole => _userRole;

  Future<void> initialize() async {
    print('Agora service initialized (demo mode)');
  }

  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required String role,
    required app_user.User user,
  }) async {
    print('Demo mode: Joining channel $channelId as $role');
    _channelId = channelId;
    _token = token;
    _uid = uid;
    _userRole = role;
    _isJoined = true;
  }

  Future<void> leaveChannel() async {
    print('Demo mode: Leaving channel');
    _isJoined = false;
    _isHandRaised = false;
  }

  Future<void> muteAudio(bool muted) async {
    print('Demo mode: Audio ${muted ? 'muted' : 'unmuted'}');
    _isMuted = muted;
  }

  Future<void> muteVideo(bool muted) async {
    print('Demo mode: Video ${muted ? 'muted' : 'unmuted'}');
  }

  // Raise hand functionality
  Future<void> raiseHand(app_user.User user) async {
    if (_userRole != 'audience' || _isHandRaised) return;

    _isHandRaised = true;
    
    final raisedHand = RaisedHand(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: _channelId ?? 'demo_session',
      userId: user.id,
      userName: user.fullName,
      userAvatar: '', // TODO: Get from user profile
      raisedAt: DateTime.now(),
    );

    // Send raise hand message to channel
    await _sendStreamMessage('RAISE_HAND:${user.id}:${user.fullName}');
    
    // Add to local raised hands
    _raisedHandController.add(raisedHand);
    
    print('Demo mode: Hand raised by ${user.fullName}');
  }

  Future<void> lowerHand(app_user.User user) async {
    if (!_isHandRaised) return;

    _isHandRaised = false;
    
    // Send lower hand message to channel
    await _sendStreamMessage('LOWER_HAND:${user.id}');
    
    print('Demo mode: Hand lowered by ${user.fullName}');
  }

  // Speaker management (for tutors)
  Future<void> approveSpeaker(app_user.User user) async {
    print('Demo mode: Approving speaker ${user.fullName}');
    
    // Send approval message
    await _sendStreamMessage('APPROVE_SPEAKER:${user.id}');
    
    // Add system message
    _messageController.add(LiveSessionMessage(
      sessionId: _channelId ?? 'demo_session',
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'system',
      userName: 'System',
      message: '${user.fullName} can now speak!',
      type: MessageType.system,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> removeSpeaker(app_user.User user) async {
    print('Demo mode: Removing speaker ${user.fullName}');
    
    // Send removal message
    await _sendStreamMessage('REMOVE_SPEAKER:${user.id}');
    
    // Add system message
    _messageController.add(LiveSessionMessage(
      sessionId: _channelId ?? 'demo_session',
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'system',
      userName: 'System',
      message: '${user.fullName} has been removed from speaking',
      type: MessageType.system,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> muteSpeaker(app_user.User user, String reason) async {
    print('Demo mode: Muting speaker ${user.fullName} - $reason');
    
    // Send mute message
    await _sendStreamMessage('MUTE_SPEAKER:${user.id}:$reason');
    
    // Add system message
    _messageController.add(LiveSessionMessage(
      sessionId: _channelId ?? 'demo_session',
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'system',
      userName: 'System',
      message: '${user.fullName} has been muted - $reason',
      type: MessageType.system,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> stopSpeaker(app_user.User user) async {
    print('Demo mode: Stopping speaker ${user.fullName}');
    
    // Send stop message
    await _sendStreamMessage('STOP_SPEAKER:${user.id}');
    
    // Add system message
    _messageController.add(LiveSessionMessage(
      sessionId: _channelId ?? 'demo_session',
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'system',
      userName: 'System',
      message: '${user.fullName} has been stopped from speaking',
      type: MessageType.system,
      timestamp: DateTime.now(),
    ));
  }

  // Send message to channel
  Future<void> _sendStreamMessage(String message) async {
    // In demo mode, just simulate sending
    print('Demo mode: Sending message - $message');
    
    // Simulate receiving the message
    _handleStreamMessage(message);
  }

  // Handle incoming stream messages
  void _handleStreamMessage(String message) {
    final parts = message.split(':');
    if (parts.isEmpty) return;

    switch (parts[0]) {
      case 'RAISE_HAND':
        if (parts.length >= 3) {
          final raisedHand = RaisedHand(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            sessionId: _channelId ?? 'demo_session',
            userId: parts[1],
            userName: parts[2],
            userAvatar: '',
            raisedAt: DateTime.now(),
          );
          _raisedHandController.add(raisedHand);
        }
        break;
        
      case 'LOWER_HAND':
        if (parts.length >= 2) {
          // Remove from raised hands (simplified)
          print('Demo mode: Hand lowered by ${parts[1]}');
        }
        break;
        
      case 'APPROVE_SPEAKER':
        if (parts.length >= 2 && parts[1] == _uid.toString()) {
          // This user was approved to speak
          _userRole = 'speaker';
          muteAudio(false); // Unmute audio
          _messageController.add(LiveSessionMessage(
            sessionId: _channelId ?? 'demo_session',
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'system',
            userName: 'System',
            message: 'You can now speak!',
            type: MessageType.system,
            timestamp: DateTime.now(),
          ));
        }
        break;
        
      case 'REMOVE_SPEAKER':
        if (parts.length >= 2 && parts[1] == _uid.toString()) {
          // This user was removed from speaking
          _userRole = 'audience';
          muteAudio(true);
          _isHandRaised = false;
          _messageController.add(LiveSessionMessage(
            sessionId: _channelId ?? 'demo_session',
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'system',
            userName: 'System',
            message: 'You have been removed from speaking',
            type: MessageType.system,
            timestamp: DateTime.now(),
          ));
        }
        break;
        
      case 'MUTE_SPEAKER':
        if (parts.length >= 3 && parts[1] == _uid.toString()) {
          // This user was muted
          muteAudio(true);
          _messageController.add(LiveSessionMessage(
            sessionId: _channelId ?? 'demo_session',
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'system',
            userName: 'System',
            message: 'You have been muted - ${parts[2]}',
            type: MessageType.system,
            timestamp: DateTime.now(),
          ));
        }
        break;
        
      case 'STOP_SPEAKER':
        if (parts.length >= 2 && parts[1] == _uid.toString()) {
          // This user was stopped from speaking
          _userRole = 'audience';
          muteAudio(true);
          _isHandRaised = false;
          _messageController.add(LiveSessionMessage(
            sessionId: _channelId ?? 'demo_session',
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'system',
            userName: 'System',
            message: 'You have been stopped from speaking',
            type: MessageType.system,
            timestamp: DateTime.now(),
          ));
        }
        break;
        
      case 'MESSAGE':
        if (parts.length >= 4) {
          _messageController.add(LiveSessionMessage(
            sessionId: _channelId ?? 'demo_session',
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: parts[1],
            userName: parts[2],
            message: parts[3],
            type: MessageType.text,
            timestamp: DateTime.now(),
          ));
        }
        break;
    }
  }

  void dispose() {
    _raisedHandController.close();
    _messageController.close();
    _currentSpeakerController.close();
    _audioStatusController.close();
  }
}
