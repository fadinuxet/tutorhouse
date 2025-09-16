class AgoraConfig {
  // TODO: Replace with your actual Agora App ID
  // Get your App ID from: https://console.agora.io
  static const String appId = '31ab20b72ffb4452adeb97201bd8daa3';
  static const String token = ''; // Will be generated server-side
  
  // Agora channel configuration
  static const int uid = 0; // 0 for auto-assign
  static const String channelName = 'tutorhouse_live';
  
  // Video settings
  static const int videoWidth = 720;
  static const int videoHeight = 1280;
  static const int frameRate = 30;
  static const int bitrate = 2000;
  
  // Audio settings
  static const int sampleRate = 48000;
  static const int channels = 1;
  
  // Check if Agora is configured
  static bool get isConfigured => appId != 'YOUR_AGORA_APP_ID';
  
  // Get channel name for tutor
  static String getChannelName(String tutorId) => 'tutor_$tutorId';
  
  // Get channel name for session
  static String getSessionChannelName(String sessionId) => 'session_$sessionId';
}
