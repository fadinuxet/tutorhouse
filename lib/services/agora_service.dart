import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/agora_config.dart';

class AgoraService {
  static RtcEngine? _engine;
  static bool _isInitialized = false;
  static bool _isJoined = false;
  static String? _currentChannel;
  static int? _currentUid;
  
  // Event streams
  static final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  static final StreamController<int> _userJoinedController = StreamController<int>.broadcast();
  static final StreamController<int> _userOfflineController = StreamController<int>.broadcast();
  static final StreamController<RtcStats> _rtcStatsController = StreamController<RtcStats>.broadcast();
  
  // Getters
  static bool get isInitialized => _isInitialized;
  static bool get isJoined => _isJoined;
  static String? get currentChannel => _currentChannel;
  static int? get currentUid => _currentUid;
  
  // Streams
  static Stream<bool> get connectionStateStream => _connectionStateController.stream;
  static Stream<int> get userJoinedStream => _userJoinedController.stream;
  static Stream<int> get userOfflineStream => _userOfflineController.stream;
  static Stream<RtcStats> get rtcStatsStream => _rtcStatsController.stream;

  /// Initialize Agora RTC Engine
  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Check if Agora is configured
      if (!AgoraConfig.isConfigured) {
        print('Agora not configured. Please add your App ID to AgoraConfig.');
        return false;
      }
      
      // Skip initialization on web for now due to platformViewRegistry issue
      if (kIsWeb) {
        print('Agora initialization skipped on web platform due to compatibility issues');
        _isInitialized = true;
        return true;
      }
      
      // Request permissions
      await _requestPermissions();
      
      // Create RTC Engine instance
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: AgoraConfig.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));
      
      // Set up event handlers
      _setupEventHandlers();
      
      // Enable video
      await _engine!.enableVideo();
      
      // Set video encoder configuration
      await _engine!.setVideoEncoderConfiguration(const VideoEncoderConfiguration(
        dimensions: VideoDimensions(
          width: AgoraConfig.videoWidth,
          height: AgoraConfig.videoHeight,
        ),
        frameRate: AgoraConfig.frameRate,
        bitrate: AgoraConfig.bitrate,
        orientationMode: OrientationMode.orientationModeFixedPortrait,
      ));
      
      _isInitialized = true;
      print('Agora RTC Engine initialized successfully');
      return true;
    } catch (e) {
      print('Failed to initialize Agora RTC Engine: $e');
      return false;
    }
  }

  /// Join a channel as broadcaster (tutor)
  static Future<bool> joinChannelAsBroadcaster(String channelName, {String? token}) async {
    if (!_isInitialized || _isJoined) return false;
    
    // Skip on web platform
    if (kIsWeb) {
      print('Live streaming not supported on web platform');
      return false;
    }
    
    try {
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      
      await _engine!.joinChannel(
        token: token ?? AgoraConfig.token,
        channelId: channelName,
        uid: AgoraConfig.uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
      
      _currentChannel = channelName;
      _isJoined = true;
      print('Joined channel as broadcaster: $channelName');
      return true;
    } catch (e) {
      print('Failed to join channel as broadcaster: $e');
      return false;
    }
  }

  /// Join a channel as audience (student)
  static Future<bool> joinChannelAsAudience(String channelName, {String? token}) async {
    if (!_isInitialized || _isJoined) return false;
    
    // Skip on web platform
    if (kIsWeb) {
      print('Live streaming not supported on web platform');
      return false;
    }
    
    try {
      await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);
      
      await _engine!.joinChannel(
        token: token ?? AgoraConfig.token,
        channelId: channelName,
        uid: AgoraConfig.uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );
      
      _currentChannel = channelName;
      _isJoined = true;
      print('Joined channel as audience: $channelName');
      return true;
    } catch (e) {
      print('Failed to join channel as audience: $e');
      return false;
    }
  }

  /// Leave the current channel
  static Future<bool> leaveChannel() async {
    if (!_isJoined) return false;
    
    try {
      await _engine!.leaveChannel();
      _isJoined = false;
      _currentChannel = null;
      _currentUid = null;
      print('Left channel successfully');
      return true;
    } catch (e) {
      print('Failed to leave channel: $e');
      return false;
    }
  }

  /// Start local video preview
  static Future<void> startPreview() async {
    if (!_isInitialized) return;
    await _engine!.startPreview();
  }

  /// Stop local video preview
  static Future<void> stopPreview() async {
    if (!_isInitialized) return;
    await _engine!.stopPreview();
  }

  /// Enable/disable local video
  static Future<void> enableLocalVideo(bool enabled) async {
    if (!_isInitialized) return;
    await _engine!.enableLocalVideo(enabled);
  }

  /// Enable/disable local audio
  static Future<void> enableLocalAudio(bool enabled) async {
    if (!_isInitialized) return;
    await _engine!.enableLocalAudio(enabled);
  }

  /// Mute/unmute local audio
  static Future<void> muteLocalAudioStream(bool muted) async {
    if (!_isInitialized) return;
    await _engine!.muteLocalAudioStream(muted);
  }

  /// Switch camera
  static Future<void> switchCamera() async {
    if (!_isInitialized) return;
    await _engine!.switchCamera();
  }

  /// Get video view widget for local video
  static Widget? getLocalVideoView() {
    if (!_isInitialized) return null;
    
    // Return placeholder for web platform
    if (kIsWeb) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Live Video Preview\n(Web not supported)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  /// Get video view widget for remote video
  static Widget? getRemoteVideoView(int uid) {
    if (!_isInitialized) return null;
    
    // Return placeholder for web platform
    if (kIsWeb) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Live Stream\n(Web not supported)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: uid),
        connection: RtcConnection(channelId: _currentChannel),
      ),
    );
  }

  /// Set up event handlers
  static void _setupEventHandlers() {
    if (_engine == null) return;
    
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          _currentUid = connection.localUid;
          _connectionStateController.add(true);
          print('Successfully joined channel: ${connection.channelId}');
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          _connectionStateController.add(false);
          print('Left channel: ${connection.channelId}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          _userJoinedController.add(remoteUid);
          print('User joined: $remoteUid');
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          _userOfflineController.add(remoteUid);
          print('User offline: $remoteUid, reason: $reason');
        },
        onRtcStats: (RtcConnection connection, RtcStats stats) {
          _rtcStatsController.add(stats);
        },
        onError: (ErrorCodeType err, String msg) {
          print('Agora error: $err - $msg');
        },
        onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
          print('Connection state changed: $state, reason: $reason');
        },
      ),
    );
  }

  /// Request necessary permissions
  static Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  /// Dispose resources
  static Future<void> dispose() async {
    if (_isJoined) {
      await leaveChannel();
    }
    
    if (_isInitialized) {
      await _engine?.release();
      _isInitialized = false;
    }
    
    await _connectionStateController.close();
    await _userJoinedController.close();
    await _userOfflineController.close();
    await _rtcStatsController.close();
    
    print('Agora service disposed');
  }
}
