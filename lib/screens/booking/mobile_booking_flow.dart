import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../config/constants.dart';
import '../../models/video_content.dart';
import '../../models/tutor_profile.dart';
import '../../services/sample_data_service.dart';
import '../../services/booking_service.dart';
import '../../services/auth_service.dart';
import 'payment_screen.dart';

class MobileBookingFlow extends StatefulWidget {
  final VideoContent video;
  final int? currentVideoIndex;

  const MobileBookingFlow({
    super.key,
    required this.video,
    this.currentVideoIndex,
  });

  @override
  State<MobileBookingFlow> createState() => _MobileBookingFlowState();
}

class _MobileBookingFlowState extends State<MobileBookingFlow> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late final TutorProfile? _tutor;
  Set<DateTime> _availableDates = {};

  @override
  void initState() {
    super.initState();
    _tutor = SampleDataService.getTutorById(widget.video.tutorId);
    _loadAvailableDates();
  }

  void _loadAvailableDates() {
    
    if (_tutor?.availability != null) {
      final now = DateTime.now();
      final availableDates = <DateTime>{};
      
      // Generate available dates for the next 30 days
      for (int i = 0; i < 30; i++) {
        final date = now.add(Duration(days: i));
        // Normalize to midnight for consistent comparison
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final dayName = _getDayName(date.weekday);
        
        // Check if tutor is available on this day
        if (_tutor!.availability!.containsKey(dayName) && 
            _tutor!.availability![dayName]!.isNotEmpty) {
          availableDates.add(normalizedDate);
        }
      }
      
      
      setState(() {
        _availableDates = availableDates;
      });
    } else {
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppConstants.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Book Trial with ${_tutor?.bio?.split(' ').take(2).join(' ') ?? 'Tutor'}',
                  style: const TextStyle(
                    color: AppConstants.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '30-minute free trial • ${_tutor?.hourlyRateDisplay ?? '£25/hour'}',
                  style: const TextStyle(
                    color: AppConstants.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Calendar and Times
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Calendar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TableCalendar<dynamic>(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 30)),
                      focusedDay: _selectedDate ?? DateTime.now(),
                      selectedDayPredicate: (day) {
                        return isSameDay(_selectedDate, day);
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        // Normalize selected day to midnight for comparison
                        final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                        
                        
                        // Only allow selection of available dates
                        if (_availableDates.contains(normalizedSelectedDay)) {
                          setState(() {
                            _selectedDate = selectedDay;
                            _selectedTime = null; // Clear time when date changes
                          });
                        } else {
                        }
                      },
                      eventLoader: (day) {
                        // Normalize day to midnight for comparison
                        final normalizedDay = DateTime(day.year, day.month, day.day);
                        final isAvailable = _availableDates.contains(normalizedDay);
                        if (isAvailable) {
                          return ['available'];
                        }
                        return [];
                      },
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: const TextStyle(color: AppConstants.textSecondary),
                        defaultTextStyle: const TextStyle(color: AppConstants.textPrimary),
                        selectedDecoration: const BoxDecoration(
                          color: AppConstants.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppConstants.primaryColor.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        markersMaxCount: 1,
                        markerDecoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                        markerSize: 4,
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          // Normalize day to midnight for comparison
                          final normalizedDay = DateTime(day.year, day.month, day.day);
                          final isAvailable = _availableDates.contains(normalizedDay);
                          if (isAvailable) {
                            return Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.25),
                                  width: 0.8,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: Colors.green[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: AppConstants.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: AppConstants.textPrimary,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: AppConstants.textSecondary),
                        weekendStyle: TextStyle(color: AppConstants.textSecondary),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Calendar Legend
                  _buildCalendarLegend(),
                  
                  // Availability message
                  if (_availableDates.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This tutor has no available dates in the next 30 days. Please try another tutor.',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Available Times
                  if (_selectedDate != null) _buildAvailableTimes(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Book Button
          if (_selectedDate != null && _selectedTime != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _bookTrial,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Book Free Trial',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppConstants.textSecondary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Available dates
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Available',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Unavailable dates
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Unavailable',
                style: TextStyle(
                  color: AppConstants.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Selected date
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Selected',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableTimes() {
    final dayName = _getDayName(_selectedDate!.weekday);
    final availableTimes = _tutor?.availability?[dayName] as List<String>? ?? [];
    
    if (availableTimes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'No available times for this day',
          style: TextStyle(
            color: AppConstants.textSecondary,
            fontSize: 16,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Times',
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: availableTimes.map((time) {
              final isSelected = _selectedTime != null && 
                  _selectedTime!.format(context) == time;
              
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTime = TimeOfDay(
                        hour: int.parse(time.split(':')[0]),
                        minute: int.parse(time.split(':')[1]),
                      );
                    });
                  },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppConstants.primaryColor 
                        : AppConstants.backgroundColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isSelected 
                          ? AppConstants.primaryColor 
                          : AppConstants.textSecondary.withValues(alpha: 0.2),
                      width: isSelected ? 3 : 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppConstants.primaryColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ] : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        time,
                        style: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : AppConstants.textPrimary,
                          fontSize: isSelected ? 17 : 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: isSelected ? 0.5 : 0,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _bookTrial() {
    if (_tutor != null && _selectedDate != null && _selectedTime != null) {
      // Check if user is logged in
      if (!AuthService.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to book a trial session'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if user has already booked a trial with this tutor
      final currentUser = AuthService.currentUser;
      if (currentUser != null && !BookingService.canBookTrial(currentUser.id, _tutor!.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already booked a trial session with this tutor. You can only book one trial per tutor.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Navigate to payment screen (which will be free for trials)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            tutor: _tutor!,
            subject: widget.video.subject ?? 'Maths',
            selectedDateTime: DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            ),
            durationMinutes: 30, // Fixed 30-minute trial
            totalAmount: 0.0, // Free trial
            currentVideoIndex: widget.currentVideoIndex,
          ),
        ),
      );
    }
  }
}