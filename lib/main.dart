import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/demo_config.dart';
import 'config/supabase_config.dart';
import 'config/agora_config.dart';
import 'services/agora_service_stub.dart' as agora_service;
import 'services/payment_service.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'providers/auth_provider.dart';
import 'providers/tutor_provider.dart';
import 'app.dart';

// Global providers
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) => AuthProvider());
final tutorProvider = ChangeNotifierProvider<TutorProvider>((ref) => TutorProvider());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the app
  await initializeApp();
  
  runApp(
    ProviderScope(
      child: TutorhouseApp(),
    ),
  );
}

/// Initialize the app with all required services
Future<void> initializeApp() async {
  
  try {
    // Initialize Supabase if enabled
    if (DemoConfig.useSupabase) {
      
      try {
        await Supabase.initialize(
          url: SupabaseConfig.supabaseUrl,
          anonKey: SupabaseConfig.supabaseAnonKey,
        );
        
        // Test connection
        final client = Supabase.instance.client;
        final response = await client.from('student_profiles').select('count').limit(1);
        
      } catch (e) {
        if (e.toString().contains('404')) {
        }
      }
    }
    
    // Initialize Agora if configured
    if (AgoraConfig.isConfigured) {
      await agora_service.AgoraService.initialize();
    }
    
    // Initialize Payment service
    await PaymentService.initialize();
    
    // Initialize Auth service
    await AuthService.initialize();
    
    // Initialize Booking service
    await BookingService.initialize();
    
    // Initialize Tutor service
    // Note: TutorProvider will be initialized in the app widget
    
  } catch (e) {
    // Continue with app launch even if some services fail
  }
}