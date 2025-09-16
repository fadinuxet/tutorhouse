import '../models/video_content.dart';
import '../models/tutor_profile.dart';
import '../models/live_session.dart';
import '../constants/british_curricula.dart';

class SampleDataService {
  static final List<VideoContent> _sampleVideos = [
    VideoContent(
      id: '1',
      tutorId: 'tutor_1',
      videoType: VideoType.intro,
      title: 'GCSE Maths Expert',
      subject: 'GCSE Maths',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=1',
      durationSeconds: 45,
      viewCount: 1250,
      likeCount: 89,
      isFeatured: true,
      isLive: false,
      isSelectedForFeed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    VideoContent(
      id: '2',
      tutorId: 'tutor_2',
      videoType: VideoType.intro,
      title: 'A-Level Physics Specialist',
      subject: 'A-Level Physics',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=2',
      durationSeconds: 52,
      viewCount: 2100,
      likeCount: 156,
      isFeatured: true,
      isLive: true, // This tutor is currently live
      isSelectedForFeed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    VideoContent(
      id: '3',
      tutorId: 'tutor_3',
      videoType: VideoType.teachingDemo,
      title: 'Chemistry Made Easy',
      subject: 'GCSE Chemistry',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=3',
      durationSeconds: 180, // 3 minutes teaching demo
      viewCount: 890,
      likeCount: 67,
      isFeatured: true,
      isLive: false,
      isSelectedForFeed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    VideoContent(
      id: '4',
      tutorId: 'tutor_4',
      videoType: VideoType.subjectDeepDive,
      title: 'English Literature Analysis',
      subject: 'A-Level English',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=4',
      durationSeconds: 1200, // 20 minutes deep dive
      viewCount: 1450,
      likeCount: 112,
      isFeatured: true,
      isLive: false,
      isSelectedForFeed: false, // Not selected for feed
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    VideoContent(
      id: '5',
      tutorId: 'tutor_5',
      videoType: VideoType.intro,
      title: 'Biology & Medicine Prep',
      subject: 'A-Level Biology',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=5',
      durationSeconds: 47,
      viewCount: 980,
      likeCount: 73,
      isFeatured: true,
      isLive: false,
      isSelectedForFeed: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  static final List<TutorProfile> _sampleTutors = [
    TutorProfile(
      id: 'tutor_1',
      userId: 'user_1',
      fullName: 'Sarah Johnson',
      bio: 'Experienced GCSE Mathematics tutor with 5+ years helping students achieve top grades.',
      introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      subjects: ['GCSE Maths', 'A-Level Maths'],
      yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
      hourlyRate: 25.0,
      currency: 'GBP',
      experienceYears: 5,
      qualifications: ['BSc Mathematics', 'PGCE Secondary Education'],
      availability: {
        'monday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        'tuesday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        'wednesday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        'thursday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        'friday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
        'saturday': ['10:00', '11:00', '12:00', '13:00', '14:00'],
        'sunday': ['10:00', '11:00', '12:00', '13:00', '14:00'],
      },
      isVerified: true,
      rating: 4.8,
      totalRatings: 127,
      totalSessions: 450,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    TutorProfile(
      id: 'tutor_2',
      userId: 'user_2',
      fullName: 'Dr. Michael Chen',
      bio: 'Physics PhD with passion for making complex concepts simple and engaging.',
      introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      subjects: ['A-Level Physics', 'GCSE Physics'],
      yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
      hourlyRate: 35.0,
      currency: 'GBP',
      experienceYears: 8,
      qualifications: ['PhD Physics', 'MSc Applied Physics', 'BSc Physics'],
      availability: {
        'monday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
        'tuesday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
        'wednesday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
        'thursday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
        'friday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
        'saturday': ['09:00', '10:00', '11:00', '12:00'],
        'sunday': ['09:00', '10:00', '11:00', '12:00'],
      },
      isVerified: true,
      rating: 4.9,
      totalRatings: 89,
      totalSessions: 320,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    TutorProfile(
      id: 'tutor_3',
      userId: 'user_3',
      fullName: 'Emma Williams',
      bio: 'Chemistry teacher with innovative teaching methods and excellent results.',
      introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      subjects: ['GCSE Chemistry', 'A-Level Chemistry'],
      yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
      hourlyRate: 28.0,
      currency: 'GBP',
      experienceYears: 6,
      qualifications: ['MSc Chemistry', 'BSc Chemistry', 'QTS'],
      availability: {
        'monday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
        'tuesday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
        'wednesday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
        'thursday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
        'friday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
        'saturday': ['09:00', '10:00', '11:00', '12:00', '13:00'],
        'sunday': ['09:00', '10:00', '11:00', '12:00', '13:00'],
      },
      isVerified: true,
      rating: 4.7,
      totalRatings: 156,
      totalSessions: 520,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    TutorProfile(
      id: 'tutor_4',
      userId: 'user_4',
      fullName: 'James Thompson',
      bio: 'English Literature specialist helping students develop critical thinking skills.',
      introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      subjects: ['A-Level English', 'GCSE English'],
      yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
      hourlyRate: 30.0,
      currency: 'GBP',
      experienceYears: 7,
      qualifications: ['MA English Literature', 'BA English', 'PGCE'],
      isVerified: true,
      rating: 4.6,
      totalRatings: 98,
      totalSessions: 380,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    TutorProfile(
      id: 'tutor_5',
      userId: 'user_5',
      fullName: 'Dr. Lisa Patel',
      bio: 'Biology expert with medical background, specializing in exam preparation.',
      introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      subjects: ['A-Level Biology', 'GCSE Biology'],
      yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
      hourlyRate: 32.0,
      currency: 'GBP',
      experienceYears: 4,
      qualifications: ['MBBS Medicine', 'BSc Biomedical Sciences'],
      isVerified: true,
      rating: 4.9,
      totalRatings: 67,
      totalSessions: 240,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    // International tutors for global markets
    TutorProfile(
      id: 'tutor_6',
      userId: 'user_6',
      fullName: 'Ahmed Al-Rashid',
      bio: 'GCSE Maths Expert in Dubai - helping students excel in British curricula.',
      introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      subjects: ['GCSE Maths', 'A-Level Maths'],
      yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
      hourlyRate: 120.0,
      currency: 'AED',
      experienceYears: 6,
      qualifications: ['BSc Mathematics', 'PGCE', 'UAE Teaching License'],
      isVerified: true,
      rating: 4.8,
      totalRatings: 89,
      totalSessions: 320,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    TutorProfile(
      id: 'tutor_7',
      userId: 'user_7',
      fullName: 'Priya Sharma',
      bio: 'A-Level Physics Specialist in Singapore - making complex concepts simple.',
      introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      subjects: ['A-Level Physics', 'GCSE Physics'],
      yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
      hourlyRate: 50.0,
      currency: 'SGD',
      experienceYears: 7,
      qualifications: ['MSc Physics', 'Singapore Teaching License'],
      isVerified: true,
      rating: 4.9,
      totalRatings: 67,
      totalSessions: 280,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  static final List<LiveSession> _sampleLiveSessions = [
    LiveSession(
      id: 'live_1',
      tutorId: 'tutor_1',
      tutor: TutorProfile(
        id: 'tutor_1',
        userId: 'user_1',
        fullName: 'Sarah Johnson',
        bio: 'Experienced GCSE Mathematics tutor with 5+ years helping students achieve top grades.',
        introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        subjects: ['GCSE Maths', 'A-Level Maths'],
        yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
        hourlyRate: 25.0,
        currency: 'GBP',
        experienceYears: 5,
        qualifications: ['BSc Mathematics', 'PGCE Secondary Education'],
        availability: {
          'monday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
          'tuesday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
          'wednesday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
          'thursday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
          'friday': ['09:00', '10:00', '11:00', '14:00', '15:00', '16:00'],
          'saturday': ['10:00', '11:00', '14:00', '15:00'],
          'sunday': ['10:00', '11:00', '14:00', '15:00'],
        },
        isVerified: true,
        rating: 4.8,
        totalRatings: 127,
        totalSessions: 450,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      title: 'GCSE Maths Problem Solving',
      description: 'Join me for a live problem-solving session covering algebra and geometry.',
      subject: 'GCSE Maths',
      type: LiveSessionType.discovery,
      status: LiveSessionStatus.live,
      scheduledAt: DateTime.now().subtract(const Duration(minutes: 30)),
      startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      maxParticipants: 50,
      currentParticipants: 23,
      thumbnailUrl: 'https://picsum.photos/400/600?random=live1',
      channelId: 'maths_live_1',
      tags: ['GCSE', 'Maths', 'Problem Solving', 'Live'],
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    LiveSession(
      id: 'live_2',
      tutorId: 'tutor_2',
      tutor: TutorProfile(
        id: 'tutor_2',
        userId: 'user_2',
        fullName: 'Dr. Michael Chen',
        bio: 'Physics PhD with passion for making complex concepts simple and engaging.',
        introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        subjects: ['A-Level Physics', 'GCSE Physics'],
        yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
        hourlyRate: 35.0,
        currency: 'GBP',
        experienceYears: 8,
        qualifications: ['PhD Physics', 'MSc Applied Physics', 'BSc Physics'],
        availability: {
          'monday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
          'tuesday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
          'wednesday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
          'thursday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
          'friday': ['10:00', '11:00', '15:00', '16:00', '17:00'],
          'saturday': ['11:00', '14:00', '15:00', '16:00'],
          'sunday': ['11:00', '14:00', '15:00', '16:00'],
        },
        isVerified: true,
        rating: 4.9,
        totalRatings: 89,
        totalSessions: 320,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      title: 'A-Level Physics: Quantum Mechanics',
      description: 'Exploring the fascinating world of quantum mechanics with interactive examples.',
      subject: 'A-Level Physics',
      type: LiveSessionType.group,
      status: LiveSessionStatus.scheduled,
      scheduledAt: DateTime.now().add(const Duration(hours: 2)),
      maxParticipants: 20,
      currentParticipants: 8,
      price: 15.0,
      currency: 'GBP',
      thumbnailUrl: 'https://picsum.photos/400/600?random=live2',
      channelId: 'physics_live_2',
      tags: ['A-Level', 'Physics', 'Quantum Mechanics', 'Group Session'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    LiveSession(
      id: 'live_3',
      tutorId: 'tutor_3',
      tutor: TutorProfile(
        id: 'tutor_3',
        userId: 'user_3',
        fullName: 'Emma Williams',
        bio: 'Chemistry teacher with innovative teaching methods and excellent results.',
        introVideoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        subjects: ['GCSE Chemistry', 'A-Level Chemistry'],
        yearLevels: ['Year 10', 'Year 11', 'Year 12', 'Year 13'],
        hourlyRate: 28.0,
        currency: 'GBP',
        experienceYears: 6,
        qualifications: ['MSc Chemistry', 'BSc Chemistry', 'QTS'],
        availability: {
          'monday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
          'tuesday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
          'wednesday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
          'thursday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
          'friday': ['08:00', '09:00', '10:00', '13:00', '14:00', '15:00'],
          'saturday': ['09:00', '10:00', '13:00', '14:00'],
          'sunday': ['09:00', '10:00', '13:00', '14:00'],
        },
        isVerified: true,
        rating: 4.7,
        totalRatings: 156,
        totalSessions: 520,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      title: 'Chemistry Lab Techniques',
      description: 'Learn essential lab techniques and safety procedures for chemistry experiments.',
      subject: 'GCSE Chemistry',
      type: LiveSessionType.discovery,
      status: LiveSessionStatus.live,
      scheduledAt: DateTime.now().subtract(const Duration(minutes: 15)),
      startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      maxParticipants: 30,
      currentParticipants: 12,
      thumbnailUrl: 'https://picsum.photos/400/600?random=live3',
      channelId: 'chemistry_live_3',
      tags: ['GCSE', 'Chemistry', 'Lab Techniques', 'Safety'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  static final List<LiveSessionMessage> _sampleMessages = [
    LiveSessionMessage(
      id: 'msg_1',
      sessionId: 'live_1',
      userId: 'student_1',
      userName: 'Sarah M.',
      message: 'Great explanation! Can you show another example?',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    LiveSessionMessage(
      id: 'msg_2',
      sessionId: 'live_1',
      userId: 'student_2',
      userName: 'Alex K.',
      message: 'I have a question about the quadratic formula',
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    LiveSessionMessage(
      id: 'msg_3',
      sessionId: 'live_1',
      userId: 'student_3',
      userName: 'Emma R.',
      message: 'Raised hand',
      type: MessageType.handRaised,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  static final List<RaisedHand> _sampleRaisedHands = [
    RaisedHand(
      id: 'hand_1',
      sessionId: 'live_1',
      userId: 'student_3',
      userName: 'Emma R.',
      userAvatar: 'https://picsum.photos/100/100?random=student1',
      raisedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    RaisedHand(
      id: 'hand_2',
      sessionId: 'live_1',
      userId: 'student_4',
      userName: 'James L.',
      userAvatar: 'https://picsum.photos/100/100?random=student2',
      raisedAt: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  static List<VideoContent> getSampleVideos() {
    return List.from(_sampleVideos);
  }

  static List<VideoContent> getFeedVideos() {
    // Return only videos selected for feed display
    return _sampleVideos.where((video) => video.isSelectedForFeed).toList();
  }

  static List<VideoContent> getLiveVideos() {
    // Return only live videos
    return _sampleVideos.where((video) => video.isLive).toList();
  }

  static List<TutorProfile> getSampleTutors() {
    return List.from(_sampleTutors);
  }

  static VideoContent? getVideoById(String id) {
    try {
      return _sampleVideos.firstWhere((video) => video.id == id);
    } catch (e) {
      return null;
    }
  }

  static TutorProfile? getTutorById(String id) {
    try {
      return _sampleTutors.firstWhere((tutor) => tutor.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<VideoContent> getVideosBySubject(String subject) {
    return _sampleVideos.where((video) => 
        video.subject?.toLowerCase().contains(subject.toLowerCase()) == true
    ).toList();
  }

  static List<TutorProfile> getTutorsBySubject(String subject) {
    return _sampleTutors.where((tutor) => 
        tutor.subjects.any((s) => s.toLowerCase().contains(subject.toLowerCase()))
    ).toList();
  }

  // Live Session methods
  static List<LiveSession> getLiveSessions() {
    return List.from(_sampleLiveSessions);
  }

  static List<LiveSession> getCurrentlyLiveSessions() {
    return _sampleLiveSessions.where((session) => session.isLive).toList();
  }

  static List<LiveSession> getScheduledLiveSessions() {
    return _sampleLiveSessions.where((session) => session.isScheduled).toList();
  }

  static LiveSession? getLiveSessionById(String id) {
    try {
      return _sampleLiveSessions.firstWhere((session) => session.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<LiveSessionMessage> getLiveSessionMessages(String sessionId) {
    return _sampleMessages.where((message) => message.sessionId == sessionId).toList();
  }

  static List<RaisedHand> getRaisedHands(String sessionId) {
    return _sampleRaisedHands.where((hand) => hand.sessionId == sessionId).toList();
  }
}
