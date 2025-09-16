import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../config/agora_config.dart';

/// Web-compatible version of AgoraService
/// This version provides placeholder functionality for web platform
class AgoraService {
  static bool _isInitialized = false;
  static bool _isJoined = false;
  static String? _currentChannel;
  static int? _currentUid;
  
  // Event streams
  static final StreamController<bool> _connectionStateController = StreamController<bool>.broadcast();
  static final StreamController<int> _userJoinedController = StreamController<int>.broadcast();
  static final StreamController<int> _userOfflineController = StreamController<int>.broadcast();
  
  // Getters
  static bool get isInitialized => _isInitialized;
  static bool get isJoined => _isJoined;
  static String? get currentChannel => _currentChannel;
  static int? get currentUid => _currentUid;
  
  // Streams
  static Stream<bool> get connectionStateStream => _connectionStateController.stream;
  static Stream<int> get userJoinedStream => _userJoinedController.stream;
  static Stream<int> get userOfflineStream => _userOfflineController.stream;

  /// Initialize Agora RTC Engine (Web placeholder)
  static Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    print('Agora initialization skipped on web platform');
    _isInitialized = true;
    return true;
  }

  /// Join a channel as broadcaster (Web placeholder)
  static Future<bool> joinChannelAsBroadcaster(String channelName, {String? token}) async {
    print('Live streaming not supported on web platform');
    return false;
  }

  /// Join a channel as audience (Web placeholder)
  static Future<bool> joinChannelAsAudience(String channelName, {String? token}) async {
    print('Live streaming not supported on web platform');
    return false;
  }

  /// Leave the current channel (Web placeholder)
  static Future<bool> leaveChannel() async {
    if (!_isJoined) return false;
    
    _isJoined = false;
    _currentChannel = null;
    _currentUid = null;
    print('Left channel (web placeholder)');
    return true;
  }

  /// Start local video preview (Web placeholder)
  static Future<void> startPreview() async {
    print('Video preview not supported on web platform');
  }

  /// Stop local video preview (Web placeholder)
  static Future<void> stopPreview() async {
    print('Video preview not supported on web platform');
  }

  /// Enable/disable local video (Web placeholder)
  static Future<void> enableLocalVideo(bool enabled) async {
    print('Video controls not supported on web platform');
  }

  /// Enable/disable local audio (Web placeholder)
  static Future<void> enableLocalAudio(bool enabled) async {
    print('Audio controls not supported on web platform');
  }

  /// Mute/unmute local audio (Web placeholder)
  static Future<void> muteLocalAudioStream(bool muted) async {
    print('Audio controls not supported on web platform');
  }

  /// Switch camera (Web placeholder)
  static Future<void> switchCamera() async {
    print('Camera controls not supported on web platform');
  }

  /// Get video view widget for local video (Web placeholder)
  static Widget? getLocalVideoView() {
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

  /// Get video view widget for remote video (Web placeholder)
  static Widget? getRemoteVideoView(int uid) {
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

  /// Dispose resources (Web placeholder)
  static Future<void> dispose() async {
    await _connectionStateController.close();
    await _userJoinedController.close();
    await _userOfflineController.close();
    
    print('Agora service disposed (web)');
  }
}
