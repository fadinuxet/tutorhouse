enum VideoType {
  intro,           // 30-60 seconds introduction
  teachingDemo,    // 2-5 minutes teaching demonstration
  subjectDeepDive, // 5-60 minutes subject content
  liveStream,      // Live streaming content
}

class VideoContent {
  final String id;
  final String tutorId;
  final VideoType videoType;
  final String? title;
  final String? subject;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final int viewCount;
  final int likeCount;
  final bool isFeatured;
  final bool isLive;
  final bool isSelectedForFeed; // Randomly selected for feed display
  final DateTime createdAt;

  VideoContent({
    required this.id,
    required this.tutorId,
    required this.videoType,
    this.title,
    this.subject,
    required this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.viewCount = 0,
    this.likeCount = 0,
    this.isFeatured = false,
    this.isLive = false,
    this.isSelectedForFeed = false,
    required this.createdAt,
  });

  factory VideoContent.fromJson(Map<String, dynamic> json) {
    return VideoContent(
      id: json['id'] as String,
      tutorId: json['tutor_id'] as String,
      videoType: VideoType.values.firstWhere(
        (e) => e.toString() == 'VideoType.${json['video_type']}',
        orElse: () => VideoType.intro,
      ),
      title: json['title'] as String?,
      subject: json['subject'] as String?,
      videoUrl: json['video_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutor_id': tutorId,
      'video_type': videoType.toString().split('.').last,
      'title': title,
      'subject': subject,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'view_count': viewCount,
      'like_count': likeCount,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
    };
  }

  VideoContent copyWith({
    String? id,
    String? tutorId,
    VideoType? videoType,
    String? title,
    String? subject,
    String? videoUrl,
    String? thumbnailUrl,
    int? durationSeconds,
    int? viewCount,
    int? likeCount,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return VideoContent(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      videoType: videoType ?? this.videoType,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  String get durationDisplay {
    if (durationSeconds == null) return 'Unknown';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get viewCountDisplay {
    if (viewCount < 1000) return viewCount.toString();
    if (viewCount < 1000000) return '${(viewCount / 1000).toStringAsFixed(1)}K';
    return '${(viewCount / 1000000).toStringAsFixed(1)}M';
  }

  String get likeCountDisplay {
    if (likeCount < 1000) return likeCount.toString();
    if (likeCount < 1000000) return '${(likeCount / 1000).toStringAsFixed(1)}K';
    return '${(likeCount / 1000000).toStringAsFixed(1)}M';
  }
}
