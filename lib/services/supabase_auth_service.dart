import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../config/supabase_config.dart';

class SupabaseAuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required String role, // 'student' or 'tutor'
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
        },
      );

      if (response.user != null) {
        // Create user profile based on role
        if (role == 'tutor') {
          await _createTutorProfile(response.user!.id, name, email);
        } else {
          await _createStudentProfile(response.user!.id, name, email);
        }
      }

      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign in with Google
  static Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.tutorhouse://login-callback/',
      );
      return true;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get current user
  static app_user.User? getCurrentUser() {
    final supabaseUser = _client.auth.currentUser;
    if (supabaseUser == null) return null;

    return app_user.User(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      fullName: supabaseUser.userMetadata?['name'] ?? '',
      userType: supabaseUser.userMetadata?['role'] == 'tutor' 
          ? app_user.UserType.tutor 
          : app_user.UserType.student,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get auth state changes stream
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Create tutor profile
  static Future<void> _createTutorProfile(String userId, String name, String email) async {
    try {
      await _client.from(SupabaseConfig.tutorsTable).insert({
        'id': userId,
        'name': name,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
    }
  }

  /// Create student profile
  static Future<void> _createStudentProfile(String userId, String name, String email) async {
    try {
      await _client.from(SupabaseConfig.studentsTable).insert({
        'id': userId,
        'name': name,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
    }
  }

  /// Update user profile
  static Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final user = getCurrentUser();
      if (user?.userType == app_user.UserType.tutor) {
        await _client.from(SupabaseConfig.tutorsTable)
            .update(updates)
            .eq('id', userId);
      } else {
        await _client.from(SupabaseConfig.studentsTable)
            .update(updates)
            .eq('id', userId);
      }
    } catch (e) {
      throw Exception('Profile update failed: $e');
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final user = getCurrentUser();
      if (user?.userType == app_user.UserType.tutor) {
        final response = await _client.from(SupabaseConfig.tutorsTable)
            .select()
            .eq('id', userId)
            .single();
        return response;
      } else {
        final response = await _client.from(SupabaseConfig.studentsTable)
            .select()
            .eq('id', userId)
            .single();
        return response;
      }
    } catch (e) {
      return null;
    }
  }
}
