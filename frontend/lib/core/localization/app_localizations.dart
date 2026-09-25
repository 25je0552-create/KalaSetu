import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocale { hindi, english }

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier() : super(AppLocale.hindi); // Hindi-first default for artisans

  void toggleLocale() {
    state = state == AppLocale.hindi ? AppLocale.english : AppLocale.hindi;
  }

  void setLocale(AppLocale locale) {
    state = locale;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>((ref) {
  return LocaleNotifier();
});

class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    'app_name': {
      'hi': 'कलासेतु',
      'en': 'KalaSetu',
    },
    'tagline': {
      'hi': 'कारीगर मंच',
      'en': 'Artisan Platform',
    },
    'certified_badge': {
      'hi': 'प्रमाणित हस्तशिल्पी',
      'en': 'Certified Artisan',
    },
    'greeting_ramesh': {
      'hi': 'नमस्ते, रमेश',
      'en': 'Namaste, Ramesh',
    },
    'artisan_craft': {
      'hi': 'माटी शिल्पी, गोरखपुर',
      'en': 'Clay Artisan, Gorakhpur',
    },
    'listen': {
      'hi': 'सुनें',
      'en': 'Listen',
    },
    'open_camera': {
      'hi': 'कैमरा खोलें',
      'en': 'Open Camera',
    },
    'add_new_item': {
      'hi': 'नया सामान जोड़ें',
      'en': 'Add New Item',
    },
    'camera_desc': {
      'hi': 'फोटो खींचकर उत्पाद की सूची बनाएं',
      'en': 'Take a photo to list your handicraft',
    },
    'add_by_voice': {
      'hi': 'बोलकर जोड़ें',
      'en': 'Add by Voice',
    },
    'speak_story': {
      'hi': 'सामान या कहानी बोलें',
      'en': 'Speak Item or Story',
    },
    'voice_desc': {
      'hi': 'अपनी बोली में मिट्टी के काम का विवरण दें',
      'en': 'Describe your work in your native dialect',
    },
    'today_summary': {
      'hi': 'आज का लेखा-जोखा',
      'en': "Today's Ledger",
    },
    'view_details': {
      'hi': 'विवरण देखें',
      'en': 'View Details',
    },
    'today_earnings': {
      'hi': 'आज की कमाई',
      'en': "Today's Earnings",
    },
    'new_orders': {
      'hi': 'ऑर्डर मिले',
      'en': 'New Orders',
    },
    'craft_fairs': {
      'hi': 'शिल्प मेले',
      'en': 'Craft Fairs',
    },
    'available_in_shop': {
      'hi': 'दुकान में उपलब्ध',
      'en': 'Available in Studio',
    },
    'view_all': {
      'hi': 'सब देखें',
      'en': 'View All',
    },
    'direct_help': {
      'hi': 'सीधी सहायता',
      'en': 'Direct Assistance',
    },
    'free': {
      'hi': 'मुफ्त',
      'en': 'Free',
    },
    'talk_to_craft_friend': {
      'hi': '१८००-२००-८८९९ • शिल्प मित्र से बात करें',
      'en': '1800-200-8899 • Speak with Shilp Mitra',
    },
    'nav_home': {
      'hi': 'होम',
      'en': 'Home',
    },
    'nav_add': {
      'hi': 'जोड़ें',
      'en': 'Add Item',
    },
    'nav_earnings': {
      'hi': 'कमाई',
      'en': 'Earnings',
    },
    'nav_fairs': {
      'hi': 'मेले',
      'en': 'Fairs',
    },
    'nav_account': {
      'hi': 'खाता',
      'en': 'Account',
    },
    'login': {
      'hi': 'लॉग इन करें',
      'en': 'Sign In',
    },
    'signup': {
      'hi': 'नया खाता बनाएं',
      'en': 'Create Account',
    },
    'phone_number': {
      'hi': 'मोबाइल नंबर दर्ज करें',
      'en': 'Enter Mobile Number',
    },
    'send_otp': {
      'hi': 'ओटीपी भेजें',
      'en': 'Send OTP',
    },
    'continue_google': {
      'hi': 'Google के साथ आगे बढ़ें',
      'en': 'Sign in with Google',
    },
    'enter_otp': {
      'hi': '६ अंकों का ओटीपी दर्ज करें',
      'en': 'Enter 6-Digit OTP',
    },
    'verify': {
      'hi': 'सत्यापित करें',
      'en': 'Verify',
    },
    'resend_otp': {
      'hi': 'ओटीपी पुनः भेजें',
      'en': 'Resend OTP',
    },
    'i_am_artisan': {
      'hi': 'मैं एक कारीगर हूं',
      'en': "I'm an Artisan",
    },
    'i_am_artisan_desc': {
      'hi': 'सामान बेचना, मेले देखना और आवाज से सूची बनाना',
      'en': 'Sell crafts, join fairs, voice & camera tools',
    },
    'i_am_customer': {
      'hi': 'मैं कला प्रेमी / खरीदार हूं',
      'en': "I'm a Customer / Buyer",
    },
    'i_am_customer_desc': {
      'hi': 'सीधे ग्रामीण कारीगरों से प्रामाणिक हस्तशिल्प खरीदें',
      'en': 'Discover authentic crafts directly from artisans',
    },
  };

  static String get(String key, AppLocale locale) {
    final lang = locale == AppLocale.hindi ? 'hi' : 'en';
    return _strings[key]?[lang] ?? _strings[key]?['hi'] ?? key;
  }
}

extension AppLocaleX on WidgetRef {
  String tr(String key) {
    final locale = watch(localeProvider);
    return AppStrings.get(key, locale);
  }
}
