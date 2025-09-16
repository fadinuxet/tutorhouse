import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

class SupabaseDebugger {
  static Future<void> testConnection() async {
    print('🔍 Testing Supabase connection...');
    print('URL: ${SupabaseConfig.supabaseUrl}');
    print('Anon Key: ${SupabaseConfig.supabaseAnonKey.substring(0, 20)}...');
    
    try {
      // Initialize Supabase
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      
      print('✅ Supabase initialized successfully');
      
      // Test a simple query
      final client = Supabase.instance.client;
      final response = await client.from('student_profiles').select('count').limit(1);
      print('✅ Database connection successful');
      
    } catch (e) {
      print('❌ Supabase connection failed: $e');
    }
  }
}
