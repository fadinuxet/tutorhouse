import 'package:flutter_stripe/flutter_stripe.dart';

class StripeConfig {
  static const String publishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  static const String secretKey = 'YOUR_STRIPE_SECRET_KEY'; // Server-side only
  
  // Platform fee percentage (15%)
  static const double platformFeePercentage = 0.15;
  
  // Currency
  static const String currency = 'GBP';
  
  // Initialize Stripe
  static Future<void> initialize() async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }
}
