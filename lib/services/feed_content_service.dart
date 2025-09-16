import '../models/video_content.dart';
import '../models/live_session.dart';
import '../models/tutor_profile.dart';
import 'sample_data_service.dart';

/// Service to mix videos and live sessions in the main feed
class FeedContentService {
  static const bool _useSampleData = true; // Always use sample data in demo

  /// Get mixed content feed (videos + live sessions)
  static Future<List<dynamic>> getMixedFeed({
    int limit = 10,
    int offset = 0,
  }) async {
    if (_useSampleData) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Get videos and live sessions
      final videos = SampleDataService.getFeedVideos();
      final liveSessions = SampleDataService.getLiveSessions();
      
      // Mix them together
      final mixedContent = <dynamic>[];
      mixedContent.addAll(videos);
      mixedContent.addAll(liveSessions);
      
      // Sort by creation date (newest first)
      mixedContent.sort((a, b) {
        DateTime aDate, bDate;
        
        if (a is VideoContent) {
          aDate = a.createdAt;
        } else if (a is LiveSession) {
          aDate = a.createdAt;
        } else {
          aDate = DateTime.now();
        }
        
        if (b is VideoContent) {
          bDate = b.createdAt;
        } else if (b is LiveSession) {
          bDate = b.createdAt;
        } else {
          bDate = DateTime.now();
        }
        
        return bDate.compareTo(aDate);
      });
      
      // Apply pagination
      final endIndex = (offset + limit).clamp(0, mixedContent.length);
      return mixedContent.sublist(offset, endIndex);
    }

    // Demo mode - always use sample data
    return [];
  }

  /// Get only videos from the feed
  static Future<List<VideoContent>> getVideoFeed({
    int limit = 10,
    int offset = 0,
  }) async {
    if (_useSampleData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final allVideos = SampleDataService.getFeedVideos();
      final endIndex = (offset + limit).clamp(0, allVideos.length);
      return allVideos.sublist(offset, endIndex);
    }
    return [];
  }

  /// Get only live sessions from the feed
  static Future<List<LiveSession>> getLiveSessionsFeed({
    int limit = 10,
    int offset = 0,
  }) async {
    if (_useSampleData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final allSessions = SampleDataService.getLiveSessions();
      final endIndex = (offset + limit).clamp(0, allSessions.length);
      return allSessions.sublist(offset, endIndex);
    }
    return [];
  }

  /// Get currently live sessions
  static Future<List<LiveSession>> getCurrentlyLiveSessions() async {
    if (_useSampleData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final allSessions = SampleDataService.getLiveSessions();
      return allSessions.where((session) => session.isLive).toList();
    }
    return [];
  }

  /// Get scheduled live sessions
  static Future<List<LiveSession>> getScheduledLiveSessions() async {
    if (_useSampleData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final allSessions = SampleDataService.getLiveSessions();
      return allSessions.where((session) => session.isScheduled).toList();
    }
    return [];
  }

  /// Join a live session
  static Future<bool> joinLiveSession(String sessionId, String userId) async {
    if (_useSampleData) {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));
      print('🎥 User $userId joined live session $sessionId');
      return true;
    }
    return false;
  }

  /// Leave a live session
  static Future<bool> leaveLiveSession(String sessionId, String userId) async {
    if (_useSampleData) {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      print('🎥 User $userId left live session $sessionId');
      return true;
    }
    return false;
  }

  /// Raise hand in a live session
  static Future<bool> raiseHand(String sessionId, String userId, String userName) async {
    if (_useSampleData) {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      print('✋ User $userName raised hand in session $sessionId');
      return true;
    }
    return false;
  }

  /// Lower hand in a live session
  static Future<bool> lowerHand(String sessionId, String userId) async {
    if (_useSampleData) {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      print('✋ User $userId lowered hand in session $sessionId');
      return true;
    }
    return false;
  }

  /// Send message in live session
  static Future<bool> sendMessage(
    String sessionId,
    String userId,
    String userName,
    String message,
  ) async {
    if (_useSampleData) {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 200));
      print('💬 User $userName sent message in session $sessionId: $message');
      return true;
    }
    return false;
  }

  /// Get live session messages
  static Future<List<LiveSessionMessage>> getLiveSessionMessages(String sessionId) async {
    if (_useSampleData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return SampleDataService.getLiveSessionMessages(sessionId);
    }
    return [];
  }

  /// Get raised hands for a live session
  static Future<List<RaisedHand>> getRaisedHands(String sessionId) async {
    if (_useSampleData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return SampleDataService.getRaisedHands(sessionId);
    }
    return [];
  }

  /// Approve a raised hand
  static Future<bool> approveRaisedHand(String sessionId, String handId) async {
    if (_useSampleData) {
      await Future.delayed(const Duration(milliseconds: 500));
      print('✅ Raised hand $handId approved in session $sessionId');
      return true;
    }
    return false;
  }

  /// Reject a raised hand
  static Future<bool> rejectRaisedHand(String sessionId, String handId) async {
    if (_useSampleData) {
      await Future.delayed(const Duration(milliseconds: 500));
      print('❌ Raised hand $handId rejected in session $sessionId');
      return true;
    }
    return false;
  }
}
