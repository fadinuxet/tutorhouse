enum BookingStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

enum SessionType {
  oneToOne,
  group,
}

class Booking {
  final String id;
  final String studentId;
  final String tutorId;
  final SessionType sessionType;
  final String subject;
  final DateTime scheduledAt;
  final int durationMinutes;
  final double pricePaid;
  final double platformFee;
  final BookingStatus status;
  final String? googleMeetLink;
  final String? whiteboardSessionId;
  final String? stripePaymentIntentId;
  final String? notes;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.studentId,
    required this.tutorId,
    this.sessionType = SessionType.oneToOne,
    required this.subject,
    required this.scheduledAt,
    this.durationMinutes = 60,
    required this.pricePaid,
    required this.platformFee,
    this.status = BookingStatus.confirmed,
    this.googleMeetLink,
    this.whiteboardSessionId,
    this.stripePaymentIntentId,
    this.notes,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      tutorId: json['tutor_id'] as String,
      sessionType: SessionType.values.firstWhere(
        (e) => e.toString() == 'SessionType.${json['session_type']}',
        orElse: () => SessionType.oneToOne,
      ),
      subject: json['subject'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int? ?? 60,
      pricePaid: (json['price_paid'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
        orElse: () => BookingStatus.confirmed,
      ),
      googleMeetLink: json['google_meet_link'] as String?,
      whiteboardSessionId: json['whiteboard_session_id'] as String?,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'tutor_id': tutorId,
      'session_type': sessionType.toString().split('.').last,
      'subject': subject,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'price_paid': pricePaid,
      'platform_fee': platformFee,
      'status': status.toString().split('.').last,
      'google_meet_link': googleMeetLink,
      'whiteboard_session_id': whiteboardSessionId,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Booking copyWith({
    String? id,
    String? studentId,
    String? tutorId,
    SessionType? sessionType,
    String? subject,
    DateTime? scheduledAt,
    int? durationMinutes,
    double? pricePaid,
    double? platformFee,
    BookingStatus? status,
    String? googleMeetLink,
    String? whiteboardSessionId,
    String? stripePaymentIntentId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      tutorId: tutorId ?? this.tutorId,
      sessionType: sessionType ?? this.sessionType,
      subject: subject ?? this.subject,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pricePaid: pricePaid ?? this.pricePaid,
      platformFee: platformFee ?? this.platformFee,
      status: status ?? this.status,
      googleMeetLink: googleMeetLink ?? this.googleMeetLink,
      whiteboardSessionId: whiteboardSessionId ?? this.whiteboardSessionId,
      stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  String get statusDisplay {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get sessionTypeDisplay {
    switch (sessionType) {
      case SessionType.oneToOne:
        return '1-to-1';
      case SessionType.group:
        return 'Group';
    }
  }

  double get totalPrice => pricePaid + platformFee;
  String get totalPriceDisplay => '£${totalPrice.toStringAsFixed(2)}';
  String get pricePaidDisplay => '£${pricePaid.toStringAsFixed(2)}';
  String get platformFeeDisplay => '£${platformFee.toStringAsFixed(2)}';

  bool get isUpcoming => 
      status == BookingStatus.confirmed && 
      scheduledAt.isAfter(DateTime.now());

  bool get isPast => 
      status == BookingStatus.completed || 
      (status == BookingStatus.confirmed && scheduledAt.isBefore(DateTime.now()));

  bool get canBeCancelled => 
      status == BookingStatus.confirmed && 
      scheduledAt.isAfter(DateTime.now().add(const Duration(hours: 24)));
}
