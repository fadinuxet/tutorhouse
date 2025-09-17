import 'tutor_profile.dart';

enum LiveSessionStatus {
  scheduled,
  live,
  ended,
  cancelled,
}

enum LiveSessionType {
  discovery,    // Free discovery sessions with raise hand
  group,        // Paid group sessions
  seminar,      // Large group seminars
}

class LiveSession {
  final String id;
  final String tutorId;
  final TutorProfile tutor;
  final String title;
  final String? description;
  final String subject;
  final LiveSessionType type;
  final LiveSessionStatus status;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int maxParticipants;
  final int currentParticipants;
  final double? price;
  final String? currency;
  final String? thumbnailUrl;
  final String? channelId;
  final String? agoraToken;
  final List<String> tags;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  LiveSession({
    required this.id,
    required this.tutorId,
    required this.tutor,
    required this.title,
    this.description,
    required this.subject,
    required this.type,
    required this.status,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    required this.maxParticipants,
    this.currentParticipants = 0,
    this.price,
    this.currency,
    this.thumbnailUrl,
    this.channelId,
    this.agoraToken,
    this.tags = const [],
    this.isPublic = true,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isLive => status == LiveSessionStatus.live;
  bool get isScheduled => status == LiveSessionStatus.scheduled;
  bool get isEnded => status == LiveSessionStatus.ended;
  bool get isCancelled => status == LiveSessionStatus.cancelled;
  
  String get tutorName => tutor.fullName;
  
  bool get isFree => type == LiveSessionType.discovery;
  bool get isPaid => price != null && price! > 0;
  
  String get statusText {
    switch (status) {
      case LiveSessionStatus.scheduled:
        return 'Scheduled';
      case LiveSessionStatus.live:
        return 'Live Now';
      case LiveSessionStatus.ended:
        return 'Ended';
      case LiveSessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get typeText {
    switch (type) {
      case LiveSessionType.discovery:
        return 'Discovery Session';
      case LiveSessionType.group:
        return 'Group Session';
      case LiveSessionType.seminar:
        return 'Seminar';
    }
  }

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['id'] as String,
      tutorId: json['tutor_id'] as String,
      tutor: TutorProfile.fromJson(json['tutor'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String?,
      subject: json['subject'] as String,
      type: LiveSessionType.values.firstWhere(
        (e) => e.toString() == 'LiveSessionType.${json['type']}',
        orElse: () => LiveSessionType.discovery,
      ),
      status: LiveSessionStatus.values.firstWhere(
        (e) => e.toString() == 'LiveSessionStatus.${json['status']}',
        orElse: () => LiveSessionStatus.scheduled,
      ),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at'] as String) 
          : null,
      endedAt: json['ended_at'] != null 
          ? DateTime.parse(json['ended_at'] as String) 
          : null,
      maxParticipants: json['max_participants'] as int,
      currentParticipants: json['current_participants'] as int? ?? 0,
      price: json['price'] as double?,
      currency: json['currency'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      channelId: json['channel_id'] as String?,
      agoraToken: json['agora_token'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPublic: json['is_public'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutor_id': tutorId,
      'tutor': tutor.toJson(),
      'title': title,
      'description': description,
      'subject': subject,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'scheduled_at': scheduledAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'price': price,
      'currency': currency,
      'thumbnail_url': thumbnailUrl,
      'channel_id': channelId,
      'agora_token': agoraToken,
      'tags': tags,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RaisedHand {
  final String id;
  final String sessionId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final DateTime raisedAt;
  final bool isApproved;
  final DateTime? approvedAt;

  RaisedHand({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.raisedAt,
    this.isApproved = false,
    this.approvedAt,
  });

  factory RaisedHand.fromJson(Map<String, dynamic> json) {
    return RaisedHand(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      raisedAt: DateTime.parse(json['raised_at'] as String),
      isApproved: json['is_approved'] as bool? ?? false,
      approvedAt: json['approved_at'] != null 
          ? DateTime.parse(json['approved_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'raised_at': raisedAt.toIso8601String(),
      'is_approved': isApproved,
      'approved_at': approvedAt?.toIso8601String(),
    };
  }
}

class LiveSessionMessage {
  final String id;
  final String sessionId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String message;
  final MessageType type;
  final DateTime timestamp;

  LiveSessionMessage({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.message,
    required this.type,
    required this.timestamp,
  });

  factory LiveSessionMessage.fromJson(Map<String, dynamic> json) {
    return LiveSessionMessage(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatar: json['user_avatar'] as String?,
      message: json['message'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

enum MessageType {
  text,
  system,
  handRaised,
  handApproved,
  handRejected,
}