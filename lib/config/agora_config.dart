class AgoraConfig {
  // ✅ Using build-time environment variables for security
  // Real credentials are passed via --dart-define flags when running the app
  static const String appId = String.fromEnvironment('AGORA_APP_ID', defaultValue: 'YOUR_AGORA_APP_ID_HERE');
  static const String appCertificate = String.fromEnvironment('AGORA_APP_CERTIFICATE', defaultValue: 'YOUR_AGORA_APP_CERTIFICATE_HERE');
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
  static bool get isConfigured => appId != 'YOUR_AGORA_APP_ID_HERE';
  
  // Get channel name for tutor
  static String getChannelName(String tutorId) => 'tutor_$tutorId';
  
  // Get channel name for session
  static String getSessionChannelName(String sessionId) => 'session_$sessionId';
}
