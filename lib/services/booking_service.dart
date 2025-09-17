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
      return;
    }
    
    
    try {
      await _loadBookingsFromStorage();
      _isInitialized = true;
    } catch (e) {
    }
  }

  // Save bookings to SharedPreferences
  static Future<void> _saveBookingsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = jsonEncode(_bookings);
      await prefs.setString('bookings', bookingsJson);
    } catch (e) {
    }
  }

  // Load bookings from SharedPreferences
  static Future<void> _loadBookingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getString('bookings');
      
      
      if (bookingsJson != null && bookingsJson.isNotEmpty) {
        final List<dynamic> bookingsList = jsonDecode(bookingsJson);
        _bookings.clear();
        _bookings.addAll(bookingsList.cast<Map<String, dynamic>>());
      } else {
        _bookings.clear();
      }
    } catch (e) {
      _bookings.clear();
    }
  }

  /// Check if a student has already booked a trial with a specific tutor
  static bool hasExistingTrialBooking(String studentId, String tutorId) {
    final hasBooking = _bookings.any((booking) =>
        booking['studentId'] == studentId &&
        booking['tutorId'] == tutorId &&
        booking['isTrial'] == true);
    
    for (var booking in _bookings) {
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
    
    // Check for existing trial booking
    if (isTrial && hasExistingTrialBooking(studentId, tutorId)) {
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

    
    _bookings.add(booking);
    
    // Save to storage
    await _saveBookingsToStorage();
    

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
    for (int i = 0; i < _bookings.length; i++) {
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
    
    final booking = _bookings.firstWhere(
      (booking) =>
          booking['studentId'] == studentId &&
          booking['tutorId'] == tutorId &&
          booking['isTrial'] == true,
      orElse: () => <String, dynamic>{},
    );
    
    if (booking.isEmpty) {
      return null;
    }
    
    final sessionTime = DateTime.parse(booking['sessionTime']);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final dateStr = '${sessionTime.day} ${months[sessionTime.month - 1]} ${sessionTime.year}';
    return dateStr;
  }
}
