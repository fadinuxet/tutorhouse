import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/constants.dart';
import '../../services/payment_service.dart';
import '../../services/google_meet_service.dart';
import '../../services/booking_service.dart';
import '../../services/auth_service.dart';
import '../../main.dart';
import '../../models/tutor_profile.dart';
import '../../models/user.dart' as app_user;
import 'session_confirmation_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final TutorProfile tutor;
  final String subject;
  final int durationMinutes;
  final double totalAmount;
  final DateTime selectedDateTime;
  final int? currentVideoIndex;

  const PaymentScreen({
    super.key,
    required this.tutor,
    required this.subject,
    required this.durationMinutes,
    required this.totalAmount,
    required this.selectedDateTime,
    this.currentVideoIndex,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isProcessing = false;
  bool _isApplePayAvailable = false;
  bool _isGooglePayAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentMethods();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _checkPaymentMethods() async {
    // Check if Apple Pay and Google Pay are available
    setState(() {
      _isApplePayAvailable = true; // Demo - would check actual availability
      _isGooglePayAvailable = true; // Demo - would check actual availability
    });
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create payment method
      final cardDetails = CardDetails(
        number: _cardNumberController.text.replaceAll(' ', ''),
        expiryMonth: int.parse(_expiryController.text.split('/')[0]),
        expiryYear: int.parse('20${_expiryController.text.split('/')[1]}'),
        cvc: _cvcController.text,
        name: _nameController.text,
        email: _emailController.text,
      );

      final paymentMethod = await PaymentService.createPaymentMethod(
        cardDetails: cardDetails,
      );

      if (paymentMethod == null) {
        throw Exception('Failed to create payment method');
      }

      // Create payment intent
      final paymentIntent = await PaymentService.createPaymentIntent(
        tutorId: widget.tutor.id,
        amount: widget.totalAmount,
        currency: 'GBP',
        description: '${widget.subject} session with ${widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor'}',
      );

      if (paymentIntent == null) {
        throw Exception('Failed to create payment intent');
      }

      // Process payment
      final result = await PaymentService.processPayment(
        paymentIntentId: paymentIntent.id,
        paymentMethodId: paymentMethod.id,
      );

      if (result.isSuccess) {
        // Payment successful
        _showSuccessDialog();
      } else {
        // Payment failed
        _showErrorDialog(result.error ?? 'Payment failed');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog() async {
    // Generate Google Meet link
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final meetLink = GoogleMeetService.generateMeetLink(
      sessionId: sessionId,
      tutorName: widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor',
      subject: widget.subject,
      sessionTime: widget.selectedDateTime,
    );

    // Get current user or create demo student
    app_user.User student;
    if (AuthService.isAuthenticated && AuthService.currentUser != null) {
      student = AuthService.currentUser!;
    } else {
      student = app_user.User(
        id: 'demo_student_${DateTime.now().millisecondsSinceEpoch}',
        email: _emailController.text.isNotEmpty ? _emailController.text : 'student@tutorhouse.com',
        fullName: _nameController.text.isNotEmpty ? _nameController.text : 'Demo Student',
        userType: app_user.UserType.student,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    // Create booking in the system
    
    final bookingResult = await BookingService.createBooking(
      studentId: student.id,
      tutorId: widget.tutor.id,
      subject: widget.subject,
      sessionTime: widget.selectedDateTime,
      durationMinutes: widget.durationMinutes,
      price: widget.totalAmount,
      isTrial: widget.totalAmount == 0.0, // Free trials
      meetLink: meetLink,
    );
    
    
    // Debug: Check all bookings
    BookingService.getAllBookings();

    if (!bookingResult['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingResult['message']),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update TutorProvider if this is a trial booking
    if (widget.totalAmount == 0.0) {
      final tutor = ref.read(tutorProvider);
      await tutor.bookTrialWithTutor(widget.tutor.id, widget.selectedDateTime);
    }

    // Navigate to session confirmation screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SessionConfirmationScreen(
          sessionId: sessionId,
          tutor: widget.tutor,
          student: student,
          subject: widget.subject,
          sessionTime: widget.selectedDateTime,
          durationMinutes: widget.durationMinutes,
          price: widget.totalAmount,
          meetLink: meetLink,
          currentVideoIndex: widget.currentVideoIndex,
        ),
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              'Payment Failed',
              style: TextStyle(color: AppConstants.textPrimary),
            ),
          ],
        ),
        content: Text(
          error,
          style: TextStyle(color: AppConstants.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Try Again',
              style: TextStyle(color: AppConstants.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If it's a free trial, skip payment and go directly to confirmation
    if (widget.totalAmount == 0.0) {
      return _buildFreeTrialConfirmation();
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Session Summary',
                      style: TextStyle(
                        color: AppConstants.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Tutor', widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor'),
                    _buildSummaryRow('Subject', widget.subject),
                    _buildSummaryRow('Duration', '${widget.durationMinutes} minutes'),
                    _buildSummaryRow('Date', '${widget.selectedDateTime.day}/${widget.selectedDateTime.month}/${widget.selectedDateTime.year}'),
                    _buildSummaryRow('Time', '${widget.selectedDateTime.hour.toString().padLeft(2, '0')}:${widget.selectedDateTime.minute.toString().padLeft(2, '0')}'),
                    const Divider(color: AppConstants.textSecondary),
                    _buildSummaryRow('Total', '£${widget.totalAmount.toStringAsFixed(2)}', isTotal: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment methods
              const Text(
                'Payment Method',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Apple Pay / Google Pay buttons
              if (_isApplePayAvailable || _isGooglePayAvailable) ...[
                if (_isApplePayAvailable)
                  _buildPaymentButton(
                    icon: Icons.apple,
                    label: 'Pay with Apple Pay',
                    onTap: () {
                      // TODO: Implement Apple Pay
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Apple Pay not implemented yet')),
                      );
                    },
                  ),
                if (_isGooglePayAvailable)
                  _buildPaymentButton(
                    icon: Icons.g_mobiledata,
                    label: 'Pay with Google Pay',
                    onTap: () {
                      // TODO: Implement Google Pay
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Google Pay not implemented yet')),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppConstants.textSecondary)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: AppConstants.textSecondary),
                      ),
                    ),
                    Expanded(child: Divider(color: AppConstants.textSecondary)),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Card details form
              const Text(
                'Card Details',
                style: TextStyle(
                  color: AppConstants.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Card number
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.replaceAll(' ', '').length < 16) {
                    return 'Please enter a valid card number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  // Expiry date
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                          return 'MM/YY format';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // CVC
                  Expanded(
                    child: TextFormField(
                      controller: _cvcController,
                      decoration: InputDecoration(
                        labelText: 'CVC',
                        hintText: '123',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 3) {
                          return 'Invalid CVC';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Cardholder name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  hintText: 'John Doe',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cardholder name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'john@example.com',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Pay button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: AppConstants.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Pay £${widget.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Security notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your payment is secure and encrypted. We use Stripe for payment processing.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppConstants.textSecondary,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppConstants.textPrimary,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 24),
          label: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppConstants.primaryColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFreeTrialConfirmation() {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.surfaceColor,
        elevation: 0,
        title: const Text(
          'Free Trial',
          style: TextStyle(color: AppConstants.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppConstants.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppConstants.primaryColor,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Free Trial Booked!',
              style: TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Your 30-minute free trial with ${widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor'} is confirmed.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Session details
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.surfaceColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Tutor', widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor'),
                  _buildDetailRow('Subject', widget.subject),
                  _buildDetailRow('Date', '${widget.selectedDateTime.day}/${widget.selectedDateTime.month}/${widget.selectedDateTime.year}'),
                  _buildDetailRow('Time', '${widget.selectedDateTime.hour.toString().padLeft(2, '0')}:${widget.selectedDateTime.minute.toString().padLeft(2, '0')}'),
                  _buildDetailRow('Duration', '${widget.durationMinutes} minutes'),
                  _buildDetailRow('Price', 'FREE'),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Generate Google Meet link and navigate to confirmation
                  final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
                  final meetLink = GoogleMeetService.generateMeetLink(
                    sessionId: sessionId,
                    tutorName: widget.tutor.bio?.split(' ').take(2).join(' ') ?? 'Tutor',
                    subject: widget.subject,
                    sessionTime: widget.selectedDateTime,
                  );

                  // Create demo student user
                  final student = app_user.User(
                    id: 'demo_student_${DateTime.now().millisecondsSinceEpoch}',
                    email: 'student@tutorhouse.com',
                    fullName: 'Demo Student',
                    userType: app_user.UserType.student,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  // Navigate to session confirmation screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => SessionConfirmationScreen(
                        sessionId: sessionId,
                        tutor: widget.tutor,
                        student: student,
                        subject: widget.subject,
                        sessionTime: widget.selectedDateTime,
                        durationMinutes: widget.durationMinutes,
                        price: widget.totalAmount,
                        meetLink: meetLink,
                        currentVideoIndex: widget.currentVideoIndex,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to Session',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppConstants.textSecondary,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppConstants.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
