import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Tutorhouse';
  static const String appVersion = '1.0.0';
  
  // Colors (TikTok-inspired but educational)
  static const Color primaryColor = Color(0xFF6C5CE7); // Purple
  static const Color secondaryColor = Color(0xFF00D2FF); // Cyan
  static const Color backgroundColor = Color(0xFF000000); // Black
  static const Color surfaceColor = Color(0xFF1A1A1A); // Dark gray
  static const Color accentColor = Color(0xFFFF6B9D); // Pink
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  
  // Video Settings
  static const int maxIntroVideoDuration = 60; // seconds
  static const int maxVideoFileSize = 100; // MB
  
  // Platform Settings
  static const double platformFeePercentage = 0.15; // 15%
  static const String whiteboardBaseUrl = 'https://whiteboard.tutorhouse.co.uk';
  
  // API Endpoints
  static const String baseApiUrl = 'https://api.tutorhouse.co.uk';
  
  // Social Media
  static const String instagramUrl = 'https://instagram.com/tutorhouse';
  static const String twitterUrl = 'https://twitter.com/tutorhouse';
  static const String tiktokUrl = 'https://tiktok.com/@tutorhouse';
  
  // Support
  static const String supportEmail = 'support@tutorhouse.co.uk';
  static const String privacyPolicyUrl = 'https://tutorhouse.co.uk/privacy';
  static const String termsOfServiceUrl = 'https://tutorhouse.co.uk/terms';
}
