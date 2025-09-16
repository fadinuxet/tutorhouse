class GoogleConfig {
  // ✅ Using build-time environment variables for security
  // Real credentials are passed via --dart-define flags when running the app
  static const String googleApiKey = String.fromEnvironment('GOOGLE_API_KEY', defaultValue: 'YOUR_GOOGLE_API_KEY_HERE');
  static const String googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: 'YOUR_GOOGLE_CLIENT_ID_HERE');
  static const String googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: 'YOUR_GOOGLE_WEB_CLIENT_ID_HERE');
  
  // Google Meet Configuration
  static const String googleMeetApiKey = 'YOUR_GOOGLE_MEET_API_KEY_HERE';
  
  // Google Calendar Configuration
  static const String googleCalendarApiKey = 'YOUR_GOOGLE_CALENDAR_API_KEY_HERE';
  
  // Google Drive Configuration
  static const String googleDriveApiKey = 'YOUR_GOOGLE_DRIVE_API_KEY_HERE';
}
