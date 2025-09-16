import '../models/user.dart' as app_user;
import '../models/tutor_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class BookingService {
  // In-memory storage for demo purposes
  // In production, this would be stored in Supabase
  static final List<Map<String, dynamic>> _bookings = [];
  static bool _isInitialized = false;

  // Initialize BookingService and load saved bookings
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ BookingService already initialized');
      return;
    }
    
    print('🚀 BookingService.initialize() called');
    
    try {
      await _loadBookingsFromStorage();
      _isInitialized = true;
      print('✅ BookingService initialized with ${_bookings.length} bookings');
    } catch (e) {
      print('❌ Error initializing BookingService: $e');
    }
  }

  // Save bookings to SharedPreferences
  static Future<void> _saveBookingsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = jsonEncode(_bookings);
      await prefs.setString('bookings', bookingsJson);
      print('💾 Saved ${_bookings.length} bookings to storage');
      print('💾 Bookings data: $_bookings');
    } catch (e) {
      print('❌ Error saving bookings to storage: $e');
    }
  }

  // Load bookings from SharedPreferences
  static Future<void> _loadBookingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getString('bookings');
      
      print('🔍 Loading bookings from storage: $bookingsJson');
      
      if (bookingsJson != null && bookingsJson.isNotEmpty) {
        final List<dynamic> bookingsList = jsonDecode(bookingsJson);
        _bookings.clear();
        _bookings.addAll(bookingsList.cast<Map<String, dynamic>>());
        print('📂 Loaded ${_bookings.length} bookings from storage');
        print('📂 Bookings: $_bookings');
      } else {
        print('❌ No bookings found in storage');
        _bookings.clear();
      }
    } catch (e) {
      print('❌ Error loading bookings from storage: $e');
      _bookings.clear();
    }
  }

  /// Check if a student has already booked a trial with a specific tutor
  static bool hasExistingTrialBooking(String studentId, String tutorId) {
    final hasBooking = _bookings.any((booking) =>
        booking['studentId'] == studentId &&
        booking['tutorId'] == tutorId &&
        booking['isTrial'] == true);
    
    print('🔍 BookingService.hasExistingTrialBooking - studentId: $studentId, tutorId: $tutorId, hasBooking: $hasBooking');
    print('🔍 Total bookings: ${_bookings.length}');
    for (var booking in _bookings) {
      print('🔍 Booking: ${booking['studentId']} -> ${booking['tutorId']} (trial: ${booking['isTrial']})');
    }
    
    return hasBooking;
  }

  /// Create a new booking
  static Future<Map<String, dynamic>> createBooking({
    required String studentId,
    required String tutorId,
    required String subject,
    required DateTime sessionTime,
    required int durationMinutes,
    required double price,
    required bool isTrial,
    required String meetLink,
  }) async {
    print('🚀 BookingService.createBooking called with:');
    print('   studentId: $studentId');
    print('   tutorId: $tutorId');
    print('   subject: $subject');
    print('   sessionTime: $sessionTime');
    print('   durationMinutes: $durationMinutes');
    print('   price: $price');
    print('   isTrial: $isTrial');
    print('   meetLink: $meetLink');
    
    // Check for existing trial booking
    if (isTrial && hasExistingTrialBooking(studentId, tutorId)) {
      print('❌ Trial booking already exists for this tutor');
      return {
        'success': false,
        'message': 'You have already booked a trial session with this tutor. You can only book one trial per tutor.',
      };
    }

    // Create new booking
    final booking = {
      'id': 'booking_${DateTime.now().millisecondsSinceEpoch}',
      'studentId': studentId,
      'tutorId': tutorId,
      'subject': subject,
      'sessionTime': sessionTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'price': price,
      'isTrial': isTrial,
      'meetLink': meetLink,
      'status': 'confirmed',
      'createdAt': DateTime.now().toIso8601String(),
    };

    print('📝 Created booking object: $booking');
    
    _bookings.add(booking);
    print('📝 Added to _bookings list. Total bookings: ${_bookings.length}');
    
    // Save to storage
    await _saveBookingsToStorage();
    print('💾 Saved to storage');
    
    print('✅ BookingService.createBooking - Added booking: ${booking['id']}');
    print('✅ Total bookings now: ${_bookings.length}');

    return {
      'success': true,
      'booking': booking,
      'message': 'Booking created successfully',
    };
  }

  /// Get all bookings for a student
  static List<Map<String, dynamic>> getStudentBookings(String studentId) {
    return _bookings.where((booking) => booking['studentId'] == studentId).toList();
  }

  /// Debug method to get all bookings
  static List<Map<String, dynamic>> getAllBookings() {
    print('🔍 BookingService.getAllBookings - Total bookings: ${_bookings.length}');
    for (int i = 0; i < _bookings.length; i++) {
      print('   Booking $i: ${_bookings[i]}');
    }
    return List.from(_bookings);
  }

  /// Get all bookings for a tutor
  static List<Map<String, dynamic>> getTutorBookings(String tutorId) {
    return _bookings.where((booking) => booking['tutorId'] == tutorId).toList();
  }

  /// Check if student can book trial with tutor
  static bool canBookTrial(String studentId, String tutorId) {
    return !hasExistingTrialBooking(studentId, tutorId);
  }

  /// Get the trial booking date for a specific tutor
  static String? getTrialBookingDate(String studentId, String tutorId) {
    print('🔍 getTrialBookingDate - studentId: $studentId, tutorId: $tutorId');
    print('🔍 Total bookings: ${_bookings.length}');
    
    final booking = _bookings.firstWhere(
      (booking) =>
          booking['studentId'] == studentId &&
          booking['tutorId'] == tutorId &&
          booking['isTrial'] == true,
      orElse: () => <String, dynamic>{},
    );
    
    if (booking.isEmpty) {
      print('❌ No trial booking found for this tutor');
      return null;
    }
    
    final sessionTime = DateTime.parse(booking['sessionTime']);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final dateStr = '${sessionTime.day} ${months[sessionTime.month - 1]} ${sessionTime.year}';
    print('✅ Found trial booking date: $dateStr');
    return dateStr;
  }
}
