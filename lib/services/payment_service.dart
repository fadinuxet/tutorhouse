import '../config/stripe_config.dart';

class PaymentService {
  static bool _isInitialized = false;

  /// Initialize payment service (Demo mode)
  static Future<bool> initialize() async {
    try {
      // For demo mode, we'll skip real payment initialization
      _isInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create a payment intent for a booking (Demo mode)
  static Future<PaymentIntent?> createPaymentIntent({
    required String tutorId,
    required double amount,
    required String currency,
    required String description,
  }) async {
    if (!_isInitialized) {
      return null;
    }

    // Demo mode - return mock payment intent
    return PaymentIntent(
      id: 'pi_demo_${DateTime.now().millisecondsSinceEpoch}',
      amount: (amount * 100).round(),
      currency: currency,
      status: PaymentIntentStatus.RequiresPaymentMethod,
      clientSecret: 'pi_demo_${DateTime.now().millisecondsSinceEpoch}_secret',
    );
  }

  /// Process a payment for a booking (Demo mode)
  static Future<PaymentResult> processPayment({
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    // Demo mode - simulate successful payment
    await Future.delayed(const Duration(seconds: 2));
    
    return PaymentResult.success(
      paymentIntentId: paymentIntentId,
      amount: 2500, // Demo amount
      currency: 'gbp',
    );
  }

  /// Create a payment method (card) (Demo mode)
  static Future<PaymentMethod?> createPaymentMethod({
    required CardDetails cardDetails,
  }) async {
    // Demo mode - return mock payment method
    await Future.delayed(const Duration(seconds: 1));
    
    return PaymentMethod(
      id: 'pm_demo_${DateTime.now().millisecondsSinceEpoch}',
      type: PaymentMethodType.card,
      card: PaymentMethodCard(
        brand: 'visa',
        last4: cardDetails.number.substring(cardDetails.number.length - 4),
        expMonth: cardDetails.expiryMonth,
        expYear: cardDetails.expiryYear,
      ),
    );
  }

  /// Calculate platform fee
  static double calculatePlatformFee(double amount) {
    return amount * StripeConfig.platformFeePercentage;
  }

  /// Calculate tutor payout
  static double calculateTutorPayout(double amount) {
    return amount - calculatePlatformFee(amount);
  }

  /// Get supported payment methods
  static List<PaymentMethodType> getSupportedPaymentMethods() {
    return [
      PaymentMethodType.card,
    ];
  }
}

/// Payment result class
class PaymentResult {
  final bool isSuccess;
  final String? paymentIntentId;
  final int? amount;
  final String? currency;
  final String? error;

  PaymentResult._({
    required this.isSuccess,
    this.paymentIntentId,
    this.amount,
    this.currency,
    this.error,
  });

  factory PaymentResult.success({
    required String paymentIntentId,
    required int amount,
    required String currency,
  }) {
    return PaymentResult._(
      isSuccess: true,
      paymentIntentId: paymentIntentId,
      amount: amount,
      currency: currency,
    );
  }

  factory PaymentResult.failure({required String error}) {
    return PaymentResult._(
      isSuccess: false,
      error: error,
    );
  }
}

/// Card details class
class CardDetails {
  final String number;
  final int expiryMonth;
  final int expiryYear;
  final String cvc;
  final String name;
  final String email;

  CardDetails({
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
    required this.name,
    required this.email,
  });
}

/// Payment Intent class (Demo)
class PaymentIntent {
  final String id;
  final int amount;
  final String currency;
  final PaymentIntentStatus status;
  final String clientSecret;

  PaymentIntent({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.clientSecret,
  });
}

/// Payment Intent Status enum (Demo)
enum PaymentIntentStatus {
  RequiresPaymentMethod,
  RequiresConfirmation,
  RequiresAction,
  Processing,
  Succeeded,
  RequiresCapture,
  Canceled,
}

/// Payment Method class (Demo)
class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final PaymentMethodCard? card;

  PaymentMethod({
    required this.id,
    required this.type,
    this.card,
  });
}

/// Payment Method Type enum (Demo)
enum PaymentMethodType {
  card,
  applePay,
  googlePay,
}

/// Payment Method Card class (Demo)
class PaymentMethodCard {
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;

  PaymentMethodCard({
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
  });
}
