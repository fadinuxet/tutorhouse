import '../models/video_content.dart';
import '../models/tutor_profile.dart';
import 'sample_data_service.dart';

class FeedService {
  static const bool _useSampleData = true; // Always use sample data in demo

  // Get video feed with pagination
  static Future<List<VideoContent>> getVideoFeed({
    int limit = 10,
    int offset = 0,
  }) async {
    if (_useSampleData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      final allVideos = SampleDataService.getFeedVideos();
      final endIndex = (offset + limit).clamp(0, allVideos.length);
      return allVideos.sublist(offset, endIndex);
    }

    // Demo mode - always use sample data
    return [];
  }

  // Get live streams (demo mode)
  static Future<List<Map<String, dynamic>>> getLiveStreams() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  // Get tutor's videos (demo mode)
  static Future<List<VideoContent>> getTutorVideos(
    String tutorId, {
    int limit = 10,
    int offset = 0,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return SampleDataService.getSampleVideos()
        .where((video) => video.tutorId == tutorId)
        .toList();
  }

  // Like a video (demo mode)
  static Future<void> likeVideo(String videoId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Unlike a video (demo mode)
  static Future<void> unlikeVideo(String videoId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Increment view count (demo mode)
  static Future<void> incrementViewCount(String videoId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Follow a tutor (demo mode)
  static Future<void> followTutor(String tutorId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Unfollow a tutor (demo mode)
  static Future<void> unfollowTutor(String tutorId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Check if user is following a tutor (demo mode)
  static Future<bool> isFollowingTutor(String tutorId) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 100));
    return false; // Demo mode - not following anyone
  }

  // Get trending tutors (demo mode)
  static Future<List<TutorProfile>> getTrendingTutors({
    int limit = 10,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return SampleDataService.getSampleTutors().take(limit).toList();
  }

  // Search videos by subject (demo mode)
  static Future<List<VideoContent>> searchVideos(
    String query, {
    int limit = 10,
    int offset = 0,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return SampleDataService.getVideosBySubject(query).take(limit).toList();
  }
}