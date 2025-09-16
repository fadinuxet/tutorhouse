import '../models/user.dart' as app_user;
import '../config/demo_config.dart';
import 'supabase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  // Demo mode - no real authentication
  static app_user.User? _currentUser;
  static String? _authToken;
  static DateTime? _tokenExpiry;
  static bool _isInitialized = false;
  
  // Get current user
  static app_user.User? get currentUser => _currentUser;
  static String? get authToken => _authToken;
  static DateTime? get tokenExpiry => _tokenExpiry;

  // Check if user is authenticated and token is valid
  static bool get isAuthenticated => _currentUser != null && _isTokenValid();
  
  // Check if token is valid (not expired)
  static bool _isTokenValid() {
    if (_authToken == null || _tokenExpiry == null) return false;
    return DateTime.now().isBefore(_tokenExpiry!);
  }
  
  // Generate a demo JWT token (in production, this would come from your backend)
  static String _generateDemoToken() {
    final now = DateTime.now();
    final expiry = now.add(const Duration(hours: 24)); // 24 hour expiry
    
    // Simple demo token structure (in production, use proper JWT library)
    final tokenData = {
      'sub': _currentUser?.id ?? 'demo_user',
      'email': _currentUser?.email ?? 'demo@tutorhouse.com',
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiry.millisecondsSinceEpoch ~/ 1000,
      'userType': _currentUser?.userType.toString() ?? 'UserType.student',
    };
    
    return base64Encode(utf8.encode(jsonEncode(tokenData)));
  }
  
  // Initialize AuthService and load saved user
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ AuthService already initialized');
      return;
    }
    
    print('🚀 AuthService.initialize() called');
    
    try {
      await _loadUserFromStorage();
      _isInitialized = true;
      print('✅ AuthService initialized successfully - isAuthenticated: $isAuthenticated');
    } catch (e) {
      print('❌ Error initializing AuthService: $e');
    }
  }
  
  // Save user and token to SharedPreferences and localStorage
  static Future<void> _saveUserToStorage(app_user.User user) async {
    try {
      print('💾 AuthService._saveUserToStorage - Starting...');
      
      // Generate JWT token
      _authToken = _generateDemoToken();
      _tokenExpiry = DateTime.now().add(const Duration(hours: 24));
      
      final userData = {
        'id': user.id,
        'email': user.email,
        'fullName': user.fullName,
        'userType': user.userType.toString(),
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt.toIso8601String(),
        'authToken': _authToken,
        'tokenExpiry': _tokenExpiry!.toIso8601String(),
      };
      print('💾 User data prepared: $userData');
      
      final userJson = jsonEncode(userData);
      print('💾 JSON encoded: $userJson');
      
      // Try SharedPreferences first
      try {
        final prefs = await SharedPreferences.getInstance();
        print('💾 SharedPreferences instance obtained');
        
        final success = await prefs.setString('current_user', userJson);
        print('💾 SharedPreferences.setString result: $success');
        
        // Verify the save by reading it back
        final savedData = prefs.getString('current_user');
        print('💾 SharedPreferences verification - saved data: $savedData');
      } catch (e) {
        print('❌ SharedPreferences error: $e');
      }
      
      // Also save to localStorage as backup
      try {
        html.window.localStorage['current_user'] = userJson;
        print('💾 localStorage backup saved');
        
        // Verify localStorage
        final localStorageData = html.window.localStorage['current_user'];
        print('💾 localStorage verification - saved data: $localStorageData');
      } catch (e) {
        print('❌ localStorage error: $e');
      }
      
      print('💾 User and token saved to storage: ${user.email}');
    } catch (e) {
      print('❌ Error saving user to storage: $e');
      print('❌ Error details: ${e.toString()}');
    }
  }
  
  // Load user and token from SharedPreferences and localStorage
  static Future<void> _loadUserFromStorage() async {
    try {
      print('🔍 AuthService._loadUserFromStorage - Starting...');
      
      String? userJson;
      
      // Try SharedPreferences first
      try {
        final prefs = await SharedPreferences.getInstance();
        print('🔍 SharedPreferences instance obtained');
        
        // Try to get all keys to debug
        final keys = prefs.getKeys();
        print('🔍 Available keys in SharedPreferences: $keys');
        
        userJson = prefs.getString('current_user');
        print('🔍 SharedPreferences userJson: $userJson');
      } catch (e) {
        print('❌ SharedPreferences error: $e');
      }
      
      // If SharedPreferences failed or returned null, try localStorage
      if (userJson == null || userJson.isEmpty) {
        try {
          userJson = html.window.localStorage['current_user'];
          print('🔍 localStorage userJson: $userJson');
        } catch (e) {
          print('❌ localStorage error: $e');
        }
      }
      
      if (userJson != null && userJson.isNotEmpty) {
        print('🔍 User data found, parsing...');
        final userData = jsonDecode(userJson);
        print('🔍 Parsed user data: $userData');
        
        // Load user data
        _currentUser = app_user.User(
          id: userData['id'],
          email: userData['email'],
          fullName: userData['fullName'],
          userType: userData['userType'] == 'UserType.tutor' 
              ? app_user.UserType.tutor 
              : app_user.UserType.student,
          createdAt: DateTime.parse(userData['createdAt']),
          updatedAt: DateTime.parse(userData['updatedAt']),
        );
        
        // Load token data
        _authToken = userData['authToken'];
        if (userData['tokenExpiry'] != null) {
          _tokenExpiry = DateTime.parse(userData['tokenExpiry']);
        }
        
        // Validate token
        if (!_isTokenValid()) {
          print('❌ Token expired, clearing user data');
          await _clearUserFromStorage();
          _currentUser = null;
          _authToken = null;
          _tokenExpiry = null;
        } else {
          print('✅ User and valid token loaded from storage: ${_currentUser?.email}');
          print('✅ Token expires at: $_tokenExpiry');
          print('✅ AuthService.isAuthenticated: $isAuthenticated');
        }
      } else {
        print('❌ No user data found in any storage');
        _currentUser = null;
        _authToken = null;
        _tokenExpiry = null;
      }
    } catch (e) {
      print('❌ Error loading user from storage: $e');
      print('❌ Error details: ${e.toString()}');
      _currentUser = null;
      _authToken = null;
      _tokenExpiry = null;
    }
  }
  
  // Clear user and token from storage
  static Future<void> _clearUserFromStorage() async {
    try {
      // Clear SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('current_user');
        print('🗑️ User and token cleared from SharedPreferences');
      } catch (e) {
        print('❌ Error clearing SharedPreferences: $e');
      }
      
      // Clear localStorage
      try {
        html.window.localStorage.remove('current_user');
        print('🗑️ User and token cleared from localStorage');
      } catch (e) {
        print('❌ Error clearing localStorage: $e');
      }
      
      // Clear in-memory data
      _currentUser = null;
      _authToken = null;
      _tokenExpiry = null;
      
      print('🗑️ User and token cleared from all storage and memory');
    } catch (e) {
      print('❌ Error clearing user from storage: $e');
    }
  }

  // Sign up with email and password
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required app_user.UserType userType,
  }) async {
    if (DemoConfig.useSupabase) {
      try {
        final response = await SupabaseAuthService.signUp(
          email: email,
          password: password,
          name: fullName,
          role: userType == app_user.UserType.tutor ? 'tutor' : 'student',
        );
        
        // Set current user
        _currentUser = app_user.User(
          id: response.user?.id ?? '',
          email: email,
          fullName: fullName,
          userType: userType,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save user to storage
        await _saveUserToStorage(_currentUser!);
        
        return {
          'success': true,
          'user': {
            'id': response.user?.id ?? '',
            'email': email,
            'full_name': fullName,
            'user_type': userType.toString().split('.').last,
          },
          'message': 'Sign up successful. Please check your email for verification.',
        };
      } catch (e) {
        String errorMessage = 'Sign up failed: $e';
        if (e.toString().contains('already registered')) {
          errorMessage = 'An account with this email already exists. Please sign in instead.';
        } else if (e.toString().contains('Invalid email')) {
          errorMessage = 'Please enter a valid email address.';
        } else if (e.toString().contains('Password should be at least')) {
          errorMessage = 'Password must be at least 6 characters long.';
        }
        throw Exception(errorMessage);
      }
    }
    
    // Demo mode - simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Set current user for demo mode
    _currentUser = app_user.User(
      id: 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: fullName,
      userType: userType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save user to storage
    await _saveUserToStorage(_currentUser!);
    
    return {
      'success': true,
      'user': {
        'id': 'demo_user_${DateTime.now().millisecondsSinceEpoch}',
        'email': email,
        'full_name': fullName,
        'user_type': userType.toString().split('.').last,
      },
      'message': 'Sign up successful (demo mode)',
    };
  }

  // Sign in with email and password
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    if (DemoConfig.useSupabase) {
      try {
        final response = await SupabaseAuthService.signIn(
          email: email,
          password: password,
        );
        
        final user = response.user;
        if (user == null) {
          throw Exception('Sign in failed: No user returned');
        }
        
        // Set current user
        _currentUser = app_user.User(
          id: user.id,
          email: user.email ?? email,
          fullName: user.userMetadata?['name'] ?? 'User',
          userType: user.userMetadata?['role'] == 'tutor' ? app_user.UserType.tutor : app_user.UserType.student,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Save user to storage
        await _saveUserToStorage(_currentUser!);
        
        return {
          'success': true,
          'user': {
            'id': user.id,
            'email': user.email ?? email,
            'full_name': user.userMetadata?['name'] ?? 'User',
            'user_type': user.userMetadata?['role'] ?? 'student',
          },
          'message': 'Sign in successful',
        };
      } catch (e) {
        throw Exception('Sign in failed: $e');
      }
    }
    
    // Demo mode - simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Set current user for demo mode
    _currentUser = app_user.User(
      id: 'demo_user',
      email: email,
      fullName: 'Demo Student',
      userType: app_user.UserType.student,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Save user to storage
    await _saveUserToStorage(_currentUser!);
    
    return {
      'success': true,
      'user': {
        'id': 'demo_user',
        'email': email,
        'full_name': 'Demo Student',
        'user_type': 'student',
      },
      'message': 'Sign in successful (demo mode)',
    };
  }

  // Sign in with Google (disabled for demo)
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    if (DemoConfig.useSupabase) {
      try {
        final success = await SupabaseAuthService.signInWithGoogle();
        return {
          'success': success,
          'user': currentUser,
          'message': success ? 'Google sign in successful' : 'Google sign in failed',
        };
      } catch (e) {
        return {
          'success': false,
          'message': e.toString(),
        };
      }
    }
    
    // Demo mode - simulate Google sign in
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'user': currentUser,
      'message': 'Google sign in successful (demo)',
    };
  }

  // Sign out (demo mode)
  static Future<void> signOut() async {
    print('🚪 AuthService.signOut called');
    // Clear current user and token
    _currentUser = null;
    _authToken = null;
    _tokenExpiry = null;
    await _clearUserFromStorage();
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    print('✅ User signed out and all data cleared successfully');
  }
  
  // Force logout (clears everything without confirmation)
  static Future<void> forceLogout() async {
    print('🚪 AuthService.forceLogout called');
    _currentUser = null;
    _authToken = null;
    _tokenExpiry = null;
    await _clearUserFromStorage();
    print('✅ Force logout completed');
  }

  // Reset password (demo mode)
  static Future<void> resetPassword(String email) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }

  // Update user profile (demo mode)
  static Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? phone,
    DateTime? dateOfBirth,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Get user profile from database (demo mode)
  static Future<app_user.User?> getUserProfile(String userId) async {
    // Return demo user
    return currentUser;
  }

  // Delete user account (demo mode)
  static Future<void> deleteAccount() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
  }
}