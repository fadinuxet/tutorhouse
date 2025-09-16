class SupabaseConfig {
  // ⚠️ SECURITY WARNING: Replace with your actual Supabase project details
  // These are DEMO credentials - DO NOT use in production!
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
  
  // Storage bucket names
  static const String tutorVideosBucket = 'tutor-videos';
  static const String documentsBucket = 'documents';
  static const String profilePicsBucket = 'profile-pics';
  
  // Database table names
  static const String tutorsTable = 'tutor_profiles';
  static const String studentsTable = 'student_profiles';
  static const String bookingsTable = 'bookings';
  static const String reviewsTable = 'reviews';
  static const String liveStreamsTable = 'live_streams';
  static const String videoContentTable = 'video_content';
  static const String chatMessagesTable = 'stream_chat';
  static const String followsTable = 'follows';
}