import 'package:flutter/material.dart';

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
    LanguageItem(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    LanguageItem(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    LanguageItem(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    LanguageItem(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    LanguageItem(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    LanguageItem(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    LanguageItem(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
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
    'hi': {
      'appName': 'भारत मित्र',
      'tagline': 'शून्य कमीशन राइड, रेंटल और गृह सेवाएं',
      'navRide': 'राइड',
      'navServices': 'सेवाएं',
      'navTrips': 'बुकिंग',
      'navProfile': 'प्रोफ़ाइल',
      'commissionBanner': '0% कमीशन: पार्टनर को 100% सीधा भुगतान!',
      'bookRide': 'राइड बुक करें',
      'rentDrive': 'रेंट और ड्राइव',
      'homeServices': 'गृह सेवाएं',
      'hireDriver': 'ड्राइवर किराए पर लें',
      'searchCity': 'शहर खोजें (जैसे गोवा, मनाली, कोलकाता...)',
      'customerMode': 'मैं ग्राहक हूँ',
      'providerMode': 'मैं पार्टनर हूँ',
      'activeStatus': 'आप लाइव हैं - ग्राहक आपको देख सकते हैं',
      'offlineStatus': 'आप ऑफ़लाइन हैं',
      'ratingPrompt': 'सवारी पूरी हुई! ड्राइवर ने भुगतान की पुष्टि की। सेवा कैसी लगी?',
      'submitRating': 'रेटिंग जमा करें',
      'writeReview': 'समीक्षा लिखें (वैकल्पिक)',
      'fileComplaint': 'शिकायत दर्ज करें',
    },
    'bn': {
      'appName': 'ভারত মিত্র',
      'tagline': 'জিরো কমিশন রাইড, রেন্টাল ও সেবা',
      'navRide': 'রাইড',
      'navServices': 'সেবা',
      'navTrips': 'বুকিংস',
      'navProfile': 'প্রোফাইল',
      'commissionBanner': '০% কমিশন: সম্পূর্ণ পেমেন্ট সরাসরি পার্টনারের!',
      'bookRide': 'রাইড বুক করুন',
      'rentDrive': 'রেন্ট ও ড্রাইভ',
      'homeServices': 'হোম সার্ভিস',
      'hireDriver': 'ড্রাইভার হায়ার করুন',
      'searchCity': 'শহর খুঁজুন (যেমন দিঘা, দার্জিলিং, পুরী...)',
      'customerMode': 'আমি কাস্টমার',
      'providerMode': 'আমি পার্টনার',
      'activeStatus': 'আপনি লাইভ আছেন - পার্টি আপনাকে দেখতে পাবে',
      'offlineStatus': 'আপনি অফলাইন আছেন',
      'ratingPrompt': 'রাইড সম্পন্ন হয়েছে! ড্রাইভার পেমেন্ট পেয়েছে। সার্ভিস কেমন লাগলো?',
      'submitRating': 'রেটিং দিন',
      'writeReview': 'মতামত লিখুন (ঐচ্ছিক)',
      'fileComplaint': 'অভিযোগ জানান',
    },
    'ta': {
      'appName': 'பாரத் மித்ரா',
      'tagline': '0% கமிஷன் சவாரி, வாடகை மற்றும் சேவைகள்',
      'navRide': 'சவாரி',
      'navServices': 'சேவைகள்',
      'navTrips': 'முன்பதிவுகள்',
      'navProfile': 'சுயவிவரம்',
      'commissionBanner': '0% கமிஷன்: கூட்டாளருக்கு 100% நேரடி பணம்!',
      'bookRide': 'சவாரி பதிவு',
      'rentDrive': 'வாடகை & ஓட்டுநர்',
      'homeServices': 'வீட்டு சேவை',
      'hireDriver': 'ஓட்டுநர் நியமனம்',
      'searchCity': 'நகரத்தைத் தேடுங்கள் (கோவா, சென்னை...)',
      'customerMode': 'நான் வாடிக்கையாளர்',
      'providerMode': 'நான் கூட்டாளி',
      'activeStatus': 'நீங்கள் நேரலையில் உள்ளீர்கள்',
      'offlineStatus': 'நீங்கள் ஆஃப்லைனில் உள்ளீர்கள்',
      'ratingPrompt': 'சவாரி முடிந்தது! சேவை எப்படி இருந்தது?',
      'submitRating': 'மதிப்பீடு சமர்ப்பிக்கவும்',
      'writeReview': 'விமர்சனம் எழுதுங்கள்',
      'fileComplaint': 'புகார் பதிவு செய்யுங்கள்',
    },
    'te': {
      'appName': 'భారత్ మిత్ర',
      'tagline': '0% కమీషన్ రైడ్‌లు, రెంటల్స్ & సేవలు',
      'navRide': 'రైడ్',
      'navServices': 'సేవలు',
      'navTrips': 'బుకింగ్స్',
      'navProfile': 'ప్రొఫైల్',
      'commissionBanner': '0% కమీషన్: భాగస్వామికి 100% ప్రత్యక్ష చెల్లింపు!',
      'bookRide': 'రైడ్ బుక్ చేయండి',
      'rentDrive': 'రెంట్ & డ్రైవ్',
      'homeServices': 'హోమ్ సర్వీసెస్',
      'hireDriver': 'డ్రైవర్‌ను నియమించండి',
      'searchCity': 'నగరాన్ని శోధించండి (గోవా, హైదరాబాద్...)',
      'customerMode': 'నేను కస్టమర్',
      'providerMode': 'నేను ప్రొవైడర్',
      'activeStatus': 'మీరు లైవ్‌లో ఉన్నారు',
      'offlineStatus': 'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు',
      'ratingPrompt': 'రైడ్ పూర్తయింది! సర్వీస్ ఎలా ఉంది?',
      'submitRating': 'రేటింగ్ సమర్పించండి',
      'writeReview': 'సమీక్ష రాయండి',
      'fileComplaint': 'ఫిర్యాదు చేయండి',
    },
    'mr': {
      'appName': 'भारत मित्र',
      'tagline': 'शून्य कमिशन राइड, रेंटल आणि घरगुती सेवा',
      'navRide': 'राइड',
      'navServices': 'सेवा',
      'navTrips': 'बुकिंग',
      'navProfile': 'प्रोफाइल',
      'commissionBanner': '0% कमिशन: भागीदाराला 100% थेट देयक!',
      'bookRide': 'राइड बुक करा',
      'rentDrive': 'रेंट आणि ड्राइव्ह',
      'homeServices': 'घरगुती सेवा',
      'hireDriver': 'ड्रायव्हर घ्या',
      'searchCity': 'शहर शोधा (उदा. गोवा, मुंबई, पुणे...)',
      'customerMode': 'मी ग्राहक आहे',
      'providerMode': 'मी भागीदार आहे',
      'activeStatus': 'तुम्ही थेट ऑनलाइन आहात',
      'offlineStatus': 'तुम्ही ऑफलाइन आहात',
      'ratingPrompt': 'प्रवास पूर्ण झाला! सेवा कशी वाटली?',
      'submitRating': 'रेटिंग द्या',
      'writeReview': 'अभिप्राय लिहा',
      'fileComplaint': 'तक्रार नोंदवा',
    },
    'gu': {
      'appName': 'ભારત મિત્ર',
      'tagline': 'શૂન્ય કમિશન રાઇડ, ભાડું અને સેવાઓ',
      'navRide': 'રાઇડ',
      'navServices': 'સેવાઓ',
      'navTrips': 'બુકિંગ',
      'navProfile': 'પ્રોફાઇલ',
      'commissionBanner': '0% કમિશન: પાર્ટનરને 100% સીધું પેમેન્ટ!',
      'bookRide': 'રાઇડ બુક કરો',
      'rentDrive': 'રેન્ટ અને ડ્રાઇવ',
      'homeServices': 'હોમ સર્વિસ',
      'hireDriver': 'ડ્રાઇવર રાખો',
      'searchCity': 'શહેર શોધો (ગોવા, જયપુર, અમદાવાદ...)',
      'customerMode': 'હું ગ્રાહક છું',
      'providerMode': 'હું પાર્ટનર છું',
      'activeStatus': 'તમે લાઈવ છો',
      'offlineStatus': 'તમે ઑફલાઇન છો',
      'ratingPrompt': 'રાઇડ પૂર્ણ થઈ! સેવા કેવી લાગી?',
      'submitRating': 'રેટિંગ આપો',
      'writeReview': 'સમીક્ષા લખો',
      'fileComplaint': 'ફરિયાદ નોંધાવો',
    },
    'kn': {
      'appName': 'ಭಾರತ್ ಮಿತ್ರ',
      'tagline': '0% ಕಮಿಷನ್ ಸವಾರಿಗಳು ಮತ್ತು ಸೇವೆಗಳು',
      'navRide': 'ಸವಾರಿ',
      'navServices': 'ಸೇವೆಗಳು',
      'navTrips': 'ಬುಕಿಂಗ್‌ಗಳು',
      'navProfile': 'ಪ್ರೊಫೈಲ್',
      'commissionBanner': '0% ಕಮಿಷನ್: ಪಾಲುದಾರರಿಗೆ 100% ನೇರ ಪಾವತಿ!',
      'bookRide': 'ಸವಾರಿ ಬುಕ್ ಮಾಡಿ',
      'rentDrive': 'ಬಾಡಿಗೆ ಮತ್ತು ಡ್ರೈವ್',
      'homeServices': 'ಮನೆ ಸೇವೆಗಳು',
      'hireDriver': 'ಚಾಲಕರನ್ನು ನೇಮಿಸಿ',
      'searchCity': 'ನಗರವನ್ನು ಹುಡುಕಿ (ಗೋವಾ, ಬೆಂಗಳೂರು...)',
      'customerMode': 'ನಾನು ಗ್ರಾಹಕ',
      'providerMode': 'ನಾನು ಪಾಲುದಾರ',
      'activeStatus': 'ನೀವು ಲೈವ್ ಆಗಿದ್ದೀರಿ',
      'offlineStatus': 'ನೀವು ಆಫ್‌ಲೈನ್ ಆಗಿದ್ದೀರಿ',
      'ratingPrompt': 'ಸವಾರಿ ಪೂರ್ಣಗೊಂಡಿದೆ! ಸೇವೆ ಹೇಗಿತ್ತು?',
      'submitRating': 'ರೇಟಿಂಗ್ ಸಲ್ಲಿಸಿ',
      'writeReview': 'ವಿಮರ್ಶೆ ಬರೆಯಿರಿ',
      'fileComplaint': 'ದೂರು ನೀಡಿ',
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
