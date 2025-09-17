import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/constants.dart';
import 'screens/auth/mobile_auth_screen.dart';
import 'screens/feed/video_feed_screen.dart';
import 'providers/auth_provider.dart';
import 'main.dart';

class TutorhouseApp extends ConsumerStatefulWidget {
  const TutorhouseApp({super.key});

  @override
  ConsumerState<TutorhouseApp> createState() => _TutorhouseAppState();
}

class _TutorhouseAppState extends ConsumerState<TutorhouseApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      await ref.read(authProvider).initialize();
    } catch (e) {
      print('❌ TutorhouseApp: Error initializing services: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        primaryColor: AppConstants.primaryColor,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: AppConstants.textPrimary,
            displayColor: AppConstants.textPrimary,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.backgroundColor,
          foregroundColor: AppConstants.textPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: AppConstants.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppConstants.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppConstants.primaryColor),
          ),
          labelStyle: const TextStyle(color: AppConstants.textSecondary),
          hintStyle: const TextStyle(color: AppConstants.textSecondary),
        ),
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
          surface: AppConstants.surfaceColor,
          onPrimary: AppConstants.textPrimary,
          onSecondary: AppConstants.textPrimary,
          onSurface: AppConstants.textPrimary,
        ),
      ),
      home: _buildHome(authState),
      routes: {
        '/auth': (context) => const MobileAuthScreen(showSignUp: true),
        '/home': (context) => const VideoFeedScreen(),
      },
    );
  }

  Widget _buildHome(AuthProvider authState) {
    // Show loading screen while initializing
    if (!_isInitialized || authState.isLoading) {
      return const Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                'Initializing...',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error screen if there's an error
    if (authState.error != null) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: ${authState.error}',
                style: const TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitialized = false;
                  });
                  _initializeAuth();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Always show video feed first - users can sign in optionally
    return const VideoFeedScreen();
  }
}
