import 'package:flutter/foundation.dart';
import '../models/tutor_profile.dart';
import '../services/sample_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TutorProvider extends ChangeNotifier {
  List<TutorProfile> _tutors = [];
  bool _isInitialized = false;

  // Getters
  List<TutorProfile> get tutors => _tutors;
  bool get isInitialized => _isInitialized;

  // Initialize and load tutors
  Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ TutorProvider already initialized');
      return;
    }
    
    print('🚀 TutorProvider.initialize() called');
    
    try {
      // Load sample tutors
      _tutors = SampleDataService.getSampleTutors();
      
      // Load booking data from storage
      await _loadBookingDataFromStorage();
      
      _isInitialized = true;
      print('✅ TutorProvider initialized with ${_tutors.length} tutors');
    } catch (e) {
      print('❌ Error initializing TutorProvider: $e');
    }
  }

  // Load booking data from SharedPreferences
  Future<void> _loadBookingDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingDataJson = prefs.getString('tutor_booking_data');
      
      if (bookingDataJson != null && bookingDataJson.isNotEmpty) {
        final Map<String, dynamic> bookingData = jsonDecode(bookingDataJson);
        
        // Update tutors with booking data
        for (int i = 0; i < _tutors.length; i++) {
          final tutorId = _tutors[i].id;
          if (bookingData.containsKey(tutorId)) {
            final bookedDate = DateTime.parse(bookingData[tutorId] as String);
            _tutors[i] = _tutors[i].copyWith(bookedTrialDate: bookedDate);
          }
        }
        
        print('📂 Loaded booking data for ${bookingData.length} tutors');
      }
    } catch (e) {
      print('❌ Error loading booking data: $e');
    }
  }

  // Save booking data to SharedPreferences
  Future<void> _saveBookingDataToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Create booking data map
      final Map<String, dynamic> bookingData = {};
      for (final tutor in _tutors) {
        if (tutor.bookedTrialDate != null) {
          bookingData[tutor.id] = tutor.bookedTrialDate!.toIso8601String();
        }
      }
      
      final bookingDataJson = jsonEncode(bookingData);
      await prefs.setString('tutor_booking_data', bookingDataJson);
      
      print('💾 Saved booking data for ${bookingData.length} tutors');
    } catch (e) {
      print('❌ Error saving booking data: $e');
    }
  }

  // Book a trial with a specific tutor
  Future<bool> bookTrialWithTutor(String tutorId, DateTime sessionTime) async {
    try {
      print('🚀 TutorProvider.bookTrialWithTutor called for tutor: $tutorId');
      
      // Find the tutor
      final tutorIndex = _tutors.indexWhere((tutor) => tutor.id == tutorId);
      if (tutorIndex == -1) {
        print('❌ Tutor not found: $tutorId');
        return false;
      }
      
      // Check if already booked
      if (_tutors[tutorIndex].hasBookedTrial) {
        print('❌ Trial already booked for tutor: $tutorId');
        return false;
      }
      
      // Update the tutor with booking date
      _tutors[tutorIndex] = _tutors[tutorIndex].copyWith(bookedTrialDate: sessionTime);
      
      // Save to storage
      await _saveBookingDataToStorage();
      
      // Notify listeners
      notifyListeners();
      
      print('✅ Trial booked successfully for tutor: $tutorId at $sessionTime');
      return true;
    } catch (e) {
      print('❌ Error booking trial: $e');
      return false;
    }
  }

  // Check if a tutor has a booked trial
  bool hasBookedTrialWithTutor(String tutorId) {
    final tutor = _tutors.firstWhere(
      (t) => t.id == tutorId,
      orElse: () => TutorProfile(
        id: tutorId,
        userId: tutorId,
        fullName: 'Unknown Tutor',
        bio: 'Tutor',
        introVideoUrl: '',
        subjects: [],
        yearLevels: [],
        hourlyRate: 0.0,
        currency: 'GBP',
        qualifications: [],
        createdAt: DateTime.now(),
      ),
    );
    return tutor.hasBookedTrial;
  }

  // Get the booked trial date for a tutor
  String? getBookedTrialDate(String tutorId) {
    final tutor = _tutors.firstWhere(
      (t) => t.id == tutorId,
      orElse: () => TutorProfile(
        id: tutorId,
        userId: tutorId,
        fullName: 'Unknown Tutor',
        bio: 'Tutor',
        introVideoUrl: '',
        subjects: [],
        yearLevels: [],
        hourlyRate: 0.0,
        currency: 'GBP',
        qualifications: [],
        createdAt: DateTime.now(),
      ),
    );
    return tutor.hasBookedTrial ? tutor.bookedTrialDisplay : null;
  }

  // Get a specific tutor by ID
  TutorProfile? getTutorById(String tutorId) {
    try {
      return _tutors.firstWhere((tutor) => tutor.id == tutorId);
    } catch (e) {
      return null;
    }
  }

  // Clear all booking data (for testing)
  Future<void> clearAllBookings() async {
    try {
      for (int i = 0; i < _tutors.length; i++) {
        _tutors[i] = _tutors[i].copyWith(bookedTrialDate: null);
      }
      
      await _saveBookingDataToStorage();
      notifyListeners();
      
      print('🗑️ All booking data cleared');
    } catch (e) {
      print('❌ Error clearing booking data: $e');
    }
  }
}
