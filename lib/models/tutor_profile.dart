class TutorProfile {
  final String id;
  final String userId;
  final String fullName;
  final String? bio;
  final String introVideoUrl;
  final List<String> subjects;
  final List<String> yearLevels;
  final double hourlyRate;
  final String currency;
  final int? experienceYears;
  final List<String> qualifications;
  final Map<String, dynamic>? availability;
  final bool isVerified;
  final double rating;
  final int totalRatings;
  final int totalSessions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? bookedTrialDate;

  TutorProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    this.bio,
    required this.introVideoUrl,
    required this.subjects,
    required this.yearLevels,
    required this.hourlyRate,
    required this.currency,
    this.experienceYears,
    required this.qualifications,
    this.availability,
    this.isVerified = false,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.totalSessions = 0,
    this.isActive = true,
    required this.createdAt,
    this.bookedTrialDate,
  });

  factory TutorProfile.fromJson(Map<String, dynamic> json) {
    return TutorProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      bio: json['bio'] as String?,
      introVideoUrl: json['intro_video_url'] as String,
      subjects: List<String>.from(json['subjects'] as List? ?? []),
      yearLevels: List<String>.from(json['year_levels'] as List? ?? []),
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'GBP',
      experienceYears: json['experience_years'] as int?,
      qualifications: List<String>.from(json['qualifications'] as List? ?? []),
      availability: json['availability'] as Map<String, dynamic>?,
      isVerified: json['is_verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['total_ratings'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      bookedTrialDate: json['booked_trial_date'] != null 
          ? DateTime.parse(json['booked_trial_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'bio': bio,
      'intro_video_url': introVideoUrl,
      'subjects': subjects,
      'year_levels': yearLevels,
      'hourly_rate': hourlyRate,
      'currency': currency,
      'experience_years': experienceYears,
      'qualifications': qualifications,
      'availability': availability,
      'is_verified': isVerified,
      'rating': rating,
      'total_ratings': totalRatings,
      'total_sessions': totalSessions,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'booked_trial_date': bookedTrialDate?.toIso8601String(),
    };
  }

  TutorProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? bio,
    String? introVideoUrl,
    List<String>? subjects,
    List<String>? yearLevels,
    double? hourlyRate,
    String? currency,
    int? experienceYears,
    List<String>? qualifications,
    Map<String, dynamic>? availability,
    bool? isVerified,
    double? rating,
    int? totalRatings,
    int? totalSessions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? bookedTrialDate,
  }) {
    return TutorProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      introVideoUrl: introVideoUrl ?? this.introVideoUrl,
      subjects: subjects ?? this.subjects,
      yearLevels: yearLevels ?? this.yearLevels,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      currency: currency ?? this.currency,
      experienceYears: experienceYears ?? this.experienceYears,
      qualifications: qualifications ?? this.qualifications,
      availability: availability ?? this.availability,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      totalSessions: totalSessions ?? this.totalSessions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      bookedTrialDate: bookedTrialDate ?? this.bookedTrialDate,
    );
  }

  // Helper methods
  String get displayName => bio?.isNotEmpty == true ? bio! : 'Tutor';
  String get ratingDisplay => rating.toStringAsFixed(1);
  String get hourlyRateDisplay => _getCurrencySymbol() + hourlyRate.toStringAsFixed(2) + '/hour';
  bool get hasExperience => experienceYears != null && experienceYears! > 0;
  bool get isNewTutor => totalSessions < 5;
  bool get hasBookedTrial => bookedTrialDate != null;
  String get bookedTrialDisplay {
    if (bookedTrialDate == null) return '';
    final date = bookedTrialDate!;
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  String _getCurrencySymbol() {
    switch (currency.toUpperCase()) {
      case 'GBP':
        return '£';
      case 'USD':
        return '\$';
      case 'AED':
        return 'AED ';
      case 'SGD':
        return 'S\$';
      case 'EUR':
        return '€';
      default:
        return '£';
    }
  }
}
