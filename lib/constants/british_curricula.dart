class BritishCurricula {
  // Simple, clear subject names
  static const List<String> subjects = [
    'GCSE Maths',
    'A-Level Maths',
    'GCSE English',
    'A-Level English',
    'GCSE Physics',
    'A-Level Physics',
    'GCSE Chemistry',
    'A-Level Chemistry',
    'GCSE Biology',
    'A-Level Biology',
    'GCSE History',
    'A-Level History',
    'GCSE Geography',
    'A-Level Geography',
    'GCSE French',
    'A-Level French',
    'GCSE Spanish',
    'A-Level Spanish',
    'GCSE German',
    'A-Level German',
    'GCSE Economics',
    'A-Level Economics',
    'GCSE Business',
    'A-Level Business',
    'GCSE Psychology',
    'A-Level Psychology',
    'GCSE Computer Science',
    'A-Level Computer Science',
    'GCSE Art',
    'A-Level Art',
    'GCSE Music',
    'A-Level Music',
  ];

  // British year levels (simple and clear)
  static const List<String> yearLevels = [
    'Year 7',
    'Year 8',
    'Year 9',
    'Year 10',
    'Year 11',
    'Year 12',
    'Year 13',
  ];

  // Currency options for different markets
  static const List<Map<String, dynamic>> currencies = [
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'AED', 'symbol': 'AED ', 'name': 'UAE Dirham'},
    {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
  ];

  // Get currency symbol by code
  static String getCurrencySymbol(String currencyCode) {
    final currency = currencies.firstWhere(
      (c) => c['code'] == currencyCode.toUpperCase(),
      orElse: () => currencies.first,
    );
    return currency['symbol'] as String;
  }

  // Get currency name by code
  static String getCurrencyName(String currencyCode) {
    final currency = currencies.firstWhere(
      (c) => c['code'] == currencyCode.toUpperCase(),
      orElse: () => currencies.first,
    );
    return currency['name'] as String;
  }

  // Get suggested pricing for different markets
  static Map<String, Map<String, double>> getSuggestedPricing() {
    return {
      'GBP': {'min': 20.0, 'max': 40.0}, // UK
      'USD': {'min': 25.0, 'max': 50.0}, // US/International
      'AED': {'min': 90.0, 'max': 180.0}, // UAE
      'SGD': {'min': 35.0, 'max': 70.0}, // Singapore
      'EUR': {'min': 22.0, 'max': 45.0}, // Europe
    };
  }
}
