import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleConfig {
  // ✅ Using environment variables for security
  // Real credentials are loaded from .env file
  static String get googleApiKey => dotenv.env['GOOGLE_API_KEY'] ?? 'YOUR_GOOGLE_API_KEY_HERE';
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? 'YOUR_GOOGLE_CLIENT_ID_HERE';
  static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? 'YOUR_GOOGLE_WEB_CLIENT_ID_HERE';
  
  // Google Meet Configuration
  static const String googleMeetApiKey = 'YOUR_GOOGLE_MEET_API_KEY_HERE';
  
  // Google Calendar Configuration
  static const String googleCalendarApiKey = 'YOUR_GOOGLE_CALENDAR_API_KEY_HERE';
  
  // Google Drive Configuration
  static const String googleDriveApiKey = 'YOUR_GOOGLE_DRIVE_API_KEY_HERE';
}
