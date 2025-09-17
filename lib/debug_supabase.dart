import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

class SupabaseDebugger {
  static Future<void> testConnection() async {
    
    try {
      // Initialize Supabase
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      
      
      // Test a simple query
      final client = Supabase.instance.client;
      final response = await client.from('student_profiles').select('count').limit(1);
      
    } catch (e) {
    }
  }
}

