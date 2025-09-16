import 'dart:async';
import 'dart:typed_data';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../models/live_session.dart';
import '../models/user.dart' as app_user;

// Conditional imports for web compatibility
import 'package:flutter/foundation.dart' show kIsWeb;

class AgoraLiveService {
  static final AgoraLiveService _instance = AgoraLiveService._internal();
  factory AgoraLiveService() => _instance;
  AgoraLiveService._internal();

  RtcEngine? _engine;
  String? _channelId;
  String? _token;
  int? _uid;
  AgoraUserRole _userRole = AgoraUserRole.audience;
  bool _isJoined = false;
  bool _isMuted = true;
  bool _isHandRaised = false;

  // Stream controllers for real-time updates
  final StreamController<RaisedHand> _raisedHandController = StreamController<RaisedHand>.broadcast();
  final StreamController<LiveSessionMessage> _messageController = StreamController<LiveSessionMessage>.broadcast();
  final StreamController<String?> _currentSpeakerController = StreamController<String?>.broadcast();
  final StreamController<bool> _audioStatusController = StreamController<bool>.broadcast();

  // Getters for streams
  Stream<RaisedHand> get raisedHandStream => _raisedHandController.stream;
  Stream<LiveSessionMessage> get messageStream => _messageController.stream;
  Stream<String?> get currentSpeakerStream => _currentSpeakerController.stream;
  Stream<bool> get audioStatusStream => _audioStatusController.stream;

  // Getters for current state
  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isHandRaised => _isHandRaised;
  AgoraUserRole get userRole => _userRole;

  Future<void> initialize() async {
    if (_engine != null) return;
    
    // Skip Agora initialization on web for now
    if (kIsWeb) {
      print('Agora initialization skipped on web');
      return;
    }

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: '31ab20b72ffb4452adeb97201bd8daa3', // Your Agora App ID
    ));

    // Set up event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Successfully joined channel: ${connection.channelId}');
          _isJoined = true;
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('User $remoteUid joined the channel');
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print('User $remoteUid left the channel');
        },
        onError: (ErrorCodeType err, String msg) {
          print('Agora error: $err - $msg');
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          print('Token will expire, need to refresh');
          // TODO: Implement token refresh
        },
        onStreamMessage: (RtcConnection connection, int remoteUid, int streamId, Uint8List data, int length, int sentTs) {
          _handleStreamMessage(String.fromCharCodes(data));
        },
      ),
    );

    // Enable audio
    await _engine!.enableAudio();
    await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);
  }

  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required AgoraUserRole role,
    required app_user.User user,
  }) async {
    if (kIsWeb) {
      print('Agora joinChannel skipped on web');
      return;
    }
    
    if (_engine == null) {
      await initialize();
    }

    _channelId = channelId;
    _token = token;
    _uid = uid;
    _userRole = role;

    // Set client role based on user role
    ClientRoleType clientRole;
    switch (role) {
      case AgoraUserRole.broadcaster:
        clientRole = ClientRoleType.clientRoleBroadcaster;
        break;
      case AgoraUserRole.audience:
      case AgoraUserRole.speaker:
        clientRole = ClientRoleType.clientRoleAudience;
        break;
    }

    await _engine!.setClientRole(role: clientRole);
    await _engine!.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleAudience,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    // Mute audio by default for audience members
    if (role == AgoraUserRole.audience) {
      await muteAudio(true);
    }
  }

  Future<void> leaveChannel() async {
    if (kIsWeb) return;
    
    if (_engine != null && _isJoined) {
      await _engine!.leaveChannel();
      _isJoined = false;
      _isMuted = true;
      _isHandRaised = false;
      _channelId = null;
      _token = null;
      _uid = null;
    }
  }

  Future<void> muteAudio(bool muted) async {
    if (_engine != null) {
      await _engine!.muteLocalAudioStream(muted);
      _isMuted = muted;
      _audioStatusController.add(muted);
    }
  }

  Future<void> muteVideo(bool muted) async {
    if (_engine != null) {
      await _engine!.muteLocalVideoStream(muted);
    }
  }

  // Raise hand functionality
  Future<void> raiseHand(app_user.User user) async {
    if (_userRole != AgoraUserRole.audience || _isHandRaised) return;

    _isHandRaised = true;
    
    final raisedHand = RaisedHand(
      userId: user.id,
      userName: user.fullName,
      userAvatar: '', // TODO: Get from user profile
      raisedAt: DateTime.now(),
    );

    // Send raise hand message to channel
    await _sendStreamMessage('RAISE_HAND:${user.id}:${user.fullName}');
    
    // Add to local raised hands
    _raisedHandController.add(raisedHand);
  }

  Future<void> lowerHand() async {
    if (!_isHandRaised) return;

    _isHandRaised = false;
    await _sendStreamMessage('LOWER_HAND:${_uid}');
  }

  // Tutor functions
  Future<void> approveSpeaker(String userId, String userName) async {
    if (_userRole != AgoraUserRole.broadcaster) return;

    // Send approval message to specific user
    await _sendStreamMessage('APPROVE_SPEAKER:$userId', targetUid: int.parse(userId));
    
    // Update current speaker
    _currentSpeakerController.add(userId);
    
    // Send system message
    _messageController.add(LiveSessionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'system',
      userName: 'System',
      message: '$userName can now speak',
      type: MessageType.system,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> muteSpeaker(String userId, String userName) async {
    if (_userRole != AgoraUserRole.broadcaster) return;

    await _sendStreamMessage('MUTE_SPEAKER:$userId', targetUid: int.parse(userId));
    
    // Send system message
    _messageController.add(LiveSessionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'system',
      userName: 'System',
      message: '$userName has been muted',
      type: MessageType.system,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> removeSpeaker(String userId, String userName) async {
    if (_userRole != AgoraUserRole.broadcaster) return;

    await _sendStreamMessage('REMOVE_SPEAKER:$userId', targetUid: int.parse(userId));
    
    // Clear current speaker if it's the removed user
    if (_currentSpeakerController.hasListener) {
      _currentSpeakerController.add(null);
    }
    
    // Send system message
    _messageController.add(LiveSessionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'system',
      userName: 'System',
      message: '$userName has been removed from speaking',
      type: MessageType.system,
      timestamp: DateTime.now(),
    ));
  }

  // Send chat message
  Future<void> sendChatMessage(String message, app_user.User user) async {
    if (kIsWeb) return;
    await _sendStreamMessage('CHAT:${user.id}:${user.fullName}:$message');
  }

  // Private methods
  Future<void> _sendStreamMessage(String message, {int? targetUid}) async {
    if (kIsWeb) return;
    
    if (_engine != null && _isJoined) {
      final data = Uint8List.fromList(message.codeUnits);
      await _engine!.sendStreamMessage(
        streamId: 1,
        data: data,
        length: data.length,
      );
    }
  }

  void _handleStreamMessage(String message) {
    final parts = message.split(':');
    if (parts.isEmpty) return;

    switch (parts[0]) {
      case 'RAISE_HAND':
        if (parts.length >= 3) {
          final raisedHand = RaisedHand(
            userId: parts[1],
            userName: parts[2],
            userAvatar: '',
            raisedAt: DateTime.now(),
          );
          _raisedHandController.add(raisedHand);
        }
        break;
        
      case 'LOWER_HAND':
        // Handle hand lowering
        break;
        
      case 'APPROVE_SPEAKER':
        if (parts.length >= 2 && parts[1] == _uid.toString()) {
          // This user was approved to speak
          _userRole = AgoraUserRole.speaker;
          muteAudio(false); // Unmute audio
          _messageController.add(LiveSessionMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'system',
            userName: 'System',
            message: 'You can now speak!',
            type: MessageType.audioApproved,
            timestamp: DateTime.now(),
          ));
        }
        break;
        
      case 'MUTE_SPEAKER':
        if (parts.length >= 2 && parts[1] == _uid.toString()) {
          // This user was muted
          muteAudio(true);
          _messageController.add(LiveSessionMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'system',
            userName: 'System',
            message: 'You have been muted',
            type: MessageType.audioRevoked,
            timestamp: DateTime.now(),
          ));
        }
        break;
        
      case 'REMOVE_SPEAKER':
        if (parts.length >= 2 && parts[1] == _uid.toString()) {
          // This user was removed from speaking
          _userRole = AgoraUserRole.audience;
          muteAudio(true);
          _isHandRaised = false;
          _messageController.add(LiveSessionMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'system',
            userName: 'System',
            message: 'You can no longer speak',
            type: MessageType.audioRevoked,
            timestamp: DateTime.now(),
          ));
        }
        break;
        
      case 'CHAT':
        if (parts.length >= 4) {
          _messageController.add(LiveSessionMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: parts[1],
            userName: parts[2],
            message: parts.sublist(3).join(':'),
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
    _engine?.release();
    _engine = null;
  }
}
