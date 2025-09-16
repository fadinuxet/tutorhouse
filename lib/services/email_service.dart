import '../models/tutor_profile.dart';
import '../models/user.dart' as app_user;

class EmailService {
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();

  // Send booking confirmation email to student
  static Future<bool> sendStudentBookingConfirmation({
    required app_user.User student,
    required TutorProfile tutor,
    required String subject,
    required DateTime sessionTime,
    required int durationMinutes,
    required String meetLink,
  }) async {
    try {
      // In production, this would integrate with an email service like SendGrid, AWS SES, etc.
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      final emailContent = _generateStudentEmailContent(
        student: student,
        tutor: tutor,
        subject: subject,
        sessionTime: sessionTime,
        durationMinutes: durationMinutes,
        meetLink: meetLink,
      );
      
      print('📧 Email sent to student: ${student.email}');
      print('Subject: ${emailContent.subject}');
      print('Content: ${emailContent.body}');
      
      return true;
    } catch (e) {
      print('Error sending student email: $e');
      return false;
    }
  }

  // Send booking confirmation email to tutor
  static Future<bool> sendTutorBookingConfirmation({
    required app_user.User student,
    required TutorProfile tutor,
    required String subject,
    required DateTime sessionTime,
    required int durationMinutes,
    required String meetLink,
  }) async {
    try {
      // In production, this would integrate with an email service
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      final emailContent = _generateTutorEmailContent(
        student: student,
        tutor: tutor,
        subject: subject,
        sessionTime: sessionTime,
        durationMinutes: durationMinutes,
        meetLink: meetLink,
      );
      
      print('📧 Email sent to tutor: ${tutor.userId}@tutorhouse.co.uk');
      print('Subject: ${emailContent.subject}');
      print('Content: ${emailContent.body}');
      
      return true;
    } catch (e) {
      print('Error sending tutor email: $e');
      return false;
    }
  }

  // Generate student email content
  static EmailContent _generateStudentEmailContent({
    required app_user.User student,
    required TutorProfile tutor,
    required String subject,
    required DateTime sessionTime,
    required int durationMinutes,
    required String meetLink,
  }) {
    final tutorName = tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor';
    final sessionDate = _formatDate(sessionTime);
    final sessionTimeFormatted = _formatTime(sessionTime);
    
    return EmailContent(
      to: student.email,
      subject: 'Trial Session Confirmed - $subject with $tutorName',
      body: '''
Hello ${student.fullName},

Your free trial session has been confirmed! 🎉

Session Details:
• Tutor: $tutorName
• Subject: $subject
• Date: $sessionDate
• Time: $sessionTimeFormatted
• Duration: $durationMinutes minutes
• Price: FREE

Google Meet Link:
$meetLink

What to expect:
• A 30-minute free trial session
• Introduction to your tutor's teaching style
• Discussion of your learning goals
• Q&A about the subject

Please join the session 5 minutes early to test your audio and video.

If you have any questions, please contact us at support@tutorhouse.co.uk

Best regards,
The Tutorhouse Team
      ''',
    );
  }

  // Generate tutor email content
  static EmailContent _generateTutorEmailContent({
    required app_user.User student,
    required TutorProfile tutor,
    required String subject,
    required DateTime sessionTime,
    required int durationMinutes,
    required String meetLink,
  }) {
    final tutorName = tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor';
    final sessionDate = _formatDate(sessionTime);
    final sessionTimeFormatted = _formatTime(sessionTime);
    
    return EmailContent(
      to: '${tutor.userId}@tutorhouse.co.uk', // Mock tutor email
      subject: 'New Trial Session Booking - $subject with ${student.fullName}',
      body: '''
Hello $tutorName,

You have a new trial session booking! 📚

Session Details:
• Student: ${student.fullName}
• Student Email: ${student.email}
• Subject: $subject
• Date: $sessionDate
• Time: $sessionTimeFormatted
• Duration: $durationMinutes minutes
• Type: Free Trial

Google Meet Link:
$meetLink

Student Information:
• Name: ${student.fullName}
• Email: ${student.email}
• Session Type: Free Trial

Please prepare for the session and join 5 minutes early to welcome your student.

If you have any questions, please contact us at support@tutorhouse.co.uk

Best regards,
The Tutorhouse Team
      ''',
    );
  }

  // Format date for email
  static String _formatDate(DateTime dateTime) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  // Format time for email
  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// Email content model
class EmailContent {
  final String to;
  final String subject;
  final String body;

  const EmailContent({
    required this.to,
    required this.subject,
    required this.body,
  });
}
