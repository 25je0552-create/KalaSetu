# KalaSetu Mobile Application — Log Messages Study Sheet

This document catalogs every `debugPrint` log message instrumented across the 27 presentation screens of the **KalaSetu** Flutter mobile application. It is designed for developer onboarding, QA verification, debugging, and production telemetry monitoring.

---

## 1. Logging Strategy & Tagging Architecture

Every log statement follows a structured, searchable convention:
```
[ScreenClassName] ActionOrEvent: Contextual parameters
```

### Filtering in Terminal or IDE
- **Filter by Screen**: `debugPrint('[ArtisanCameraScreen]')`
- **Filter by Flow**: `debugPrint('[LoginScreen]')`, `debugPrint('[ShopCatalogScreen]')`
- **Via Terminal (ADB/macOS/Linux/Windows PowerShell)**:
  ```powershell
  flutter logs | Select-String "\[Artisan"
  ```
  ```bash
  adb logcat -s flutter | grep "\["
  ```

---

## 2. Master Log Messages Reference Table

### Group 1: Auth, Roles & Onboarding (7 Screens)

| # | Screen Name | File Path | Event Trigger / Lifecycle | Log Message Pattern | Diagnostic / Study Purpose |
|---|---|---|---|---|---|
| 1 | **SplashScreen** | `features/auth/presentation/splash_screen.dart` | `initState` / App Mount | `[SplashScreen] Initializing splash screen...` | Tracks initial launch and cold start sequence. |
| 1 | **SplashScreen** | `features/auth/presentation/splash_screen.dart` | Auth Check (Authenticated) | `[SplashScreen] Authenticated user found (role: $role) -> routing to $destination` | Validates session persistence and role-based redirect. |
| 1 | **SplashScreen** | `features/auth/presentation/splash_screen.dart` | Auth Check (Unauthenticated) | `[SplashScreen] No session found -> navigating to /language` | Confirms onboarding kickoff for first-time / logged-out users. |
| 2 | **LanguageSelectScreen** | `features/auth/presentation/language_select_screen.dart` | `build` render | `[LanguageSelectScreen] Rendered. Selected: $selectedLocale` | Confirms locale detection on boot. |
| 2 | **LanguageSelectScreen** | `features/auth/presentation/language_select_screen.dart` | Language Option Tap | `[LanguageSelectScreen] Selected language: Hindi / English` | Captures language preference toggle. |
| 2 | **LanguageSelectScreen** | `features/auth/presentation/language_select_screen.dart` | Continue Button | `[LanguageSelectScreen] Language saved ($selectedLocale) -> navigating to /role-select` | Confirms locale state commit before role selection. |
| 3 | **RoleSelectScreen** | `features/auth/presentation/role_select_screen.dart` | `build` render | `[RoleSelectScreen] Rendered` | Tracks role selection screen presentation. |
| 3 | **RoleSelectScreen** | `features/auth/presentation/role_select_screen.dart` | Role Card Tap | `[RoleSelectScreen] Selected role: Artisan / Customer` | Captures user persona selection before login. |
| 3 | **RoleSelectScreen** | `features/auth/presentation/role_select_screen.dart` | Role Confirmation | `[RoleSelectScreen] Navigating to role destination: /login or /buyer/login` | Tracks bifurcation into Artisan or Buyer authentication flow. |
| 4 | **LoginScreen** (Artisan) | `features/auth/presentation/login_screen.dart` | Phone Validation Error | `[LoginScreen] Phone validation error: Phone number must be 10 digits` | Monitors validation drop-off points. |
| 4 | **LoginScreen** (Artisan) | `features/auth/presentation/login_screen.dart` | Send OTP Attempt | `[LoginScreen] Attempting OTP send for phone: $phone` | Diagnoses authentication network requests. |
| 4 | **LoginScreen** (Artisan) | `features/auth/presentation/login_screen.dart` | OTP Sent Success | `[LoginScreen] OTP sent successfully -> navigating to /otp-verify` | Confirms SMS gateway handshake. |
| 4 | **LoginScreen** (Artisan) | `features/auth/presentation/login_screen.dart` | OTP Failure | `[LoginScreen] Failed to send OTP: $error` | Error tracking for gateway failures. |
| 4 | **LoginScreen** (Artisan) | `features/auth/presentation/login_screen.dart` | Google Sign-In | `[LoginScreen] Google Sign-In tapped` | Monitors third-party OAuth entry. |
| 5 | **BuyerLoginScreen** | `features/auth/presentation/buyer_login_screen.dart` | Send OTP Attempt | `[BuyerLoginScreen] Attempting OTP send for phone: $phone` | Tracks buyer-specific authentication traffic. |
| 5 | **BuyerLoginScreen** | `features/auth/presentation/buyer_login_screen.dart` | OTP Sent Success | `[BuyerLoginScreen] OTP sent successfully -> navigating to /otp-verify` | Tracks buyer OTP routing. |
| 5 | **BuyerLoginScreen** | `features/auth/presentation/buyer_login_screen.dart` | Google Sign-In | `[BuyerLoginScreen] Google Sign-In tapped` | Tracks buyer OAuth login. |
| 6 | **SignupScreen** | `features/auth/presentation/signup_screen.dart` | Screen Render | `[SignupScreen] Rendered` | Monitors artisan self-registration funnel. |
| 6 | **SignupScreen** | `features/auth/presentation/signup_screen.dart` | Form Submission | `[SignupScreen] Submitting registration for name: $name, phone: $phone, craft: $craft` | Audits artisan registration inputs and craft taxonomy. |
| 7 | **OtpVerifyScreen** | `features/auth/presentation/otp_verify_screen.dart` | `initState` | `[OtpVerifyScreen] Initialized. Phone: $phone, destination: $destination` | Validates target parameters passed to verification view. |
| 7 | **OtpVerifyScreen** | `features/auth/presentation/otp_verify_screen.dart` | Verify Button | `[OtpVerifyScreen] Verifying code: $code for phone: $phone` | Tracks verification attempts. |
| 7 | **OtpVerifyScreen** | `features/auth/presentation/otp_verify_screen.dart` | Verification Success | `[OtpVerifyScreen] OTP verified successfully -> routing to $destination` | Confirms authentication grant and dashboard routing. |
| 7 | **OtpVerifyScreen** | `features/auth/presentation/otp_verify_screen.dart` | Verification Failure | `[OtpVerifyScreen] OTP verification failed: $error` | Captures wrong code or timeout errors. |
| 7 | **OtpVerifyScreen** | `features/auth/presentation/otp_verify_screen.dart` | Resend OTP | `[OtpVerifyScreen] Resending OTP to $phone` | Telemetry for OTP resend fatigue and SMS retry logic. |

---

### Group 2: Artisan Studio & Add Item Wizard (8 Screens)

| # | Screen Name | File Path | Event Trigger / Lifecycle | Log Message Pattern | Diagnostic / Study Purpose |
|---|---|---|---|---|---|
| 8 | **ArtisanHomeScreen** | `features/artisan_home/presentation/artisan_home_screen.dart` | `initState` | `[ArtisanHomeScreen] Initialized` | Verifies artisan home dashboard mount. |
| 8 | **ArtisanHomeScreen** | `features/artisan_home/presentation/artisan_home_screen.dart` | Audio Guide Toggle | `[ArtisanHomeScreen] Audio guide playback toggled: isPlaying=$isPlaying` | Tracks voice assistance usage among artisans. |
| 8 | **ArtisanHomeScreen** | `features/artisan_home/presentation/artisan_home_screen.dart` | Camera Hero Card | `[ArtisanHomeScreen] Camera hero card tapped -> /artisan/add-item/camera` | Funnel tracking: Start of product creation. |
| 8 | **ArtisanHomeScreen** | `features/artisan_home/presentation/artisan_home_screen.dart` | Metric Tile Click | `[ArtisanHomeScreen] Metric tile tapped: earnings / orders / fairs` | Telemetry for dashboard tile interest. |
| 8 | **ArtisanHomeScreen** | `features/artisan_home/presentation/artisan_home_screen.dart` | View All Crafts | `[ArtisanHomeScreen] View All Crafts tapped -> /artisan/shop-catalog/art_1` | Verifies catalog navigation fix. |
| 8 | **ArtisanHomeScreen** | `features/artisan_home/presentation/artisan_home_screen.dart` | Product Card Tap | `[ArtisanHomeScreen] Product tapped: id=$id, nameEn="$name"` | Tracks specific item management clicks. |
| 9 | **ShopCatalogScreen** | `features/artisan_home/presentation/shop_catalog_screen.dart` | `initState` | `[ShopCatalogScreen] Initialized for artisanId: $artisanId` | Validates shop ID mapping and catalog data loading. |
| 9 | **ShopCatalogScreen** | `features/artisan_home/presentation/shop_catalog_screen.dart` | Search Query Changed | `[ShopCatalogScreen] Search query changed: "$query"` | Monitors live in-catalog search queries. |
| 9 | **ShopCatalogScreen** | `features/artisan_home/presentation/shop_catalog_screen.dart` | Search Cleared | `[ShopCatalogScreen] Search query cleared` | Search reset interaction tracking. |
| 9 | **ShopCatalogScreen** | `features/artisan_home/presentation/shop_catalog_screen.dart` | Category Chip | `[ShopCatalogScreen] Category filter selected: $category` | Audits craft category filtering behavior. |
| 9 | **ShopCatalogScreen** | `features/artisan_home/presentation/shop_catalog_screen.dart` | Product Card Tap | `[ShopCatalogScreen] Product card tapped: id=$id, nameEn="$name", isBuyer=$isBuyer` | Verifies contextual routing between artisan and buyer views. |
| 9 | **ShopCatalogScreen** | `features/artisan_home/presentation/shop_catalog_screen.dart` | Add Craft FAB | `[ShopCatalogScreen] Add Craft FAB pressed -> navigating to /artisan/add-item/camera` | Funnel tracking: New craft creation entry. |
| 10 | **ArtisanCameraScreen** | `features/artisan_add_item/presentation/artisan_camera_screen.dart` | `initState` / Permissions | `[ArtisanCameraScreen] Requesting camera permissions... Granted: $granted` | Diagnoses device hardware camera permissions. |
| 10 | **ArtisanCameraScreen** | `features/artisan_add_item/presentation/artisan_camera_screen.dart` | Camera Initialized | `[ArtisanCameraScreen] Camera initialized. Ready: $isInitialized` | Verifies live camera preview controller readiness. |
| 10 | **ArtisanCameraScreen** | `features/artisan_add_item/presentation/artisan_camera_screen.dart` | Shutter Button Tap | `[ArtisanCameraScreen] Shutter pressed. Flash state: $flashState` | Audits camera shutter latency and flash configuration. |
| 10 | **ArtisanCameraScreen** | `features/artisan_add_item/presentation/artisan_camera_screen.dart` | Photo Capture Result | `[ArtisanCameraScreen] Photo captured: $photoPath, navigating to photo review` | Captures saved image file URI and wizard state transition. |
| 10 | **ArtisanCameraScreen** | `features/artisan_add_item/presentation/artisan_camera_screen.dart` | Gallery Pick | `[ArtisanCameraScreen] Gallery photo selected: $path` | Tracks gallery image importation. |
| 10 | **ArtisanCameraScreen** | `features/artisan_add_item/presentation/artisan_camera_screen.dart` | Flash Toggle | `[ArtisanCameraScreen] Flash toggled: state=$state, mode=$mode` | Audits flash cycle (off, on, auto). |
| 10 | **ArtisanCameraScreen** | `features/artisan_add_item/presentation/artisan_camera_screen.dart` | Torch Toggle | `[ArtisanCameraScreen] Toggling torch... Torch is now: $isTorchOn` | Verifies torch light state. |
| 10 | **ArtisanCameraScreen** | `features/artisan_add_item/presentation/artisan_camera_screen.dart` | Flip Camera | `[ArtisanCameraScreen] Switch camera requested. Result: $switched` | Verifies front/back camera lens switching. |
| 10 | **ArtisanCameraScreen** | `features/artisan_add_item/presentation/artisan_camera_screen.dart` | Voice Note Toggle | `[ArtisanCameraScreen] Voice note toggled: isRecording=$isVoiceRecording` | Quick audio description toggle on camera viewfinder. |
| 11 | **ImageCropperScreen** | `features/artisan_add_item/presentation/image_cropper_screen.dart` | `initState` | `[ImageCropperScreen] Initialized with image: $imagePath` | Validates target image passed to cropper. |
| 11 | **ImageCropperScreen** | `features/artisan_add_item/presentation/image_cropper_screen.dart` | Aspect Ratio Select | `[ImageCropperScreen] Aspect ratio selected: $ratio` | Logs preset ratio selection (1:1, 4:5, 16:9, free). |
| 11 | **ImageCropperScreen** | `features/artisan_add_item/presentation/image_cropper_screen.dart` | Reset Crop | `[ImageCropperScreen] Reset crop parameters` | Tracks user resetting cropping box. |
| 11 | **ImageCropperScreen** | `features/artisan_add_item/presentation/image_cropper_screen.dart` | Rotate Clockwise | `[ImageCropperScreen] Rotate 90 deg clockwise. New turns: $turns` | Tracks 90-degree image rotation steps. |
| 11 | **ImageCropperScreen** | `features/artisan_add_item/presentation/image_cropper_screen.dart` | Crop Confirmed | `[ImageCropperScreen] Crop confirmed: rect=($l, $t, $r, $b), rotation=$turns` | Logs final bounding crop box coordinates. |
| 12 | **PhotoReviewScreen** | `features/artisan_add_item/presentation/photo_review_screen.dart` | `initState` | `[PhotoReviewScreen] Initialized. photoPath: $path` | Verifies preview stage mount with captured photo. |
| 12 | **PhotoReviewScreen** | `features/artisan_add_item/presentation/photo_review_screen.dart` | Aspect Ratio Resolved | `[PhotoReviewScreen] Aspect ratio resolved: $ratio (dimensions: ${w}x${h})` | Prevents yellow distortion by logging dimensions. |
| 12 | **PhotoReviewScreen** | `features/artisan_add_item/presentation/photo_review_screen.dart` | Before/After Toggle | `[PhotoReviewScreen] Switched to AI Studio Backdrop / Original Photo view` | Tracks artisan comparison of AI background treatment. |
| 12 | **PhotoReviewScreen** | `features/artisan_add_item/presentation/photo_review_screen.dart` | Tap to Crop | `[PhotoReviewScreen] Tapped photo to crop -> opening /artisan/add-item/crop` | Cropping workflow transition. |
| 12 | **PhotoReviewScreen** | `features/artisan_add_item/presentation/photo_review_screen.dart` | Retake Button | `[PhotoReviewScreen] Retake button tapped -> popping to camera` | Audits photo retake rate. |
| 12 | **PhotoReviewScreen** | `features/artisan_add_item/presentation/photo_review_screen.dart` | Next Button | `[PhotoReviewScreen] Next button tapped -> navigating to voice describe` | Step completion tracking. |
| 13 | **VoiceDescribeScreen** | `features/artisan_add_item/presentation/voice_describe_screen.dart` | `initState` | `[VoiceDescribeScreen] Initialized. Starting recording setup...` | Mount audit for microphone recorder. |
| 13 | **VoiceDescribeScreen** | `features/artisan_add_item/presentation/voice_describe_screen.dart` | Record Start | `[VoiceDescribeScreen] Audio recording active at path: $filePath` | Logs temporary audio file creation. |
| 13 | **VoiceDescribeScreen** | `features/artisan_add_item/presentation/voice_describe_screen.dart` | Pause / Resume | `[VoiceDescribeScreen] Toggle pause. Current isPaused: $isPaused` | Tracks audio pause/resume states. |
| 13 | **VoiceDescribeScreen** | `features/artisan_add_item/presentation/voice_describe_screen.dart` | Re-record Button | `[VoiceDescribeScreen] Re-record button tapped` | Tracks audio retake rate. |
| 13 | **VoiceDescribeScreen** | `features/artisan_add_item/presentation/voice_describe_screen.dart` | Finish Recording | `[VoiceDescribeScreen] Recorded audio saved: $path. Navigating to AI review` | Saves audio note to wizard and navigates to AI analysis. |
| 14 | **AiReviewScreen** | `features/artisan_add_item/presentation/ai_review_screen.dart` | `initState` | `[AiReviewScreen] Initialized. Prepopulated AI title & description ready for review.` | Audits AI generation arrival. |
| 14 | **AiReviewScreen** | `features/artisan_add_item/presentation/ai_review_screen.dart` | Set Pricing Tap | `[AiReviewScreen] Set Pricing tapped. nameHi: "$nameHi", nameEn: "$nameEn"` | Captures artisan overrides of AI-generated titles. |
| 15 | **PricingScreen** | `features/artisan_add_item/presentation/pricing_screen.dart` | `initState` | `[PricingScreen] Initialized. suggestedPrice=$price, rawMaterial=$mat, laborHours=$hrs` | Audits fair price cost calculation. |
| 15 | **PricingScreen** | `features/artisan_add_item/presentation/pricing_screen.dart` | Stock Counter +/- | `[PricingScreen] Stock increased / decreased to: $stock` | Tracks inventory stock adjustments. |
| 15 | **PricingScreen** | `features/artisan_add_item/presentation/pricing_screen.dart` | Publish Item | `[PricingScreen] Publishing item with price: ₹$price, stock: $stock` | Captures final listing commit. |
| 15 | **PricingScreen** | `features/artisan_add_item/presentation/pricing_screen.dart` | Publish Success Dialog | `[PricingScreen] Item published successfully. Showing confirmation modal.` | Confirms marketplace listing publication. |
| 15 | **PricingScreen** | `features/artisan_add_item/presentation/pricing_screen.dart` | Back to Home | `[PricingScreen] Back to home tapped -> resetting wizard and navigating to /artisan/home` | Confirms wizard cleanup and return to studio. |

---

### Group 3: Artisan Management & Profile (5 Screens)

| # | Screen Name | File Path | Event Trigger / Lifecycle | Log Message Pattern | Diagnostic / Study Purpose |
|---|---|---|---|---|---|
| 16 | **ArtisanOrdersScreen** | `features/artisan_orders/presentation/artisan_orders_screen.dart` | Orders Loaded | `[ArtisanOrdersScreen] Orders loaded: count=$count` | Audits order repository load performance. |
| 16 | **ArtisanOrdersScreen** | `features/artisan_orders/presentation/artisan_orders_screen.dart` | Order Item Click | `[ArtisanOrdersScreen] Order tapped: orderNumber=$num, status=$status, customer=$customer` | Tracks order detail inspection. |
| 17 | **ArtisanEarningsScreen** | `features/artisan_earnings/presentation/artisan_earnings_screen.dart` | `build` render | `[ArtisanEarningsScreen] Rendered. Available balance: ₹8,720, isHindi: $isHindi` | Audits balance presentation and localization. |
| 17 | **ArtisanEarningsScreen** | `features/artisan_earnings/presentation/artisan_earnings_screen.dart` | Weekly Row Click | `[ArtisanEarningsScreen] Weekly summary tapped: week=$week, amount=$amount, orders=$orders` | Audits weekly payout analysis. |
| 18 | **ArtisanProfileScreen** | `features/artisan_profile/presentation/artisan_profile_screen.dart` | `initState` | `[ArtisanProfileScreen] Initialized` | Validates profile mount. |
| 18 | **ArtisanProfileScreen** | `features/artisan_profile/presentation/artisan_profile_screen.dart` | Aadhaar Toggle | `[ArtisanProfileScreen] Aadhaar toggle tapped. isRevealed: $isRevealed` | Audits security mask on sensitive artisan Aadhaar number. |
| 18 | **ArtisanProfileScreen** | `features/artisan_profile/presentation/artisan_profile_screen.dart` | Play Story Audio | `[ArtisanProfileScreen] Story audio play toggle: isPlaying=$isPlaying` | Audits artisan bio audio narration engagement. |
| 18 | **ArtisanProfileScreen** | `features/artisan_profile/presentation/artisan_profile_screen.dart` | Edit Story Tap | `[ArtisanProfileScreen] Edit story tapped -> navigating to /artisan/story-input` | Tracks story editing entry point. |
| 18 | **ArtisanProfileScreen** | `features/artisan_profile/presentation/artisan_profile_screen.dart` | View Shop Catalog | `[ArtisanProfileScreen] View shop catalog tapped for artisan: $artisanId` | Verifies navigation to artisan catalog. |
| 18 | **ArtisanProfileScreen** | `features/artisan_profile/presentation/artisan_profile_screen.dart` | Contact Artisan Dialog | `[ArtisanProfileScreen] Contact artisan tapped -> opening contact dialog` | Logs direct contact inquiries. |
| 18 | **ArtisanProfileScreen** | `features/artisan_profile/presentation/artisan_profile_screen.dart` | Product Card Tap | `[ArtisanProfileScreen] Product card tapped: id=$productId` | Profile craft showcase click telemetry. |
| 18 | **ArtisanProfileScreen** | `features/artisan_profile/presentation/artisan_profile_screen.dart` | Switch to Buyer Role | `[ArtisanProfileScreen] Role switch to Buyer confirmed -> navigating to /buyer/home` | Captures mode-switching between artisan seller and buyer. |
| 18 | **ArtisanProfileScreen** | `features/artisan_profile/presentation/artisan_profile_screen.dart` | Sign Out Tap | `[ArtisanProfileScreen] Sign out confirmed -> navigating to /login` | Audits session termination. |
| 19 | **ArtisanStoryTextInputScreen** | `features/artisan_profile/presentation/artisan_story_text_screen.dart` | `initState` | `[ArtisanStoryTextInputScreen] Initialized` | Verifies written story form mount. |
| 19 | **ArtisanStoryTextInputScreen** | `features/artisan_profile/presentation/artisan_story_text_screen.dart` | Form Submission | `[ArtisanStoryTextInputScreen] Submitting story form: name="$name", craft="$craft", storyLength=$len` | Audits artisan bio updates and content lengths. |
| 19 | **ArtisanStoryTextInputScreen** | `features/artisan_profile/presentation/artisan_story_text_screen.dart` | Return to Profile | `[ArtisanStoryTextInputScreen] Returned to profile from dialog` | Confirms dialog dismissal and profile refresh. |
| 20 | **VoiceOnboardingScreen** | `features/artisan_profile/presentation/voice_onboarding_screen.dart` | `initState` | `[VoiceOnboardingScreen] Initialized` | Verifies voice bio onboarding mount. |
| 20 | **VoiceOnboardingScreen** | `features/artisan_profile/presentation/voice_onboarding_screen.dart` | Mic Hold Down | `[VoiceOnboardingScreen] Mic pressed down -> listening started` | Audits push-to-talk mic initiation. |
| 20 | **VoiceOnboardingScreen** | `features/artisan_profile/presentation/voice_onboarding_screen.dart` | Mic Release | `[VoiceOnboardingScreen] Mic released -> listening stopped, voice recorded` | Audits push-to-talk completion. |
| 20 | **VoiceOnboardingScreen** | `features/artisan_profile/presentation/voice_onboarding_screen.dart` | Prefer Typing Link | `[VoiceOnboardingScreen] Prefer typing pressed -> navigating to /artisan/story-input` | Tracks fallback from voice to standard typing. |

---

### Group 4: Fairs & Community (2 Screens)

| # | Screen Name | File Path | Event Trigger / Lifecycle | Log Message Pattern | Diagnostic / Study Purpose |
|---|---|---|---|---|---|
| 21 | **ArtisanFairsScreen** | `features/artisan_fairs/presentation/artisan_fairs_screen.dart` | `initState` | `[ArtisanFairsScreen] Initialized. Current tab index: $index` | Tracks fair directory entry. |
| 21 | **ArtisanFairsScreen** | `features/artisan_fairs/presentation/artisan_fairs_screen.dart` | Tab Selection | `[ArtisanFairsScreen] Tab selected: index=$index, label="$label"` | Audits filtering across Upcoming, Applied, and Subsidized tabs. |
| 21 | **ArtisanFairsScreen** | `features/artisan_fairs/presentation/artisan_fairs_screen.dart` | Search Query | `[ArtisanFairsScreen] Search query changed: "$val"` | Live search telemetry in fairs. |
| 21 | **ArtisanFairsScreen** | `features/artisan_fairs/presentation/artisan_fairs_screen.dart` | Voice Search Modal | `[ArtisanFairsScreen] Opening voice search modal` | Voice search engagement metric. |
| 21 | **ArtisanFairsScreen** | `features/artisan_fairs/presentation/artisan_fairs_screen.dart` | Bookmark Fair | `[ArtisanFairsScreen] Bookmark toggled for fair: id=$id, newState=$state` | Audits fair saving behavior. |
| 21 | **ArtisanFairsScreen** | `features/artisan_fairs/presentation/artisan_fairs_screen.dart` | View Details Click | `[ArtisanFairsScreen] Navigating to fair details: /fair/$fairId` | Tracks transition to fair details. |
| 21 | **ArtisanFairsScreen** | `features/artisan_fairs/presentation/artisan_fairs_screen.dart` | Apply for Stall | `[ArtisanFairsScreen] Stall application submitted for fair: id=$id, title=$title` | Audits artisan exhibition participation. |
| 21 | **ArtisanFairsScreen** | `features/artisan_fairs/presentation/artisan_fairs_screen.dart` | Support Helpline | `[ArtisanFairsScreen] Calling helpline 1800-200-8899` | Tracks support phone dialer trigger. |
| 22 | **FairDetailScreen** | `features/artisan_fairs/presentation/fair_detail_screen.dart` | `initState` | `[FairDetailScreen] Initialized for fairId: $fairId` | Validates fair detail screen initialization. |
| 22 | **FairDetailScreen** | `features/artisan_fairs/presentation/fair_detail_screen.dart` | View Artisan Shop | `[FairDetailScreen] View Shop clicked for artisan: $artisanId` | Verifies Task 1 navigation fix from fair to shop catalog. |
| 22 | **FairDetailScreen** | `features/artisan_fairs/presentation/fair_detail_screen.dart` | Featured Craft Tap | `[FairDetailScreen] Featured product card tapped: id=$id, name="$name"` | Tracks craft discovery within fair. |
| 22 | **FairDetailScreen** | `features/artisan_fairs/presentation/fair_detail_screen.dart` | Stall Apply Dialog | `[FairDetailScreen] Stall application completed for fair: $fairId` | Verifies exhibition registration flow. |

---

### Group 5: Marketplace & Buyer Flow (5 Screens)

| # | Screen Name | File Path | Event Trigger / Lifecycle | Log Message Pattern | Diagnostic / Study Purpose |
|---|---|---|---|---|---|
| 23 | **MarketplaceHomeScreen** | `features/marketplace_home/presentation/marketplace_home_screen.dart` | `initState` | `[MarketplaceHomeScreen] Initialized` | Tracks buyer marketplace launch. |
| 23 | **MarketplaceHomeScreen** | `features/marketplace_home/presentation/marketplace_home_screen.dart` | Cart Icon Tap | `[MarketplaceHomeScreen] Cart icon tapped (count=$count) -> navigating to /customer/cart` | Cart inspection funnel. |
| 23 | **MarketplaceHomeScreen** | `features/marketplace_home/presentation/marketplace_home_screen.dart` | Pull to Refresh | `[MarketplaceHomeScreen] Pull-to-refresh triggered` | Audits feed refresh frequency. |
| 23 | **MarketplaceHomeScreen** | `features/marketplace_home/presentation/marketplace_home_screen.dart` | B2B Wholesale Banner | `[MarketplaceHomeScreen] B2B wholesale tapped -> navigating to /customer/b2b/bulk-request` | B2B quotation lead tracking. |
| 23 | **MarketplaceHomeScreen** | `features/marketplace_home/presentation/marketplace_home_screen.dart` | Cluster Filter Chip | `[MarketplaceHomeScreen] Cluster selected: "$cluster"` | Geographical cluster filter telemetry (e.g. Gorakhpur, Maheshwar). |
| 23 | **MarketplaceHomeScreen** | `features/marketplace_home/presentation/marketplace_home_screen.dart` | Product Card Tap | `[MarketplaceHomeScreen] Product card tapped: id=$id, name="$name"` | Product page view conversion tracking. |
| 23 | **MarketplaceHomeScreen** | `features/marketplace_home/presentation/marketplace_home_screen.dart` | Quick Add to Cart | `[MarketplaceHomeScreen] Quick add to cart: id=$id, price=$price` | Audits quick-buy interactions. |
| 24 | **ProductDetailScreen** | `features/marketplace_home/presentation/product_detail_screen.dart` | `build` render | `[ProductDetailScreen] Rendered. productId=$productId, isBuyer=$isBuyer` | Verifies contextual buyer vs artisan rendering. |
| 24 | **ProductDetailScreen** | `features/marketplace_home/presentation/product_detail_screen.dart` | Add to Cart Tap | `[ProductDetailScreen] Add to cart pressed: productId=$productId, price=$price` | Tracks cart conversion (exclusive to Buyer flow). |
| 24 | **ProductDetailScreen** | `features/marketplace_home/presentation/product_detail_screen.dart` | Artisan Edit Listing | `[ProductDetailScreen] Artisan edit listing tapped -> navigating to pricing` | Verifies artisan seller quick-edit capability. |
| 25 | **CartScreen** | `features/cart_checkout/presentation/cart_screen.dart` | `build` render | `[CartScreen] Rendered. cartItemsCount=$count, total=₹$total` | Cart contents and billing breakdown audit. |
| 25 | **CartScreen** | `features/cart_checkout/presentation/cart_screen.dart` | Quantity +/- | `[CartScreen] Quantity increased / decreased for product: $productId` | Tracks cart quantity modifications. |
| 25 | **CartScreen** | `features/cart_checkout/presentation/cart_screen.dart` | Empty Cart CTA | `[CartScreen] Empty cart button tapped -> navigating to /customer/home` | Tracks bounce recovery from empty cart. |
| 25 | **CartScreen** | `features/cart_checkout/presentation/cart_screen.dart` | Checkout Button | `[CartScreen] Checkout confirmed for total: ₹$total` | Audits purchase checkout completion. |
| 26 | **CustomerAccountScreen** | `features/marketplace_home/presentation/customer_account_screen.dart` | `build` render | `[CustomerAccountScreen] Rendered for user: $name` | Buyer account overview audit. |
| 26 | **CustomerAccountScreen** | `features/marketplace_home/presentation/customer_account_screen.dart` | Switch to Artisan Track | `[CustomerAccountScreen] Role switch to Artisan -> navigating to /artisan/home` | Tracks persona transition to Artisan studio. |
| 26 | **CustomerAccountScreen** | `features/marketplace_home/presentation/customer_account_screen.dart` | Sign Out Button | `[CustomerAccountScreen] Sign out confirmed -> navigating to /login` | Audits buyer sign out. |
| 27 | **B2bBulkRequestScreen** | `features/b2b_bulk_request/presentation/b2b_bulk_request_screen.dart` | `initState` | `[B2bBulkRequestScreen] Initialized` | B2B RFQ form mount. |
| 27 | **B2bBulkRequestScreen** | `features/b2b_bulk_request/presentation/b2b_bulk_request_screen.dart` | Craft Category Select | `[B2bBulkRequestScreen] Craft category changed: $val` | Tracks bulk craft categories in demand. |
| 27 | **B2bBulkRequestScreen** | `features/b2b_bulk_request/presentation/b2b_bulk_request_screen.dart` | Submit Quotation | `[B2bBulkRequestScreen] Quotation request submitted: company="$company", craft="$craft", qty="$qty"` | Logs B2B quotation submission inputs. |
| 27 | **B2bBulkRequestScreen** | `features/b2b_bulk_request/presentation/b2b_bulk_request_screen.dart` | Dialog OK Tap | `[B2bBulkRequestScreen] Request dialog OK pressed -> popping screen` | Confirms quotation dialog acknowledgment. |

---

## 3. How to Use for Study and Debugging

1. **Grepping by Tag**:
   Every log statement starts with `[<ClassName>]`. When debugging a specific screen (e.g., `ArtisanCameraScreen`), use:
   ```bash
   flutter logs | grep "\[ArtisanCameraScreen\]"
   ```
2. **Monitoring State Transitions**:
   In multi-step wizards like **Add Item Wizard**:
   - `[ArtisanCameraScreen]` -> `[ImageCropperScreen]` -> `[PhotoReviewScreen]` -> `[VoiceDescribeScreen]` -> `[AiReviewScreen]` -> `[PricingScreen]`
   You can trace an entire craft creation lifecycle from photo capture to price publication in a single log trace.
3. **Role Context Verification**:
   Screens that adapt dynamically between Artisan and Buyer (`ProductDetailScreen`, `ShopCatalogScreen`, `ArtisanFairsScreen`) print `isBuyer=true/false` so you can verify access rules and UI permissions in real-time.
