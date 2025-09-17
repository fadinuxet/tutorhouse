import 'dart:math';

class GoogleMeetService {
  static final GoogleMeetService _instance = GoogleMeetService._internal();
  factory GoogleMeetService() => _instance;
  GoogleMeetService._internal();

  // Generate a unique Google Meet link for a session
  static String generateMeetLink({
    required String sessionId,
    required String tutorName,
    required String subject,
    required DateTime sessionTime,
  }) {
    // For demo purposes, we'll generate a mock Google Meet link
    // In production, this would integrate with Google Calendar API
    final random = Random();
    final meetingId = _generateMeetingId();
    
    return 'https://meet.google.com/$meetingId';
  }

  // Generate a Google Calendar event with Google Meet link
  static GoogleCalendarEvent createCalendarEvent({
    required String sessionId,
    required String tutorName,
    required String studentName,
    required String subject,
    required DateTime startTime,
    required int durationMinutes,
    required String meetLink,
    required String tutorEmail,
    required String studentEmail,
  }) {
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    
    return GoogleCalendarEvent(
      id: sessionId,
      title: '$subject Tutoring Session - $tutorName',
      description: 'Tutoring session with $tutorName for $subject',
      startTime: startTime,
      endTime: endTime,
      meetLink: meetLink,
      attendees: [
        CalendarAttendee(
          email: tutorEmail,
          name: tutorName,
          role: 'organizer',
        ),
        CalendarAttendee(
          email: studentEmail,
          name: studentName,
          role: 'attendee',
        ),
      ],
      location: 'Google Meet',
      reminders: [
        CalendarReminder(minutes: 15, type: 'popup'),
        CalendarReminder(minutes: 60, type: 'email'),
      ],
    );
  }

  // Generate a meeting ID (mock implementation)
  static String _generateMeetingId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    final random = Random();
    // Generate 3 groups of 3-4 characters each, separated by hyphens
    final group1 = List.generate(3, (index) => chars[random.nextInt(chars.length)]).join();
    final group2 = List.generate(4, (index) => chars[random.nextInt(chars.length)]).join();
    final group3 = List.generate(3, (index) => chars[random.nextInt(chars.length)]).join();
    return '$group1-$group2-$group3';
  }

  // Create a calendar invite URL (for web)
  static String createCalendarInviteUrl(GoogleCalendarEvent event) {
    final startTime = _formatDateTimeForCalendar(event.startTime);
    final endTime = _formatDateTimeForCalendar(event.endTime);
    final title = Uri.encodeComponent(event.title);
    final description = Uri.encodeComponent(event.description);
    final location = Uri.encodeComponent(event.location);
    
    return 'https://calendar.google.com/calendar/render?action=TEMPLATE'
        '&text=$title'
        '&dates=$startTime/$endTime'
        '&details=$description'
        '&location=$location'
        '&trp=true'
        '&sprop=name:Tutorhouse'
        '&sprop=website:https://tutorhouse.co.uk';
  }

  // Format datetime for Google Calendar
  static String _formatDateTimeForCalendar(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String().replaceAll(RegExp(r'[-:]'), '').split('.')[0] + 'Z';
  }

  // Send calendar invites (mock implementation)
  static Future<bool> sendCalendarInvites(GoogleCalendarEvent event) async {
    // In production, this would:
    // 1. Create Google Calendar event via API
    // 2. Send email invites to attendees
    // 3. Add to tutor's calendar
    // 4. Add to student's calendar
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    
    
    return true;
  }

  // Get session reminder details
  static SessionReminder getSessionReminder({
    required DateTime sessionTime,
    required String tutorName,
    required String subject,
    required String meetLink,
  }) {
    final now = DateTime.now();
    final timeUntilSession = sessionTime.difference(now);
    
    return SessionReminder(
      sessionTime: sessionTime,
      tutorName: tutorName,
      subject: subject,
      meetLink: meetLink,
      timeUntilSession: timeUntilSession,
      isUpcoming: timeUntilSession.inMinutes > 0 && timeUntilSession.inHours < 24,
    );
  }
}

// Data models for Google Meet integration
class GoogleCalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String meetLink;
  final List<CalendarAttendee> attendees;
  final String location;
  final List<CalendarReminder> reminders;

  const GoogleCalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.meetLink,
    required this.attendees,
    required this.location,
    required this.reminders,
  });
}

class CalendarAttendee {
  final String email;
  final String name;
  final String role; // 'organizer' or 'attendee'

  const CalendarAttendee({
    required this.email,
    required this.name,
    required this.role,
  });
}

class CalendarReminder {
  final int minutes;
  final String type; // 'popup' or 'email'

  const CalendarReminder({
    required this.minutes,
    required this.type,
  });
}

class SessionReminder {
  final DateTime sessionTime;
  final String tutorName;
  final String subject;
  final String meetLink;
  final Duration timeUntilSession;
  final bool isUpcoming;

  const SessionReminder({
    required this.sessionTime,
    required this.tutorName,
    required this.subject,
    required this.meetLink,
    required this.timeUntilSession,
    required this.isUpcoming,
  });

  String get formattedTimeUntilSession {
    if (timeUntilSession.inDays > 0) {
      return '${timeUntilSession.inDays}d ${timeUntilSession.inHours % 24}h';
    } else if (timeUntilSession.inHours > 0) {
      return '${timeUntilSession.inHours}h ${timeUntilSession.inMinutes % 60}m';
    } else if (timeUntilSession.inMinutes > 0) {
      return '${timeUntilSession.inMinutes}m';
    } else {
      return 'Starting now';
    }
  }
}
