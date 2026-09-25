import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocale { hindi, english }

class LocaleNotifier extends StateNotifier<AppLocale> {
  LocaleNotifier() : super(AppLocale.hindi); // Default Hindi for rural artisan equity

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
    // Brand & Top Navigation
    'app_name': {
      'hi': 'कलासेतु',
      'en': 'KalaSetu',
    },
    'tagline': {
      'hi': 'कारीगर मंच',
      'en': 'Artisan Platform',
    },
    'header_fairs_subtitle': {
      'hi': 'कलासेतु शिल्प मेले',
      'en': 'Craft Fairs & Haats',
    },
    'header_voice_subtitle': {
      'hi': 'बोलकर जोड़ें',
      'en': 'Voice Add',
    },
    'header_camera_subtitle': {
      'hi': 'कैमरा सूची',
      'en': 'Camera Listing',
    },

    // Bottom Navigation Bar - Artisan & Customer
    'nav_home': {
      'hi': 'होम',
      'en': 'Home',
    },
    'nav_voice': {
      'hi': 'बोलकर जोड़ें',
      'en': 'Voice Scribe',
    },
    'nav_voice_short': {
      'hi': 'आवाज़',
      'en': 'Voice',
    },
    'nav_add': {
      'hi': 'जोड़ें',
      'en': 'Add',
    },
    'nav_fairs': {
      'hi': 'मेले',
      'en': 'Fairs',
    },
    'nav_orders': {
      'hi': 'ऑर्डर',
      'en': 'Orders',
    },
    'nav_earnings': {
      'hi': 'कमाई',
      'en': 'Earnings',
    },
    'nav_profile': {
      'hi': 'प्रोफ़ाइल',
      'en': 'Profile',
    },
    'nav_crafts': {
      'hi': 'शिल्प',
      'en': 'Crafts',
    },
    'nav_cart': {
      'hi': 'कार्ट',
      'en': 'Cart',
    },
    'nav_account': {
      'hi': 'खाता',
      'en': 'Account',
    },

    // Auth & Login
    'login': {
      'hi': 'लॉग इन करें',
      'en': 'Sign In',
    },
    'login_subtitle': {
      'hi': 'अपने पंजीकृत मोबाइल नंबर से प्रवेश करें',
      'en': 'Sign in with your registered mobile number',
    },
    'phone_number': {
      'hi': 'मोबाइल नंबर दर्ज करें',
      'en': 'Enter Mobile Number',
    },
    'phone_placeholder': {
      'hi': '98765 43210',
      'en': '98765 43210',
    },
    'phone_error': {
      'hi': 'कृपया 10 अंकों का मान्य मोबाइल नंबर दर्ज करें',
      'en': 'Please enter a valid 10-digit mobile number',
    },
    'send_otp': {
      'hi': 'ओटीपी भेजें',
      'en': 'Send OTP',
    },
    'or_divider': {
      'hi': 'या / OR',
      'en': 'OR',
    },
    'continue_google': {
      'hi': 'Google के साथ आगे बढ़ें',
      'en': 'Sign in with Google',
    },
    'need_account': {
      'hi': 'नया खाता बनाना है? ',
      'en': "Don't have an account? ",
    },
    'signup_link': {
      'hi': 'खाता बनाएं (Sign Up)',
      'en': 'Create Account',
    },
    'select_language': {
      'hi': 'भाषा चुनें',
      'en': 'Select Language',
    },

    // Signup Screen
    'signup': {
      'hi': 'नया खाता बनाएं',
      'en': 'Create Account',
    },
    'signup_subtitle': {
      'hi': 'कलासेतु समुदाय से जुड़ें और अपनी शिल्प यात्रा शुरू करें',
      'en': 'Join KalaSetu and start your handcrafted artisan journey',
    },
    'full_name': {
      'hi': 'पूरा नाम',
      'en': 'Full Name',
    },
    'continue_btn': {
      'hi': 'आगे बढ़ें',
      'en': 'Continue',
    },
    'already_have_account': {
      'hi': 'पहले से खाता है? लॉगिन करें',
      'en': 'Already have an account? Sign In',
    },

    // OTP Verify Screen
    'otp_title': {
      'hi': 'ओटीपी सत्यापन',
      'en': 'OTP Verification',
    },
    'enter_otp': {
      'hi': '६ अंकों का ओटीपी दर्ज करें',
      'en': 'Enter 6-Digit OTP',
    },
    'otp_sent_to': {
      'hi': 'पर भेजा गया 6 अंकों का कोड दर्ज करें',
      'en': 'Enter the 6-digit code sent to',
    },
    'verify': {
      'hi': 'सत्यापित करें',
      'en': 'Verify',
    },
    'resend_otp': {
      'hi': 'ओटीपी पुनः भेजें',
      'en': 'Resend OTP',
    },
    'resend_in': {
      'hi': 'पुनः कोड भेजें:',
      'en': 'Resend code in:',
    },
    'seconds': {
      'hi': 'सेकंड',
      'en': 'seconds',
    },
    'invalid_otp': {
      'hi': 'अमान्य ओटीपी कोड',
      'en': 'Invalid OTP Code',
    },

    // Role Selection
    'role_title': {
      'hi': 'भूमिका चुनें',
      'en': 'Select Role',
    },
    'how_to_use': {
      'hi': 'आप ऐप का उपयोग कैसे करना चाहते हैं?',
      'en': 'How would you like to use the app?',
    },
    'i_am_artisan': {
      'hi': 'मैं एक कारीगर हूं',
      'en': "I'm an Artisan",
    },
    'i_am_artisan_badge': {
      'hi': 'हिंदी-प्रथम • कैमरा व आवाज',
      'en': 'Vernacular-First • Camera & Voice',
    },
    'i_am_artisan_desc': {
      'hi': 'सामान बेचना, मेले देखना और आवाज से सूची बनाना',
      'en': 'Sell crafts, join fairs, voice & camera listing tools',
    },
    'i_am_customer': {
      'hi': 'मैं कला प्रेमी / खरीदार हूं',
      'en': "I'm a Customer / Buyer",
    },
    'i_am_customer_badge': {
      'hi': 'मार्केटप्लेस • क्राफ्ट क्लस्टर',
      'en': 'Marketplace • Craft Clusters',
    },
    'i_am_customer_desc': {
      'hi': 'सीधे ग्रामीण कारीगरों से प्रामाणिक हस्तशिल्प खरीदें',
      'en': 'Discover authentic handcrafted art directly from artisans',
    },

    // Artisan Home
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
    'pause': {
      'hi': 'रुकें',
      'en': 'Pause',
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
      'en': "Today's Overview",
    },
    'view_details': {
      'hi': 'विवरण देखें',
      'en': 'View Details',
    },
    'period_today': {
      'hi': 'आज',
      'en': 'Today',
    },
    'period_week': {
      'hi': 'सप्ताह',
      'en': 'Week',
    },
    'today_earnings': {
      'hi': 'आज की कमाई',
      'en': "Today's Earnings",
    },
    'new_orders': {
      'hi': 'ऑर्डर मिले',
      'en': 'Orders Received',
    },
    'orders_count_4': {
      'hi': '४ नए',
      'en': '4 New',
    },
    'craft_fairs': {
      'hi': 'शिल्प मेले',
      'en': 'Craft Fairs',
    },
    'fairs_count_2': {
      'hi': '२ मेले',
      'en': '2 Fairs',
    },
    'available_in_shop': {
      'hi': 'दुकान में उपलब्ध',
      'en': 'Available in Shop',
    },
    'view_all': {
      'hi': 'सब देखें',
      'en': 'View All',
    },
    'stock_left': {
      'hi': 'बचे',
      'en': 'Left',
    },
    'direct_help': {
      'hi': 'सीधी सहायता',
      'en': 'Direct Support',
    },
    'free': {
      'hi': 'मुफ्त',
      'en': 'Free',
    },
    'talk_to_craft_friend': {
      'hi': '१८००-२००-८८९९ • शिल्प मित्र से बात करें',
      'en': '1800-200-8899 • Speak with Craft Friend',
    },

    // Fairs Screen
    'govt_support_badge': {
      'hi': 'सीधा सरकारी सहयोग',
      'en': 'Direct Govt Support',
    },
    'fairs_heading': {
      'hi': 'शिल्प मेले',
      'en': 'Craft Fairs & Haats',
    },
    'fairs_subheading': {
      'hi': 'अपने हस्तशिल्प को देश-विदेश के बड़े मंचों तक पहुंचाएं',
      'en': 'Connect your handcrafted arts with major national & international exhibitions',
    },
    'fairs_search_placeholder': {
      'hi': 'शहर, शिल्प या मेले का नाम खोजें...',
      'en': 'Search city, craft or fair name...',
    },
    'tab_upcoming_fairs': {
      'hi': 'आगामी मेले',
      'en': 'Upcoming Fairs',
    },
    'tab_my_applications': {
      'hi': 'मेरे आवेदन',
      'en': 'My Applications',
    },
    'tab_govt_subsidies': {
      'hi': 'सरकारी अनुदान',
      'en': 'Govt Schemes',
    },
    'expected_visitors_label': {
      'hi': 'अनुमानित दर्शक',
      'en': 'Expected Footfall',
    },
    'apply_now': {
      'hi': 'आवेदन करें',
      'en': 'Apply Now',
    },
    'applied': {
      'hi': 'आवेदन हुआ',
      'en': 'Applied',
    },
    'need_help_form': {
      'hi': 'फॉर्म भरने में सहायता चाहिए?',
      'en': 'Need help filling applications?',
    },
    'help_desc_fairs': {
      'hi': 'कलासेतु मित्र केंद्र से निःशुल्क आवेदन सहायता व दस्तावेज़ सत्यापन प्राप्त करें।',
      'en': 'Get free application support & document verification from KalaSetu Mitra Kendra.',
    },
    'talk_artisan_helpline': {
      'hi': 'कारीगर हेल्पलाइन से बात करें',
      'en': 'Artisan Helpline Call',
    },
    'voice_search_tooltip': {
      'hi': 'बोलकर मेला खोजें',
      'en': 'Voice Search Fairs',
    },
    'listening_voice': {
      'hi': 'हम सुन रहे हैं...',
      'en': 'Listening now...',
    },
    'voice_search_prompt': {
      'hi': 'बोलिए "दिल्ली के मेले" या "सूरजकुंड"',
      'en': 'Say "Delhi fairs" or "Surajkund"',
    },
    'application_submitted': {
      'hi': 'आवेदन जमा हुआ',
      'en': 'Application Submitted',
    },
    'application_note': {
      'hi': 'आपके पंजीकृत शिल्पी पहचान पत्र के आधार पर आवेदन अग्रसारित कर दिया गया है। 48 घंटे में एसएमएस द्वारा सूचना प्राप्त होगी।',
      'en': 'Your application has been forwarded using your verified artisan ID. You will receive an SMS confirmation within 48 hours.',
    },
    'modal_thanks': {
      'hi': 'ठीक है, धन्यवाद',
      'en': 'Understood, Thank You',
    },

    // Camera Add Item Screen
    'center_craft_hint': {
      'hi': 'सामान को बीच में रखें',
      'en': 'Center item in frame',
    },
    'good_light': {
      'hi': 'अच्छी रोशनी',
      'en': 'Good lighting',
    },
    'craft_mode': {
      'hi': 'हस्तशिल्प मोड',
      'en': 'Craft Mode',
    },
    'balanced': {
      'hi': 'संतुलित',
      'en': 'Balanced',
    },
    'lighting_tip': {
      'hi': 'दीया या खिड़की के पास रखें',
      'en': 'Place near window or lamp',
    },
    'gallery': {
      'hi': 'गैलरी',
      'en': 'Gallery',
    },
    'voice_add_btn': {
      'hi': 'बोलकर जोड़ें',
      'en': 'Add by Voice',
    },
    'flash_off': {
      'hi': 'बंद',
      'en': 'Off',
    },
    'flash_on': {
      'hi': 'चालू',
      'en': 'On',
    },
    'flash_auto': {
      'hi': 'स्वतः',
      'en': 'Auto',
    },
    'artisan_tip_title': {
      'hi': 'कारीगर सलाह',
      'en': 'Artisan Tip',
    },
    'artisan_tip_desc': {
      'hi': 'मिट्टी की सतह और बनावट को साफ दिखाने के लिए छाया से बचें।',
      'en': 'Avoid harsh shadows to capture natural clay surface and texture.',
    },

    // Voice Scribe / Voice Product Screen
    'voice_scribe_badge': {
      'hi': 'आवाज से विवरण',
      'en': 'Voice Scribe',
    },
    'voice_scribe_title': {
      'hi': 'बोलिए, हम लिख लेंगे',
      'en': "Speak, We'll Write for You",
    },
    'voice_scribe_subtitle': {
      'hi': 'स्वाभाविक रूप से बोलें, हम खरीदारों के लिए आपकी कहानी तैयार करेंगे',
      'en': 'Speak naturally, we will create your story for buyers',
    },
    'listening_status': {
      'hi': 'सुन रहे हैं...',
      'en': 'Listening...',
    },
    'paused_status': {
      'hi': 'रुका हुआ',
      'en': 'Paused',
    },
    'live_scribe': {
      'hi': 'सीधा श्रुतलेख',
      'en': 'Live Scribe',
    },
    'dialect_tag': {
      'hi': 'हिंदी (महेश्वर)',
      'en': 'Hindi (Maheshwar)',
    },
    'transcription_sample': {
      'hi': '“मैं महेश्वर में पारंपरिक हाथ की बनी चंदेरी और सूती साड़ियाँ बनाता हूँ। इसमें प्राकृतिक नील और हल्दी के रंगों का प्रयोग किया गया है...”',
      'en': '“I craft traditional handwoven Chanderi and cotton sarees in Maheshwar, using authentic natural indigo and turmeric vegetable dyes...”',
    },
    'tag_saree': {
      'hi': 'साड़ी',
      'en': 'Sarees',
    },
    'tag_natural_dyes': {
      'hi': 'प्राकृतिक रंग',
      'en': 'Natural Dyes',
    },
    'tag_maheshwar': {
      'hi': 'महेश्वर',
      'en': 'Maheshwar',
    },
    'photo_attached': {
      'hi': 'तस्वीर जोड़ी गई',
      'en': 'Photo Attached',
    },
    'photo_attached_desc': {
      'hi': 'महेश्वरी हैंडलूम टेक्सटाइल #04',
      'en': 'Maheshwari Handloom Textile #04',
    },
    're_record': {
      'hi': 'फिर से बोलें',
      'en': 'Re-record',
    },
    'pause_btn': {
      'hi': 'रोकें',
      'en': 'Pause',
    },
    'resume_btn': {
      'hi': 'जारी रखें',
      'en': 'Resume',
    },
    'done_btn': {
      'hi': 'पूरा हुआ',
      'en': 'Done',
    },
    'saved_btn': {
      'hi': 'सहेजा गया!',
      'en': 'Saved!',
    },
    'done_hint': {
      'hi': 'अपनी डिजिटल उत्पाद कथा बनाने के लिए "पूरा हुआ" पर टैप करें',
      'en': 'Tap Done to automatically create your digital product story',
    },

    // Voice Onboarding Screen
    'voice_onboarding_badge': {
      'hi': 'स्वर परिचय',
      'en': 'Voice Onboarding',
    },
    'voice_onboarding_title': {
      'hi': 'मुझे अपने बारे में बताएं',
      'en': 'Tell me about yourself',
    },
    'voice_onboarding_subtitle': {
      'hi': 'आपका नाम, आपका शिल्प, और आपका गाँव',
      'en': 'Your name, your craft, and your village',
    },
    'hold_to_speak': {
      'hi': 'दबाकर बोलें',
      'en': 'Hold to Speak',
    },
    'speak_action': {
      'hi': 'बोलें',
      'en': 'Speak',
    },
    'hold_hint': {
      'hi': 'माइक्रोफ़ोन को दबाए रखें और बोलना शुरू करें',
      'en': 'Hold down the microphone and start speaking',
    },
    'release_hint': {
      'hi': 'बोलना समाप्त करने पर उँगली उठाएँ',
      'en': 'Release to finish speaking',
    },
    'voice_recorded': {
      'hi': 'आवाज़ दर्ज की गई!',
      'en': 'Voice recorded!',
    },
    'voice_processing': {
      'hi': 'पुष्टि हो रही है... कृपया प्रतीक्षा करें',
      'en': 'Processing... please wait',
    },
    'artisan_help_title': {
      'hi': 'कारीगर सहायता',
      'en': 'Artisan Assistance',
    },
    'artisan_help_desc': {
      'hi': 'खुल कर बोलें, अपनी भाषा में',
      'en': 'Speak freely, in your own language',
    },
    'prefer_typing': {
      'hi': 'लिखकर भरना चाहते हैं?',
      'en': 'Prefer to type instead?',
    },
    'fill_standard_form': {
      'hi': 'साधारण फ़ॉर्म भरें',
      'en': 'Fill out standard form',
    },

    // Artisan Profile Screen
    'profile_title': {
      'hi': 'कारीगर प्रोफ़ाइल',
      'en': 'Artisan Profile',
    },
    'gi_card_number': {
      'hi': 'जी.आई. कार्ड संख्या: UP/TERRA/2021/8492',
      'en': 'GI Card No: UP/TERRA/2021/8492',
    },
    'experience_years': {
      'hi': '२४ वर्ष अनुभव',
      'en': '24 Years Exp.',
    },
    'active_items_count': {
      'hi': '१८ शिल्प उपलब्ध',
      'en': '18 Items Listed',
    },
    'artisan_story_heading': {
      'hi': 'मेरी शिल्पकला और कहानी',
      'en': 'My Craft & Heritage Story',
    },
    'artisan_story_text': {
      'hi': 'गोरखपुर के पारंपरिक टेराकोटा शिल्प में 3 पीढ़ियों से हमारा परिवार लगा हुआ है। प्राकृतिक नदी किनारे की चिकनी मिट्टी और हाथ की चाक से हम कलश, हाथी-घोड़े और सजावटी दीप बनाते हैं।',
      'en': 'Our family has preserved the traditional Gorakhpur Terracotta craft for three generations. Using fine riverbank clay and hand-spun wooden potter wheels, we craft auspicious earthen vessels, sculptures, and lamps.',
    },
    'profile_actions_heading': {
      'hi': 'त्वरित सेवाएं व सेटिंग्स',
      'en': 'Quick Services & Settings',
    },
    'update_voice_intro': {
      'hi': 'स्वर परिचय सुनें या बदलें',
      'en': 'Update Voice Introduction',
    },
    'update_voice_intro_desc': {
      'hi': 'खरीदारों के लिए अपनी आवाज में परिचय रिकॉर्ड करें',
      'en': 'Re-record your audio story for global buyers',
    },
    'switch_to_buyer': {
      'hi': 'खरीदार ट्रैक पर जाएं',
      'en': 'Switch to Customer Track',
    },
    'switch_to_buyer_desc': {
      'hi': 'हस्तशिल्प और अन्य कारीगरों के उत्पाद देखें',
      'en': 'Browse handicraft catalog as a customer',
    },
    'app_language': {
      'hi': 'ऐप की भाषा (Language)',
      'en': 'App Language',
    },
    'helpline_support': {
      'hi': 'कारीगर सहायता केंद्र',
      'en': 'Artisan Support Desk',
    },
    'helpline_support_desc': {
      'hi': 'टोल-फ्री १८००-२००-८८९९ पर तुरंत बात करें',
      'en': 'Toll-free 1800-200-8899 instant support',
    },
    'logout': {
      'hi': 'लॉग आउट करें',
      'en': 'Sign Out',
    },

    // Earnings & Orders
    'earnings_title': {
      'hi': 'कमाई व भुगतान',
      'en': 'Earnings & Payouts',
    },
    'available_balance': {
      'hi': 'कुल प्राप्य राशि',
      'en': 'Available Balance',
    },
    'bank_account': {
      'hi': 'बैंक खाता: SBI •••• 4892',
      'en': 'Bank Account: SBI •••• 4892',
    },
    'wednesday_payout': {
      'hi': 'प्रत्येक बुधवार भुगतान',
      'en': 'Payout Every Wednesday',
    },
    'weekly_history': {
      'hi': 'साप्ताहिक कमाई का इतिहास',
      'en': 'Weekly Earnings History',
    },
    'week_current': {
      'hi': 'सप्ताह ८ (वर्तमान)',
      'en': 'Week 8 (Current)',
    },
    'week_prev': {
      'hi': 'सप्ताह',
      'en': 'Week',
    },
    'orders_count_label': {
      'hi': 'ऑर्डर',
      'en': 'orders',
    },
    'orders_title': {
      'hi': 'ऑर्डर व ग्राहक',
      'en': 'Orders & Customers',
    },
    'no_orders': {
      'hi': 'कोई नया ऑर्डर नहीं है',
      'en': 'No new orders right now',
    },
    'no_orders_desc': {
      'hi': 'नए ऑर्डर आने पर आपको तुरंत सूचना मिलेगी',
      'en': 'You will be notified immediately when new orders arrive',
    },
    'customer_label': {
      'hi': 'ग्राहक',
      'en': 'Customer',
    },
    'quantity_label': {
      'hi': 'मात्रा',
      'en': 'Qty',
    },
    'total_label': {
      'hi': 'कुल',
      'en': 'Total',
    },

    // Pricing & Fair Pay
    'pricing_title': {
      'hi': 'मूल्य निर्धारण',
      'en': 'Pricing & Fair Pay',
    },
    'fair_price_guarantee': {
      'hi': 'कारीगर न्यायसंगत मूल्य गारंटी: आपकी मेहनत और सामग्री की उचित कीमत सुरक्षित की जाती है। कलासेतु कोई छुपा कमीशन नहीं लेता।',
      'en': 'Artisan Fair-Price Guarantee: Ensures your materials and handcraft labor are protected. KalaSetu takes 0 hidden platform fees.',
    },
    'cost_breakdown_title': {
      'hi': 'लागत और समय',
      'en': 'Cost & Labor Breakdown',
    },
    'raw_material_label': {
      'hi': 'कच्चा माल (सिल्क, रंग, धागा):',
      'en': 'Raw Materials (Clay, Dye, Thread):',
    },
    'labor_time_label': {
      'hi': 'बुनने का समय',
      'en': 'Crafting Labor Time',
    },
    'artisan_margin_label': {
      'hi': 'कारीगर लाभ मार्जिन (25% न्यूनतम):',
      'en': 'Artisan Margin (25% Min.):',
    },
    'margin_guarantee_badge': {
      'hi': '+ २५% गारंटी',
      'en': '+ 25% Guaranteed',
    },
    'suggested_price_label': {
      'hi': 'सुझाया गया विक्रय मूल्य:',
      'en': 'Suggested Selling Price:',
    },
    'stock_quantity_label': {
      'hi': 'उपलब्ध संख्या',
      'en': 'Stock Quantity',
    },
    'publish_item_btn': {
      'hi': 'दुकान में प्रकाशित करें',
      'en': 'Publish Item to Shop',
    },
    'publish_success_title': {
      'hi': 'उत्पाद सफलतापूर्वक प्रकाशित!',
      'en': 'Product Published Successfully!',
    },
    'publish_success_desc': {
      'hi': 'आपकी वस्तु अब दुकान और देश भर के खरीदारों को दिखाई दे रही है।',
      'en': 'Your craft is now live in your shop and visible to buyers across India.',
    },
    'back_to_home_btn': {
      'hi': 'दुकान में देखें',
      'en': 'View in Shop & Home',
    },

    // Marketplace & Customer
    'marketplace_search_hint': {
      'hi': 'शिल्प, साड़ी, मटका या पीतल खोजें...',
      'en': 'Search pottery, saree, brass, silk...',
    },
    'b2b_wholesale_title': {
      'hi': 'थोक खरीददार (B2B Bulk Orders)',
      'en': 'Wholesale Buyers (B2B Bulk Orders)',
    },
    'b2b_wholesale_subtitle': {
      'hi': 'सीधे शिल्प क्लस्टर से भारी छूट पर आर्डर करें',
      'en': 'Order directly from craft clusters at bulk discounts',
    },
    'get_quote_btn': {
      'hi': 'कोटेशन लें',
      'en': 'Get Quote',
    },
    'craft_clusters_title': {
      'hi': 'शिल्प क्लस्टर',
      'en': 'Craft Clusters',
    },
    'all_cluster_filter': {
      'hi': 'सभी',
      'en': 'All',
    },
    'featured_crafts_title': {
      'hi': 'विशेष हस्तशिल्प',
      'en': 'Featured Handcrafts',
    },
    'gi_tagged_badge': {
      'hi': 'प्रमाणित जी.आई. शिल्प',
      'en': 'Certified GI Craft',
    },
    'craft_detail_title': {
      'hi': 'शिल्प विवरण',
      'en': 'Craft Details',
    },
    'product_not_found': {
      'hi': 'उत्पाद नहीं मिला',
      'en': 'Product Not Found',
    },
    'artisan_story_label': {
      'hi': 'शिल्प कथा',
      'en': 'The Artisan Story',
    },
    'add_to_cart_btn': {
      'hi': 'कार्ट में जोड़ें',
      'en': 'Add to Cart',
    },
    'added_to_cart_msg': {
      'hi': 'कार्ट में जोड़ा गया!',
      'en': 'Added to cart!',
    },
    'craft_cart_title': {
      'hi': 'शिल्प कार्ट',
      'en': 'Craft Cart',
    },
    'cart_empty_title': {
      'hi': 'आपकी कार्ट खाली है',
      'en': 'Your Cart is Empty',
    },
    'cart_empty_subtitle': {
      'hi': 'कारीगरों की कलाकृतियों को कार्ट में जोड़ें',
      'en': 'Discover handcrafted treasures and add to cart',
    },
    'shop_crafts_btn': {
      'hi': 'शिल्प देखें',
      'en': 'Shop Crafts',
    },
    'order_summary_title': {
      'hi': 'ऑर्डर सारांश',
      'en': 'Order Summary',
    },
    'subtotal_label': {
      'hi': 'उपकुल',
      'en': 'Subtotal',
    },
    'delivery_label': {
      'hi': 'डिलीवरी (कारीगर से सीधा)',
      'en': 'Delivery (Direct from artisan)',
    },
    'free_label': {
      'hi': 'निःशुल्क',
      'en': 'Free',
    },
    'checkout_btn': {
      'hi': 'सुरक्षित भुगतान करें',
      'en': 'Secure Checkout',
    },
    'b2b_request_title': {
      'hi': 'थोक खरीद',
      'en': 'B2B Bulk Request',
    },
    'b2b_banner_note': {
      'hi': 'कॉर्पोरेट उपहार व निर्यात हेतु सीधे ग्रामीण कारीगर क्लस्टर से थोक भाव पर संपर्क करें।',
      'en': 'Connect directly with rural craft clusters at wholesale rates for corporate gifting and exports.',
    },

    // Photo Review & AI Review
    'photo_review_title': {
      'hi': 'फोटो समीक्षा',
      'en': 'Photo Review',
    },
    'original_photo_tab': {
      'hi': 'मूल फोटो',
      'en': 'Original Photo',
    },
    'ai_studio_tab': {
      'hi': 'स्टूडियो पृष्ठभूमि (AI Studio)',
      'en': 'Studio Backdrop (AI Studio)',
    },
    'studio_treatment_note': {
      'hi': 'पृष्ठभूमि स्वतः साफ की गई है ताकि खरीदार केवल आपकी कारीगरी पर ध्यान दें।',
      'en': 'Background cleaned automatically to showcase your authentic handcraft.',
    },
    'retake_btn': {
      'hi': 'दोबारा खींचें',
      'en': 'Retake Photo',
    },
    'next_btn': {
      'hi': 'आगे बढ़ें',
      'en': 'Next Step',
    },
    'ai_review_title': {
      'hi': 'विवरण समीक्षा',
      'en': 'AI Description Review',
    },
    'ai_review_banner': {
      'hi': 'आपकी आवाज से स्वतः हिंदी व अंग्रेजी में विवरण तैयार किया गया है। आवश्यकतानुसार बदलाव कर सकते हैं।',
      'en': 'Bilingual descriptions generated automatically from your voice. You can edit any details as needed.',
    },
    'hindi_desc_title': {
      'hi': 'हिंदी विवरण',
      'en': 'Hindi Description (Artisan)',
    },
    'hindi_title_label': {
      'hi': 'उत्पाद का नाम (हिंदी)',
      'en': 'Craft Title (Hindi)',
    },
    'hindi_desc_label': {
      'hi': 'विस्तृत शिल्प कथा (हिंदी)',
      'en': 'Craft Story (Hindi)',
    },
    'english_desc_title': {
      'hi': 'अंग्रेजी विवरण (खरीदारों के लिए)',
      'en': 'English Description (For Buyers)',
    },
    'english_title_label': {
      'hi': 'उत्पाद का नाम (अंग्रेजी)',
      'en': 'Craft Title (English)',
    },
    'english_desc_label': {
      'hi': 'विस्तृत शिल्प कथा (अंग्रेजी)',
      'en': 'Craft Story for Global Buyers',
    },
    'craft_attributes_title': {
      'hi': 'पहचाने गए शिल्प गुण',
      'en': 'Identified Craft Attributes',
    },
    'set_pricing_btn': {
      'hi': 'मूल्य निर्धारण पर जाएं',
      'en': 'Set Fair Pricing',
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
