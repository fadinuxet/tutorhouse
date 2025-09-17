class SupabaseConfig {
  // ✅ Using build-time environment variables for security
  // Real credentials are passed via --dart-define flags when running the app
  static const String supabaseUrl = 'https://lpjbzkwflyidjbmdrubg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxwamJ6a3dmbHlpZGpibWRydWJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc4NzE5NzEsImV4cCI6MjA3MzQ0Nzk3MX0.7oZipOxgXpeD7FoXBT517giqfVr0akyKZdZyiQrsKdo';
  
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
