import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/services/auth_service.dart';
import '../data/artisan_repository.dart';

class ArtisanProfileScreen extends ConsumerStatefulWidget {
  const ArtisanProfileScreen({super.key});

  @override
  ConsumerState<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends ConsumerState<ArtisanProfileScreen> {
  bool _isPlayingStory = false;

  @override
  Widget build(BuildContext context) {
    final artisanAsync = ref.watch(currentArtisanProvider);
    final user = ref.watch(authStateProvider);
    final currentLocale = ref.watch(localeProvider);
    final isHindi = currentLocale == AppLocale.hindi;

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
      body: artisanAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('त्रुटि: $err')),
        data: (artisan) {
          final name = artisan?.name ?? user?.name ?? (isHindi ? 'रमेश प्रजापति' : 'Ramesh Prajapati');
          final craft = artisan != null
              ? '${artisan.craftType}, ${artisan.district}'
              : (isHindi ? 'माटी शिल्पी, गोरखपुर' : 'Clay Artisan, Gorakhpur');
          final story = artisan?.story ?? ref.tr('artisan_story_text');

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
                                artisan?.avatarUrl ??
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB3sV-GYA0lx00uY-wcyCGKIEJi1pJCzJy99rDKdTCu56nL130Frmkp11Rh59MuH1zyK5xZArvcRK1kGahDZgyXtpcykw8v4zHQunxg9abSMFOOhRUtNSTvmhZNK5fzaDbTxY5nJKoZlJdbDCs503FQbB1tagmI-Q4DcAC-NQZYx5c1khH0XtdtrkYgC22-Kb8h_emvmrzgw24ZjROCv0EKo6c1BNt_it-hfswbRFnjlPD2h_o3izQs',
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
                    ],
                  ),
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

                // Switch to Customer Track
                _buildActionTile(
                  icon: Icons.storefront_outlined,
                  title: ref.tr('switch_to_buyer'),
                  subtitle: ref.tr('switch_to_buyer_desc'),
                  onTap: () {
                    ref.read(authStateProvider.notifier).selectRole(UserRole.customer);
                    context.go('/customer/home');
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
        },
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
