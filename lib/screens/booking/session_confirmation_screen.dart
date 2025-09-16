import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/constants.dart';
import '../../services/google_meet_service.dart';
import '../../services/email_service.dart';
import '../../models/tutor_profile.dart';
import '../../models/user.dart' as app_user;
import '../feed/video_feed_screen.dart';

class SessionConfirmationScreen extends StatefulWidget {
  final String sessionId;
  final TutorProfile tutor;
  final app_user.User student;
  final String subject;
  final DateTime sessionTime;
  final int durationMinutes;
  final double price;
  final String meetLink;
  final int? currentVideoIndex; // Add current video index

  const SessionConfirmationScreen({
    super.key,
    required this.sessionId,
    required this.tutor,
    required this.student,
    required this.subject,
    required this.sessionTime,
    required this.durationMinutes,
    required this.price,
    required this.meetLink,
    this.currentVideoIndex,
  });

  @override
  State<SessionConfirmationScreen> createState() => _SessionConfirmationScreenState();
}

class _SessionConfirmationScreenState extends State<SessionConfirmationScreen> {
  bool _isLoading = false;
  bool _emailsSent = false;

  @override
  void initState() {
    super.initState();
    _sendBookingEmails();
  }

  Future<void> _sendBookingEmails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Send email to student
      await EmailService.sendStudentBookingConfirmation(
        student: widget.student,
        tutor: widget.tutor,
        subject: widget.subject,
        sessionTime: widget.sessionTime,
        durationMinutes: widget.durationMinutes,
        meetLink: widget.meetLink,
      );

      // Send email to tutor
      await EmailService.sendTutorBookingConfirmation(
        student: widget.student,
        tutor: widget.tutor,
        subject: widget.subject,
        sessionTime: widget.sessionTime,
        durationMinutes: widget.durationMinutes,
        meetLink: widget.meetLink,
      );

      setState(() {
        _emailsSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking confirmation emails sent to you and your tutor!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send emails: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            // Navigate back to the main video feed screen with current video index
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => VideoFeedScreen(
                  initialIndex: widget.currentVideoIndex ?? 0,
                ),
              ),
              (route) => false,
            );
          },
          icon: const Icon(Icons.close, color: AppConstants.textPrimary),
        ),
        title: const Text(
          'Session Confirmed',
          style: TextStyle(
            color: AppConstants.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Session Booked Successfully!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll receive a confirmation email shortly',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Session details
            _buildSection(
              title: 'Session Details',
              children: [
                _buildDetailRow('Tutor', widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor'),
                _buildDetailRow('Subject', widget.subject),
                _buildDetailRow('Date', _formatDate(widget.sessionTime)),
                _buildDetailRow('Time', _formatTime(widget.sessionTime)),
                _buildDetailRow('Duration', '${widget.durationMinutes} minutes'),
                _buildDetailRow('Price', '£${widget.price.toStringAsFixed(2)}'),
              ],
            ),

            const SizedBox(height: 32),

            // Add to Calendar button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _addToCalendar,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.calendar_today),
                label: Text(_isLoading ? 'Adding to Calendar...' : 'Add to Calendar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Email confirmation status
            if (_emailsSent)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.green),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Confirmation emails sent to you and your tutor!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppConstants.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _addToCalendar() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final event = GoogleCalendarEvent(
        id: widget.sessionId,
        title: '${widget.subject} Tutoring Session - ${widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor'}',
        description: 'Tutoring session for ${widget.subject}\n\nGoogle Meet Link: ${widget.meetLink}',
        startTime: widget.sessionTime,
        endTime: widget.sessionTime.add(Duration(minutes: widget.durationMinutes)),
        meetLink: widget.meetLink,
        attendees: [
          CalendarAttendee(
            email: 'tutor@tutorhouse.co.uk', // Mock email
            name: widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor',
            role: 'organizer',
          ),
          CalendarAttendee(
            email: widget.student.email,
            name: widget.student.fullName,
            role: 'attendee',
          ),
        ],
        location: 'Google Meet',
        reminders: [
          const CalendarReminder(minutes: 15, type: 'popup'),
          const CalendarReminder(minutes: 60, type: 'email'),
        ],
      );

      final calendarUrl = GoogleMeetService.createCalendarInviteUrl(event);
      final uri = Uri.parse(calendarUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calendar event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Could not open calendar app');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to calendar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

