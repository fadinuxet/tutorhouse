class DemoConfig {
  // Demo mode - bypasses real authentication for easy testing
  static const bool isDemoMode = true;
  
  // Demo user credentials
  static const String demoEmail = 'demo@tutorhouse.com';
  static const String demoPassword = 'demo123';
  static const String demoName = 'Demo Student';
  
  // Demo settings
  static const bool skipAuthentication = false; // Changed to show auth screen
  static const bool useSampleData = true;
  
  // Supabase integration
  static const bool useSupabase = true; // Fixed URL typo - now working
  static const bool enableRealFileUpload = true; // Set to true when Supabase is ready
}
