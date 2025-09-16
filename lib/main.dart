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
  print('🚀 Initializing Tutorhouse App...');
  
  try {
    // Initialize Supabase if enabled
    if (DemoConfig.useSupabase) {
      print('🔧 Initializing Supabase...');
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
      );
      print('✅ Supabase initialized');
    }
    
    // Initialize Agora if configured
    if (AgoraConfig.isConfigured) {
      print('🔧 Initializing Agora...');
      await agora_service.AgoraService.initialize();
      print('✅ Agora initialized');
    }
    
    // Initialize Payment service
    print('🔧 Initializing Payment service...');
    await PaymentService.initialize();
    print('✅ Payment service initialized');
    
    // Initialize Auth service
    print('🔧 Initializing Auth service...');
    await AuthService.initialize();
    print('✅ Auth service initialized');
    
    // Initialize Booking service
    print('🔧 Initializing Booking service...');
    await BookingService.initialize();
    print('✅ Booking service initialized');
    
    // Initialize Tutor service
    print('🔧 Initializing Tutor service...');
    // Note: TutorProvider will be initialized in the app widget
    print('✅ Tutor service ready');
    
    print('✅ App initialization completed successfully');
  } catch (e) {
    print('❌ Error during app initialization: $e');
    // Continue with app launch even if some services fail
  }
}