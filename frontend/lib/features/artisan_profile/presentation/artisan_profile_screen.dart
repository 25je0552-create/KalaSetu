import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  Artisan _getFallbackArtisan(bool isHindi) {
    return Artisan(
      id: 'art_1',
      name: isHindi ? 'रमेश प्रजापति' : 'Ramesh Prajapati',
      phone: '+91 98765 43210',
      craftType: isHindi ? 'टेराकोटा शिल्प' : 'Terracotta Pottery',
      village: 'बड़हलगंज',
      district: 'गोरखपुर',
      state: 'उत्तर प्रदेश',
      isCertified: true,
      artisanCardNumber: 'UP/TERRA/2021/8492',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3sV-GYA0lx00uY-wcyCGKIEJi1pJCzJy99rDKdTCu56nL130Frmkp11Rh59MuH1zyK5xZArvcRK1kGahDZgyXtpcykw8v4zHQunxg9abSMFOOhRUtNSTvmhZNK5fzaDbTxY5nJKoZlJdbDCs503FQbB1tagmI-Q4DcAC-NQZYx5c1khH0XtdtrkYgC22-Kb8h_emvmrzgw24ZjROCv0EKo6c1BNt_it-hfswbRFnjlPD2h_o3izQs',
      story: isHindi
          ? 'मैं गोरखपुर में 28 वर्षों से माटी की मूर्तियां और बर्तन बना रहा हूं। यह हमारी 3 पीढ़ियों की विरासत है।'
          : 'I have been sculpting clay for 28 years in Gorakhpur. Carrying forward a 3-generation legacy of GI-tagged terracotta art.',
      activeProductsCount: 14,
      rating: 4.9,
      yearsOfExperience: 28,
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
        preferredSize: const Size.fromHeight(64),
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/artisan/home');
                      }
                    },
                  ),
                  Text(
                    ref.tr('profile_title'),
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  const LanguageTogglePill(),
                ],
              ),
            ),
          ),
        ),
      ),
      body: artisanAsync.isLoading && !artisanAsync.hasValue
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _buildProfileContent(context, artisan, user, isHindi),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    Artisan artisan,
    dynamic user,
    bool isHindi,
  ) {
    final name = artisan.name.isNotEmpty ? artisan.name : (user?.name ?? (isHindi ? 'रमेश प्रजापति' : 'Ramesh Prajapati'));
    final craft = '${artisan.craftType}, ${artisan.district}';
    final story = artisan.story.isNotEmpty ? artisan.story : ref.tr('artisan_story_text');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Profile Header Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
              boxShadow: const [
                BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                        color: AppColors.surfaceContainer,
                      ),
                      child: ClipOval(
                        child: Image.network(
                          artisan.avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: AppColors.primary),
                        ),
                      ),
                    ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      ref.tr('certified_badge'),
                                      style: const TextStyle(
                                        fontFamily: 'Be Vietnam Pro',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontFamily: 'Literata',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  craft,
                                  style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, size: 18, color: Color(0xFF6B7A4F)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ref.tr('gi_card_number'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.history_edu,
                            label: ref.tr('experience_years'),
                          ),
                          Container(width: 1, height: 28, color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                          _buildStatItem(
                            icon: Icons.star_rounded,
                            label: '4.9 ★ (128)',
                          ),
                          Container(width: 1, height: 28, color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                          _buildStatItem(
                            icon: Icons.inventory_2_outlined,
                            label: ref.tr('active_items_count'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Action buttons: Edit Profile, View Listings, Contact
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
                              onPressed: () => context.push('/artisan/story-input'),
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
                              onPressed: () => context.push('/artisan/shop-catalog/${artisan.id}'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _showContactDialog(context, artisan, isHindi),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: const Icon(Icons.phone_in_talk, size: 18, color: AppColors.secondary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Artisan's Listed Crafts Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'शिल्पकार के उत्पाद' : "Artisan's Listed Crafts",
                      style: const TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/artisan/shop-catalog/${artisan.id}'),
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
                                isHindi ? 'कोई उत्पाद उपलब्ध नहीं है' : 'No listings available yet',
                                style: const TextStyle(color: AppColors.onSurfaceVariant),
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 190,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: products.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final prod = products[index];
                              final prodTitle = isHindi && prod.nameHi.isNotEmpty ? prod.nameHi : prod.nameEn;
                              return GestureDetector(
                                onTap: () => context.push('/product/${prod.id}'),
                                child: Container(
                                  width: 140,
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
                                          height: 105,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 105,
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
                const SizedBox(height: 20),

                // 2. Artisan Craft Story
                Text(
                  ref.tr('artisan_story_heading'),
                  style: const TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story,
                        style: const TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPlayingStory ? AppColors.secondary : AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            icon: Icon(_isPlayingStory ? Icons.pause_circle_filled : Icons.volume_up, size: 18),
                            label: Text(
                              _isPlayingStory
                                  ? (isHindi ? 'कहानी रोकें' : 'Pause Story')
                                  : (isHindi ? 'कहानी सुनें' : 'Listen to Story'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPlayingStory = !_isPlayingStory;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isPlayingStory
                                        ? (isHindi
                                            ? 'स्वर परिचय सुनाया जा रहा है...'
                                            : 'Playing artisan voice story...')
                                        : (isHindi ? 'स्वर परिचय रोका गया' : 'Voice story paused'),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            icon: const Icon(Icons.edit_note, size: 18),
                            label: Text(
                              isHindi ? 'कहानी बदलें' : 'Edit Story',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => context.push('/artisan/voice-onboarding'),
                          ),
                        ],
                      ),
                      if (_isPlayingStory) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.graphic_eq, color: AppColors.onSecondaryFixed, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isHindi ? 'ऑडियो परिचय चल रहा है...' : 'Playing Audio Introduction...',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSecondaryFixed),
                                    ),
                                    const SizedBox(height: 4),
                                    const LinearProgressIndicator(
                                      value: 0.38,
                                      backgroundColor: Colors.black12,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                                      minHeight: 3,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                '0:24 / 1:15',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSecondaryFixed),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Complete Seller Details
                Text(
                  isHindi ? 'शिल्पकार पूर्ण विवरण' : 'Seller Profile Details',
                  style: const TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.person_pin,
                        label: isHindi ? 'शिल्पकार का नाम' : 'Artisan Full Name',
                        value: name,
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.palette_outlined,
                        label: isHindi ? 'शिल्प विधा' : 'Master Craft Specialization',
                        value: isHindi ? 'पारंपरिक गोरखपुर टेराकोटा शिल्प (Handmade Terracotta)' : 'Traditional Gorakhpur Terracotta Craft',
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.place_outlined,
                        label: isHindi ? 'कार्यशाला का पता' : 'Workshop / Studio Address',
                        value: isHindi ? 'ग्राम बड़हलगंज, गोरखपुर, उत्तर प्रदेश - 273402' : 'Vill. Barhalganj, Gorakhpur, UP - 273402',
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.eco_outlined,
                        label: isHindi ? 'उपयोग होने वाली सामग्री' : 'Primary Materials Used',
                        value: isHindi ? 'प्राकृतिक नदी की चिकनी मिट्टी, प्राकृतिक गेरू रंग' : 'River Silt Clay, Natural Mineral Ochre, Wood Kiln',
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.history_edu_outlined,
                        label: isHindi ? 'अनुभव एवं परंपरा' : 'Experience & Heritage',
                        value: isHindi ? '28 वर्ष (3 पीढ़ियों की पुश्तैनी कला)' : '28 Years (3 Generations of Legacy)',
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.verified_user_outlined,
                        label: isHindi ? 'जी.आई. प्रमाणन संख्या' : 'GI Certification No.',
                        value: 'UP/TERRA/2021/8492 (Active GI Holder)',
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.military_tech_outlined,
                        label: isHindi ? 'पुरस्कार व सम्मान' : 'Honors & Recognition',
                        value: isHindi ? 'राज्य हस्तशिल्प पुरस्कार (2018)' : 'State Handicraft Awardee (2018)',
                      ),
                      const Divider(height: 16),
                      _buildDetailRow(
                        icon: Icons.phone_android_outlined,
                        label: isHindi ? 'संपर्क मोबाइल' : 'Registered Mobile Number',
                        value: '+91 98765 43210 (Verified)',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Quick Actions & Settings
                Text(
                  ref.tr('profile_actions_heading'),
                  style: const TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),

                // Fairs & Exhibitions Quick Tile
                _buildActionTile(
                  icon: Icons.festival,
                  title: isHindi ? 'शिल्प मेले एवं प्रदर्शनियां' : 'Fairs & Exhibitions',
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

                // Edit Profile Quick Tile
                _buildActionTile(
                  icon: Icons.badge_outlined,
                  title: isHindi ? 'प्रोफ़ाइल विवरण संपादित करें' : 'Edit Profile Details',
                  subtitle: isHindi ? 'शिल्प विधा, अनुभव और व्यक्तिगत जानकारी बदलें' : 'Update craft details, experience and info',
                  onTap: () => context.push('/artisan/story-input'),
                ),
                const SizedBox(height: 10),

                // Switch to Buyer Track
                _buildActionTile(
                  icon: Icons.shopping_bag_outlined,
                  title: ref.tr('switch_to_buyer'),
                  subtitle: ref.tr('switch_to_buyer_desc'),
                  onTap: () {
                    ref.read(authStateProvider.notifier).selectRole(UserRole.customer);
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
                const SizedBox(height: 10),

                // Helpline Support
                _buildActionTile(
                  icon: Icons.support_agent,
                  title: ref.tr('helpline_support'),
                  subtitle: ref.tr('helpline_support_desc'),
                  onTap: () {
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
                const SizedBox(height: 16),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
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
                      context.go('/login');
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
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
