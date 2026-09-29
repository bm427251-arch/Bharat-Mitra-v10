class LanguageItem {
  final String code;
  final String name;
  final String nativeName;

  const LanguageItem({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

class AppTranslations {
  static const List<LanguageItem> supportedLanguages = [
    LanguageItem(code: 'en', name: 'English', nativeName: 'English'),
    LanguageItem(code: 'hi', name: 'Hindi', nativeName: 'Hindi'),
    LanguageItem(code: 'bn', name: 'Bengali', nativeName: 'Bangla'),
    LanguageItem(code: 'ta', name: 'Tamil', nativeName: 'Tamil'),
    LanguageItem(code: 'te', name: 'Telugu', nativeName: 'Telugu'),
    LanguageItem(code: 'mr', name: 'Marathi', nativeName: 'Marathi'),
    LanguageItem(code: 'gu', name: 'Gujarati', nativeName: 'Gujarati'),
    LanguageItem(code: 'kn', name: 'Kannada', nativeName: 'Kannada'),
  ];

  static String _currentLanguage = 'en';

  static String get currentLanguage => _currentLanguage;

  static void setLanguage(String code) {
    _currentLanguage = code;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Bharat Mitra',
      'tagline': 'Zero Commission Rides, Rentals & Home Services',
      'navRide': 'Ride',
      'navServices': 'Services',
      'navTrips': 'Bookings',
      'navProfile': 'Profile',
      'commissionBanner': '0% Commission: 100% Direct Cash/UPI Payment to Partner!',
      'bookRide': 'Book Ride',
      'rentDrive': 'Rent & Drive',
      'homeServices': 'Home Service',
      'serviceProvider': 'Service Provider',
      'hireDriver': 'Hire Driver',
      'searchCity': 'Search City (e.g. Digha, Goa, Manali, Kolkata...)',
      'customerMode': 'I am Customer',
      'providerMode': 'I am Provider',
      'activeStatus': 'You are Live - Party can see you',
      'offlineStatus': 'You are Offline',
      'ratingPrompt': 'Ride Completed! Driver confirmed payment received. How was the service?',
      'submitRating': 'Submit Rating',
      'writeReview': 'Write review (Optional)',
      'fileComplaint': 'File Complaint',
    },
  };

  static String tr(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

extension AppStringExtension on String {
  String trApp() {
    return AppTranslations.tr(this);
  }
}
