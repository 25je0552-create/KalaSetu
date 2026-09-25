import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/services/auth_service.dart';
import '../data/artisan_repository.dart';
import '../../marketplace_home/data/product_repository.dart';
import '../../../mock_data/mock_data_loader.dart';

class ArtisanProfileScreen extends ConsumerStatefulWidget {
  const ArtisanProfileScreen({super.key});

  @override
  ConsumerState<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends ConsumerState<ArtisanProfileScreen> {
  bool _isPlayingStory = false;
  bool _isAadhaarRevealed = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[ArtisanProfileScreen] Initialized');
  }

  String _formatAadhaar(String raw, bool revealed) {
    final clean = raw.replaceAll(RegExp(r'\D'), '');
    final last4 = clean.length >= 4 ? clean.substring(clean.length - 4) : '8492';
    if (!revealed) {
      return 'XXXX-XXXX-$last4';
    }
    if (clean.length == 12) {
      return '${clean.substring(0, 4)}-${clean.substring(4, 8)}-$last4';
    }
    return raw;
  }

  Artisan _getFallbackArtisan(bool isHindi) {
    return Artisan(
      id: 'art_1',
      name: isHindi ? 'रमेश प्रजापति' : 'Ramesh Prajapati',
      phone: '+91 98765 43210',
      craftType: isHindi ? 'गोरखपुर टेराकोटा एवं माटी शिल्प' : 'Gorakhpur Terracotta & Clay Craft',
      village: isHindi ? 'गांव औरंगाबाद' : 'Aurangabad Village',
      district: isHindi ? 'गोरखपुर' : 'Gorakhpur',
      state: isHindi ? 'उत्तर प्रदेश' : 'Uttar Pradesh',
      isCertified: true,
      artisanCardNumber: 'IND-UP-GKP-9021',
      aadhaarNumber: '5842-9134-8492',
      email: 'ramesh.prajapati@kalasetu.in',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida/AEtjO1WwXZ6MsJlC0xG1asbyymA6hnNNQvTRJ40iowmrO3sGggI4vS1kqCVRZGWuSo8STZQzZpohJ5hwl3cvVfGALpD5tDueM88BvazRUFKUzxkR1BxAatNOsMANpHUbAfU8B_mo2MAyGPBcL3edYP7_lDhwYu8ppHol3AsoXrAc27qOubqtbUqy8aFc2B7gY1SHFROQi-r2UYIyR03XFEbz-NzsZs-qCDDMRbHTdaJwPnf75-On8LSDHqvnJm0',
      story: isHindi
          ? 'हमारा परिवार तीन पीढ़ियों से गोरखपुर की राप्ती नदी की उपजाऊ काली मिट्टी से पारम्परिक टेराकोटा दीप, मूर्तियां व कलश गढ़ता आया है। लकड़ियों से सुलगने वाली भट्टी में प्राकृतिक रूप से पकाई गई यह मिट्टी कभी रंग नहीं छोड़ती। हर शिल्पकला में हमारे पुरखों का आशीर्वाद और अवध की माटी की खुशबू समाई है।'
          : 'For three generations, our family has shaped traditional terracotta earthen lamps, sculptures, and pitchers using the fertile black clay of Gorakhpur\'s Rapti riverbed. Fired naturally in wood-burning kilns, this clay never loses its earthy sheen. Every piece embodies our ancestral blessings and the fragrant soil of Awadh.',
      activeProductsCount: 18,
      rating: 4.9,
      yearsOfExperience: 24,
      giTagNumber: '#GI-UP-2018',
      generation: isHindi ? 'तृतीय पीढ़ी' : '3rd Generation',
      isPehchanVerified: true,
      isCraftVerified: true,
    );
  }

  void _showContactDialog(BuildContext context, Artisan artisan, bool isHindi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.contact_phone, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(isHindi ? 'शिल्पकार संपर्क विवरण' : 'Artisan Contact'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              artisan.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text('${artisan.craftType} • ${artisan.district}, ${artisan.state}'),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone, color: AppColors.secondary),
              title: Text(artisan.phone),
              subtitle: Text(isHindi ? 'सीधे कॉल करें' : 'Call directly'),
              onTap: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isHindi
                          ? '${artisan.name} को कॉल किया जा रहा है: ${artisan.phone}'
                          : 'Calling ${artisan.name}: ${artisan.phone}',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.badge, color: AppColors.secondary),
              title: Text(artisan.artisanCardNumber),
              subtitle: Text(isHindi ? 'जीआई शिल्पकार कार्ड संख्या' : 'GI Artisan Card No.'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isHindi ? 'बंद करें' : 'Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artisanAsync = ref.watch(currentArtisanProvider);
    final user = ref.watch(authStateProvider);
    final currentLocale = ref.watch(localeProvider);
    final isHindi = currentLocale == AppLocale.hindi;
    final fallback = _getFallbackArtisan(isHindi);
    final artisan = artisanAsync.value ?? fallback;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(66),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.95),
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4), width: 0.8)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.asset(AppConstants.logoPath, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'KalaSetu',
                        style: TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        isHindi ? 'कलासेतु शिल्प मेले' : 'Craft Fairs & Haats',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const LanguageTogglePill(),
                  const SizedBox(width: 10),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        artisan.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: artisanAsync.isLoading && !artisanAsync.hasValue
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                if (_isPlayingStory)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: AppColors.secondaryContainer,
                    child: Row(
                      children: [
                        const Icon(Icons.volume_up, size: 20, color: AppColors.onSecondaryContainer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isHindi
                                ? 'ऑडियो चल रहा है: रमेश जी की कहानी (1:45 मिनट)'
                                : 'Now Playing: Story of Master Ramesh (1:45 min)',
                            style: const TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _isPlayingStory = false);
                          },
                          child: const Icon(Icons.close, size: 18, color: AppColors.onSecondaryContainer),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _buildProfileContent(context, artisan, user, isHindi),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    Artisan artisan,
    dynamic user,
    bool isHindi,
  ) {
    final name = artisan.name.isNotEmpty ? artisan.name : (user?.name ?? (isHindi ? 'रमेश प्रजापति' : 'Ramesh Prajapati'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Artisan Hero Card
          _buildHeroCard(context, artisan, name, isHindi),
          const SizedBox(height: 16),

          // 2. Artisan Story & Heritage Card
          _buildStoryAndHeritageCard(context, artisan, isHindi),
          const SizedBox(height: 16),

          // 3. Credentials & Trust Stats
          _buildCredentialsTrustCard(isHindi),
          const SizedBox(height: 16),

          // 4. Workshop & Craft Studio Gallery (Carousel)
          _buildStudioGalleryCard(context, artisan, isHindi),
          const SizedBox(height: 16),

          // 5. Bank & Payout Summary Card
          _buildBankPayoutCard(isHindi),
          const SizedBox(height: 16),

          // 6. Verified Identity & Masked Aadhaar Card
          _buildIdentityAndContactCard(context, artisan, isHindi),
          const SizedBox(height: 16),

          // 7. Artisan Welfare Schemes & Support
          _buildSchemesAndHelplineCard(context, isHindi),
          const SizedBox(height: 16),

          // 8. Quick Actions & Sign Out
          _buildActionsSection(context, artisan, isHindi),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    Artisan artisan,
    String name,
    bool isHindi,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9ECD9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFB599).withValues(alpha: 0.25),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Opacity(
              opacity: 0.1,
              child: const Icon(Icons.circle_outlined, size: 68, color: AppColors.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 1.5),
                            color: AppColors.surfaceContainerHigh,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              artisan.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 44, color: AppColors.primary),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: const Icon(Icons.verified, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDDB0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF805600),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isHindi ? 'प्रमाणित मास्टर शिल्पी' : 'Certified Master Artisan',
                                  style: const TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF805600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Literata',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artisan.craftType,
                            style: const TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.outline),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  '${artisan.village}, ${artisan.district}, ${artisan.state}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Be Vietnam Pro',
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // GI Tag container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_outlined, size: 18, color: AppColors.secondary),
                              const SizedBox(width: 6),
                              Text(
                                isHindi ? 'जी.आई. टैग धारक (#GI-UP-2018)' : 'GI Tag Holder (#GI-UP-2018)',
                                style: const TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isHindi ? 'मान्यता प्राप्त' : 'Certified',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.military_tech_outlined, size: 16, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isHindi
                                  ? '24 वर्ष का अनुभव • राज्य हस्तशिल्प पुरस्कार विजेता'
                                  : '24 Years Experience • State Handicraft Awardee',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Verified chips
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 15, color: Color(0xFF805600)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                isHindi ? 'पहचान पत्र (Pehchan ID)' : 'Pehchan ID Verified',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.verified_user, size: 15, color: Color(0xFF805600)),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                isHindi ? 'शिल्प मित्र सत्यापित' : 'KalaSetu Verified',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(
                          isHindi ? 'प्रोफ़ाइल बदलें' : 'Edit Profile',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          debugPrint('[ArtisanProfileScreen] Edit profile tapped -> /artisan/story-input');
                          context.push('/artisan/story-input');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.storefront_outlined, size: 16),
                        label: Text(
                          isHindi ? 'उत्पाद देखें' : 'View Listings',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          debugPrint('[ArtisanProfileScreen] View listings tapped for artisan: ${artisan.id}');
                          context.push('/artisan/shop-catalog/${artisan.id}');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          debugPrint('[ArtisanProfileScreen] Contact tapped');
                          _showContactDialog(context, artisan, isHindi);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.phone_in_talk, size: 18, color: AppColors.secondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryAndHeritageCard(
    BuildContext context,
    Artisan artisan,
    bool isHindi,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2DF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_edu, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? 'कारीगर की कहानी व धरोहर' : 'Artisan Heritage & Story',
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDBCE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isHindi ? 'तृतीय पीढ़ी' : '3rd Generation',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF370E00),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            artisan.story,
            style: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 14,
              height: 1.55,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              icon: Icon(_isPlayingStory ? Icons.pause_circle_filled : Icons.volume_up, size: 22),
              label: Text(
                _isPlayingStory
                    ? (isHindi ? 'कहानी रोकें (Pause Story)' : 'Pause Story')
                    : (isHindi ? 'कहानी सुनें (Audio Story - 1:45 min)' : 'Listen to Story (Audio - 1:45 min)'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                final next = !_isPlayingStory;
                setState(() => _isPlayingStory = next);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _isPlayingStory
                          ? (isHindi
                              ? 'ऑडियो चल रहा है: रमेश जी की कहानी (1:45 मिनट)'
                              : 'Now Playing: Story of Master Ramesh (1:45 min)')
                          : (isHindi ? 'स्वर परिचय रोका गया' : 'Voice story paused'),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsTrustCard(bool isHindi) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_outlined, color: AppColors.secondary, size: 22),
              const SizedBox(width: 8),
              Text(
                isHindi ? 'विश्वास एवं शिल्पकला साख' : 'Trust & Artisan Credentials',
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFEBA4A), size: 20),
                      const SizedBox(height: 4),
                      const Text(
                        '184+',
                        style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isHindi ? 'समीक्षाएं' : 'Reviews',
                        style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(height: 4),
                      const Text(
                        '520+',
                        style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isHindi ? 'हस्तशिल्प निर्मित' : 'Pieces Made',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.eco_outlined, color: Color(0xFF6B7A4F), size: 20),
                      const SizedBox(height: 4),
                      const Text(
                        '100%',
                        style: TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isHindi ? 'प्राकृतिक मिट्टी' : 'Pure Clay',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, color: AppColors.secondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'हस्तशिल्प पहचान पत्र (वस्त्र मंत्रालय)' : 'Artisan Pehchan Card (Ministry of Textiles)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: IND-UP-GKP-9021 • ${isHindi ? 'वैध 2028 तक' : 'Valid until 2028'}',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_outlined, color: Color(0xFF6B7A4F), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'कारीगर बैंक खाता लिंक (DBT सक्षम)' : 'Linked Bank Account (DBT Active)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isHindi
                            ? 'सरकारी अनुदान एवं बिक्री हेतु प्रत्यक्ष भुगतान चालू'
                            : 'Direct Benefit Transfer active for sales & subsidies',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioGalleryCard(
    BuildContext context,
    Artisan artisan,
    bool isHindi,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, color: AppColors.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  isHindi ? 'कार्यशाला व कलाकृतियां' : 'Workshop & Craft Studio',
                  style: const TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                debugPrint('[ArtisanProfileScreen] View all crafts tapped -> /artisan/shop-catalog/${artisan.id}');
                context.push('/artisan/shop-catalog/${artisan.id}');
              },
              child: Text(
                isHindi ? 'सभी देखें' : 'View All',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Consumer(
          builder: (context, ref, _) {
            final productsAsync = ref.watch(artisanProductsProvider(artisan.id));
            return productsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (products) {
                if (products.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        isHindi ? 'कोई कलाकृति उपलब्ध नहीं है' : 'No listings available yet',
                        style: const TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  );
                }
                return SizedBox(
                  height: 195,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final prod = products[index];
                      final prodTitle = isHindi && prod.nameHi.isNotEmpty ? prod.nameHi : prod.nameEn;
                      return GestureDetector(
                        onTap: () {
                          debugPrint('[ArtisanProfileScreen] Product card tapped: id=${prod.id}');
                          context.push('/artisan/product/${prod.id}');
                        },
                        child: Container(
                          width: 145,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  prod.imageUrl,
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 110,
                                    color: AppColors.surfaceContainer,
                                    child: const Icon(Icons.image, color: AppColors.outline),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prodTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '₹${prod.price.toInt()}',
                                      style: const TextStyle(
                                        fontFamily: 'Be Vietnam Pro',
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBankPayoutCard(bool isHindi) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2DF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? 'बैंक एवं भुगतान विवरण' : 'Bank & Payout Summary',
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7A4F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isHindi ? 'सक्रिय (DBT)' : 'Active (DBT)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7A4F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isHindi
                ? 'भारतीय स्टेट बैंक (SBI) • खाता संख्या: •••• 4821'
                : 'State Bank of India (SBI) • Account: •••• 4821',
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'कुल अर्जित आय' : 'Total Earnings',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '₹2,48,600',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 36, color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'आगामी भुगतान' : 'Next Payout',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '₹7,450',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: Color(0xFF6B7A4F)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isHindi
                      ? 'कल सुबह 10:00 बजे तक आपके बैंक खाते में जमा होगा'
                      : 'Arriving in your bank account tomorrow by 10:00 AM',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF6B7A4F)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityAndContactCard(
    BuildContext context,
    Artisan artisan,
    bool isHindi,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isHindi ? 'पहचान एवं संपर्क विवरण' : 'Identity & Contact Details',
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7A4F).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isHindi ? 'सत्यापित' : 'Verified',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B7A4F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Aadhaar Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.fingerprint, color: AppColors.secondary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'आधार संख्या' : 'Aadhaar Number',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatAadhaar(artisan.aadhaarNumber, _isAadhaarRevealed),
                        style: const TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() => _isAadhaarRevealed = !_isAadhaarRevealed);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAadhaarRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isAadhaarRevealed ? (isHindi ? 'छिपाएं' : 'Hide') : (isHindi ? 'देखें' : 'Reveal'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Location Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.place_outlined, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'कार्यशाला का पता' : 'Workshop Address',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${artisan.village}, ${artisan.district}, ${artisan.state} - 273001',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Mobile Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_android, color: AppColors.secondary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'पंजीकृत मोबाइल' : 'Registered Mobile',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        artisan.phone,
                        style: const TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.call, size: 20, color: AppColors.primary),
                  onPressed: () => _showContactDialog(context, artisan, isHindi),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemesAndHelplineCard(BuildContext context, bool isHindi) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                isHindi ? 'कारीगर कल्याण योजनाएं' : 'Artisan Welfare Schemes',
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.handyman_outlined, color: AppColors.secondary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isHindi ? 'पीएम विश्वकर्मा योजना' : 'PM Vishwakarma Scheme',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B7A4F).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isHindi ? 'सक्रिय' : 'Active',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7A4F)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isHindi
                            ? 'टूलकिट प्रोत्साहन एवं ₹1 लाख ऋण स्वीकृत'
                            : 'Toolkit incentive & ₹1 Lakh collateral-free loan approved',
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.phone_in_talk, size: 18),
              label: Text(
                isHindi
                    ? '1800-200-8899 शिल्प मित्र से बात करें'
                    : '1800-200-8899 Call Craft Friend',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isHindi
                          ? 'कारीगर हेल्पलाइन 1800-200-8899 पर कॉल की जा रही है...'
                          : 'Dialing Artisan Helpline 1800-200-8899...',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    Artisan artisan,
    bool isHindi,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHindi ? 'त्वरित सेटिंग्स व सेवाएं' : 'Quick Actions & Settings',
          style: const TextStyle(
            fontFamily: 'Literata',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 10),

        // Fairs & Exhibitions Tile
        _buildActionTile(
          icon: Icons.festival,
          title: isHindi ? 'शिल्प मेले एवं प्रदर्शनियां' : 'Craft Fairs & Haats',
          subtitle: isHindi ? 'आगामी मेलों और स्टॉल के लिए आवेदन करें' : 'Browse upcoming craft fairs & stalls',
          onTap: () => context.go('/artisan/fairs'),
        ),
        const SizedBox(height: 10),

        // Voice Onboarding Link
        _buildActionTile(
          icon: Icons.record_voice_over,
          title: ref.tr('update_voice_intro'),
          subtitle: ref.tr('update_voice_intro_desc'),
          onTap: () => context.push('/artisan/voice-onboarding'),
        ),
        const SizedBox(height: 10),

        // View Shop Catalog Quick Tile
        _buildActionTile(
          icon: Icons.store_mall_directory_outlined,
          title: isHindi ? 'दुकान उत्पाद कैटलॉग' : 'My Shop Catalog',
          subtitle: isHindi ? 'अपने सभी लिस्टेड क्राफ्ट देखें व प्रबंधित करें' : 'View all products listed by your shop',
          onTap: () => context.push('/artisan/shop-catalog/${artisan.id}'),
        ),
        const SizedBox(height: 10),

        // Switch to Buyer Track
        _buildActionTile(
          icon: Icons.shopping_bag_outlined,
          title: ref.tr('switch_to_buyer'),
          subtitle: ref.tr('switch_to_buyer_desc'),
          onTap: () {
            ref.read(authStateProvider.notifier).selectRole(UserRole.customer);
            debugPrint('[ArtisanProfileScreen] Role switch to Buyer confirmed -> navigating to /buyer/home');
            context.go('/buyer/home');
          },
        ),
        const SizedBox(height: 10),

        // Language Setting Tile
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.language, color: AppColors.primary, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  ref.tr('app_language'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const LanguageTogglePill(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout, size: 20),
            label: Text(
              ref.tr('logout'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            onPressed: () {
              ref.read(authStateProvider.notifier).signOut();
              debugPrint('[ArtisanProfileScreen] Sign out confirmed -> navigating to /login');
              context.go('/login');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
