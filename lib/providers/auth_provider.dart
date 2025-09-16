import 'package:flutter/foundation.dart';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  app_user.User? _user;
  String? _authToken;
  DateTime? _tokenExpiry;
  bool _isLoading = false;
  String? _error;

  // Getters
  app_user.User? get user => _user;
  String? get authToken => _authToken;
  DateTime? get tokenExpiry => _tokenExpiry;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _isTokenValid();

  // Check if token is valid (not expired)
  bool _isTokenValid() {
    if (_authToken == null || _tokenExpiry == null) return false;
    return DateTime.now().isBefore(_tokenExpiry!);
  }

  // Initialize auth state from storage
  Future<void> initialize() async {
    try {
      print('🚀 AuthProvider.initialize() called');
      
      // Load user and token from AuthService
      await AuthService.initialize();
      
      // Update provider state without triggering listeners during init
      _user = AuthService.currentUser;
      _authToken = AuthService.authToken;
      _tokenExpiry = AuthService.tokenExpiry;
      _isLoading = false;
      _error = null;
      
      print('✅ AuthProvider initialized - isAuthenticated: $isAuthenticated');
      print('✅ User: ${_user?.email}');
      print('✅ Token expires: $_tokenExpiry');
      
    } catch (e) {
      print('❌ Error initializing AuthProvider: $e');
      _user = null;
      _authToken = null;
      _tokenExpiry = null;
      _isLoading = false;
      _error = 'Failed to initialize authentication: $e';
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      print('🚀 AuthProvider.signIn called for: $email');
      
      final result = await AuthService.signIn(
        email: email,
        password: password,
      );
      
      if (result['success']) {
        // Update provider state
        _user = AuthService.currentUser;
        _authToken = AuthService.authToken;
        _tokenExpiry = AuthService.tokenExpiry;
        
        print('✅ AuthProvider sign in successful');
        notifyListeners();
      } else {
        _setError(result['message'] ?? 'Sign in failed');
      }
      
      return result;
    } catch (e) {
      print('❌ Error in AuthProvider.signIn: $e');
      _setError('Sign in failed: $e');
      return {
        'success': false,
        'message': 'Sign in failed: $e',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required app_user.UserType userType,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      print('🚀 AuthProvider.signUp called for: $email');
      
      final result = await AuthService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        userType: userType,
      );
      
      if (result['success']) {
        // Update provider state
        _user = AuthService.currentUser;
        _authToken = AuthService.authToken;
        _tokenExpiry = AuthService.tokenExpiry;
        
        print('✅ AuthProvider sign up successful');
        notifyListeners();
      } else {
        _setError(result['message'] ?? 'Sign up failed');
      }
      
      return result;
    } catch (e) {
      print('❌ Error in AuthProvider.signUp: $e');
      _setError('Sign up failed: $e');
      return {
        'success': false,
        'message': 'Sign up failed: $e',
      };
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    
    try {
      print('🚀 AuthProvider.signOut called');
      
      await AuthService.signOut();
      
      // Clear provider state
      _user = null;
      _authToken = null;
      _tokenExpiry = null;
      
      print('✅ AuthProvider sign out successful');
      notifyListeners();
    } catch (e) {
      print('❌ Error in AuthProvider.signOut: $e');
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Force logout (clears everything)
  Future<void> forceLogout() async {
    _setLoading(true);
    _clearError();
    
    try {
      print('🚀 AuthProvider.forceLogout called');
      
      await AuthService.forceLogout();
      
      // Clear provider state
      _user = null;
      _authToken = null;
      _tokenExpiry = null;
      
      print('✅ AuthProvider force logout successful');
      notifyListeners();
    } catch (e) {
      print('❌ Error in AuthProvider.forceLogout: $e');
      _setError('Force logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh token (if needed)
  Future<void> refreshToken() async {
    if (!isAuthenticated) return;
    
    try {
      print('🔄 AuthProvider.refreshToken called');
      
      // In a real app, you would call your backend to refresh the token
      // For demo purposes, we'll just check if the current token is still valid
      if (!_isTokenValid()) {
        print('❌ Token expired, signing out');
        await forceLogout();
      } else {
        print('✅ Token is still valid');
      }
    } catch (e) {
      print('❌ Error refreshing token: $e');
      await forceLogout();
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
