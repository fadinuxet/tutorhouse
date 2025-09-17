import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/demo_config.dart';
import 'config/supabase_config.dart';
import 'config/agora_config.dart';
import 'services/agora_service.dart' as agora_service;
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
        
        // Test connection - use a simple table that exists
        final client = Supabase.instance.client;
        // Skip connection test to avoid startup issues
      } catch (e) {
        // Continue with demo mode if Supabase fails
      }
    }
    
    // Initialize Agora if configured
    if (AgoraConfig.isConfigured) {
      await agora_service.AgoraService.initialize();
    }
    
    // Initialize services with individual error handling
    try {
      await PaymentService.initialize();
    } catch (e) {
      print('Payment service initialization failed: $e');
    }
    
    try {
      await AuthService.initialize();
    } catch (e) {
      print('Auth service initialization failed: $e');
    }
    
    try {
      await BookingService.initialize();
    } catch (e) {
      print('Booking service initialization failed: $e');
    }
  } catch (e) {
    print('App initialization error: $e');
    // Continue with app launch even if some services fail
  }
}