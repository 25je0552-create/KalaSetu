import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../data/fair_repository.dart';
import '../../../mock_data/mock_data_loader.dart';

class ArtisanFairsScreen extends ConsumerStatefulWidget {
  const ArtisanFairsScreen({super.key});

  @override
  ConsumerState<ArtisanFairsScreen> createState() => _ArtisanFairsScreenState();
}

class _ArtisanFairsScreenState extends ConsumerState<ArtisanFairsScreen> {
  int _selectedTabIndex = 0; // 0: Upcoming, 1: Applied, 2: Subsidized
  String _searchQuery = '';
  final Set<String> _bookmarkedFairIds = {};
  final Set<String> _appliedFairIds = {};

  @override
  void initState() {
    super.initState();
    debugPrint('[ArtisanFairsScreen] Initialized. Current tab index: $_selectedTabIndex');
  }

  void _showApplicationSuccessDialog(CraftFair fair, bool isHindi) {
    debugPrint('[ArtisanFairsScreen] Stall application submitted for fair: id=${fair.id}, title=${fair.titleEn}');
    setState(() {
      _appliedFairIds.add(fair.id);
    });

    final fairTitle = isHindi ? fair.titleHi : fair.titleEn;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceBright,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.task_alt, size: 36, color: AppColors.onSecondaryContainer),
            ),
            const SizedBox(height: 16),
            Text(
              ref.tr('application_submitted'),
              style: const TextStyle(
                fontFamily: 'Literata',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              fairTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ref.tr('application_note'),
                style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 20),
            TerracottaButton(
              label: ref.tr('modal_thanks'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceSearchModal(bool isHindi) {
    debugPrint('[ArtisanFairsScreen] Opening voice search modal');
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF363023),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.mic, color: AppColors.onSecondaryContainer, size: 26),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.tr('listening_voice'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              ref.tr('voice_search_prompt'),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      backgroundColor: const Color(0xFF4A4336),
                      label: Text(
                        isHindi ? 'हुनर हाट' : 'Hunar Haat',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      onPressed: () {
                        setState(() => _searchQuery = isHindi ? 'हुनर' : 'Hunar');
                        Navigator.pop(ctx);
                      },
                    ),
                    ActionChip(
                      backgroundColor: const Color(0xFF4A4336),
                      label: Text(
                        isHindi ? 'सूरजकुंड' : 'Surajkund',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      onPressed: () {
                        setState(() => _searchQuery = isHindi ? 'सूरजकुंड' : 'Surajkund');
                        Navigator.pop(ctx);
                      },
                    ),
                    ActionChip(
                      backgroundColor: const Color(0xFF4A4336),
                      label: Text(
                        isHindi ? 'ताज महोत्सव' : 'Taj Mahotsav',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      onPressed: () {
                        setState(() => _searchQuery = isHindi ? 'ताज' : 'Taj');
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fairsAsync = ref.watch(craftFairsProvider);
    final isHindi = ref.watch(localeProvider) == AppLocale.hindi;
    final isBuyer = GoRouterState.of(context).uri.path.startsWith('/customer');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.9),
            border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 0.8)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
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
                      Text(
                        ref.tr('app_name'),
                        style: const TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        isBuyer
                            ? (isHindi ? 'शिल्प मेले व हाट' : 'Craft Fairs & Haats')
                            : ref.tr('header_fairs_subtitle'),
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const LanguageTogglePill(),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => context.push(isBuyer ? '/customer/profile' : '/artisan/profile'),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida/AEtjO1WwXZ6MsJlC0xG1asbyymA6hnNNQvTRJ40iowmrO3sGggI4vS1kqCVRZGWuSo8STZQzZpohJ5hwl3cvVfGALpD5tDueM88BvazRUFKUzxkR1BxAatNOsMANpHUbAfU8B_mo2MAyGPBcL3edYP7_lDhwYu8ppHol3AsoXrAc27qOubqtbUqy8aFc2B7gY1SHFROQi-r2UYIyR03XFEbz-NzsZs-qCDDMRbHTdaJwPnf75-On8LSDHqvnJm0',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person_outline, color: AppColors.primary, size: 22),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: fairsAsync.when(
        loading: () {
          debugPrint('[ArtisanFairsScreen] fairsAsync state: LOADING');
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
        error: (err, stack) {
          debugPrint('[ArtisanFairsScreen] fairsAsync state: ERROR: $err\n$stack');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 54, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(
                    isHindi ? 'मेले लोड करने में त्रुटि हुई' : 'Failed to load craft fairs',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      isHindi ? 'पुनः प्रयास करें' : 'Retry',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onPressed: () => ref.refresh(craftFairsProvider),
                  ),
                ],
              ),
            ),
          );
        },
        data: (fairs) {
          debugPrint('[ArtisanFairsScreen] fairsAsync state: DATA (${fairs.length} fairs received from craftFairsProvider)');
          var filteredFairs = fairs;
          if (_selectedTabIndex == 0) {
            // Tab 0: Upcoming Fairs
            filteredFairs = fairs;
          } else if (_selectedTabIndex == 1) {
            // Tab 1: My Applications
            if (isBuyer) {
              filteredFairs = fairs.where((f) => _bookmarkedFairIds.contains(f.id)).toList();
            } else {
              filteredFairs = fairs.where((f) => f.applied || _appliedFairIds.contains(f.id)).toList();
            }
          } else if (_selectedTabIndex == 2) {
            // Tab 2: Govt Subsidies / Schemes
            filteredFairs = fairs.where((f) => f.subsidized).toList();
          }

          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase().trim();
            filteredFairs = filteredFairs
                .where((f) =>
                    f.titleHi.toLowerCase().contains(query) ||
                    f.titleEn.toLowerCase().contains(query) ||
                    f.locationHi.toLowerCase().contains(query) ||
                    f.locationEn.toLowerCase().contains(query))
                .toList();
          }

          debugPrint('[ArtisanFairsScreen] Displaying ${filteredFairs.length} fairs for tab $_selectedTabIndex (query: "$_searchQuery")');

          final appliedCount = fairs.where((f) => f.applied || _appliedFairIds.contains(f.id)).length;
          final savedCount = fairs.where((f) => _bookmarkedFairIds.contains(f.id)).length;

          return RefreshIndicator(
            onRefresh: () async {
              debugPrint('[ArtisanFairsScreen] Pull-to-refresh triggered.');
              ref.refresh(craftFairsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Artisanal Header Greeting Banner
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryFixed,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.celebration, size: 14, color: AppColors.onSecondaryFixed),
                                  const SizedBox(width: 4),
                                  Text(
                                    isBuyer ? ref.tr('buyer_badge') : ref.tr('govt_support_badge'),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSecondaryFixed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isBuyer ? ref.tr('buyer_fairs_heading') : ref.tr('fairs_heading'),
                              style: const TextStyle(
                                fontFamily: 'Literata',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isBuyer ? ref.tr('buyer_fairs_subheading') : ref.tr('fairs_subheading'),
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      // Voice Search Anchor Button
                      GestureDetector(
                        onTap: () => _showVoiceSearchModal(isHindi),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(color: Color(0x339D3E14), blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.mic, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.outline),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) {
                            debugPrint('[ArtisanFairsScreen] Search query changed: "$val"');
                            setState(() => _searchQuery = val);
                          },
                          decoration: InputDecoration(
                            hintText: ref.tr('fairs_search_placeholder'),
                            border: InputBorder.none,
                            hintStyle: const TextStyle(fontSize: 14, color: AppColors.outline),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.outline),
                          onPressed: () => setState(() => _searchQuery = ''),
                        ),
                      const Icon(Icons.tune, color: AppColors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Filter Clay Tabs (3 tabs matching reference design)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTab(
                        0,
                        isBuyer ? (isHindi ? 'सभी मेले' : 'All Fairs') : ref.tr('tab_upcoming_fairs'),
                        Icons.event,
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        1,
                        isBuyer
                            ? (isHindi ? 'सहेजे गए' : 'Saved Fairs')
                            : ref.tr('tab_my_applications'),
                        isBuyer ? Icons.bookmark : Icons.assignment_turned_in,
                        badgeCount: isBuyer ? (savedCount > 0 ? savedCount : null) : (appliedCount > 0 ? appliedCount : 2),
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        2,
                        ref.tr('tab_govt_subsidies'),
                        Icons.verified,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Exhibition Tickets Stack
                if (filteredFairs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.festival_outlined, size: 54, color: AppColors.outline),
                          const SizedBox(height: 10),
                          Text(
                            isHindi ? 'कोई मेला नहीं मिला' : 'No craft fairs found',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  for (final fair in filteredFairs) ...[
                    _buildTicketCard(fair, isHindi, isBuyer),
                    const SizedBox(height: 20),
                  ],

                const SizedBox(height: 24),

                // Help Desk Footnote Banner
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.contact_support, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBuyer ? ref.tr('buyer_help_title') : ref.tr('need_help_form'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isBuyer ? ref.tr('buyer_help_desc') : ref.tr('help_desc_fairs'),
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                debugPrint('[ArtisanFairsScreen] Calling helpline 1800-200-8899');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isHindi
                                          ? (isBuyer
                                              ? 'कलासेतु शिल्प मित्र केंद्र 1800-200-8899 पर कॉल की जा रही है...'
                                              : 'कारीगर हेल्पलाइन 1800-200-8899 पर कॉल की जा रही है...')
                                          : 'Calling KalaSetu Support 1800-200-8899...',
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.call, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    isBuyer ? ref.tr('talk_customer_helpline') : ref.tr('talk_artisan_helpline'),
                                    style: const TextStyle(
                                      fontSize: 12,
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
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildTab(int index, String label, IconData icon, {int? badgeCount}) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        debugPrint('[ArtisanFairsScreen] Tab selected: index=$index, label="$label"');
        setState(() => _selectedTabIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontFamily: 'Be Vietnam Pro',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(CraftFair fair, bool isHindi, bool isBuyer) {
    final title = isHindi ? fair.titleHi : fair.titleEn;
    final category = isHindi ? fair.categoryHi : fair.categoryEn;
    final badge = isHindi ? fair.badgeHi : fair.badgeEn;
    final daysLeft = isHindi ? fair.daysLeftHi : fair.daysLeftEn;
    final location = isHindi ? fair.locationHi : fair.locationEn;
    final dateRange = isHindi ? fair.dateRangeHi : fair.dateRangeEn;
    final subsidyNote = isHindi ? fair.subsidyNoteHi : fair.subsidyNoteEn;
    final expectedVisitorsRaw = isHindi ? fair.expectedVisitorsHi : fair.expectedVisitorsEn;
    final expectedVisitors = toEnglishDigits(expectedVisitorsRaw);

    final isApplied = fair.applied || _appliedFairIds.contains(fair.id);
    final isBookmarked = _bookmarkedFairIds.contains(fair.id);

    Color badgeBg;
    IconData badgeIcon;
    Color categoryColor;
    IconData noticeIcon;

    if (fair.id == 'fair_2') {
      badgeBg = AppColors.primary;
      badgeIcon = Icons.public;
      categoryColor = AppColors.secondary;
      noticeIcon = Icons.storefront;
    } else if (fair.id == 'fair_3') {
      badgeBg = const Color(0xFF936C57);
      badgeIcon = Icons.palette;
      categoryColor = const Color(0xFF785440);
      noticeIcon = Icons.local_shipping;
    } else {
      badgeBg = AppColors.secondary;
      badgeIcon = Icons.stars;
      categoryColor = AppColors.primary;
      noticeIcon = Icons.card_membership;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visual banner with floating pills
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  fair.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: AppColors.surfaceContainerHigh,
                    child: const Icon(Icons.festival, size: 48, color: AppColors.outline),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(badgeIcon, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        badge,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    daysLeft,
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: categoryColor),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        debugPrint('[ArtisanFairsScreen] Bookmark toggled for fair: id=${fair.id}, newState=${!isBookmarked}');
                        setState(() {
                          if (isBookmarked) {
                            _bookmarkedFairIds.remove(fair.id);
                          } else {
                            _bookmarkedFairIds.add(fair.id);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                          color: isBookmarked ? AppColors.primary : AppColors.outline,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () => context.push('/fair/${fair.id}'),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(location, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(dateRange, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFFD4A373)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${fair.participatingShopsCount > 0 ? fair.participatingShopsCount : 124} ${ref.tr('participating_artisans')}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        debugPrint('[ArtisanFairsScreen] Navigating to fair details: /fair/${fair.id}');
                        context.push('/fair/${fair.id}');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        isBuyer
                            ? (isHindi ? 'कैटलॉग देखें →' : 'View Catalog →')
                            : (isHindi ? 'विवरण देखें →' : 'View Details →'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(noticeIcon, size: 18, color: categoryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subsidyNote,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Perforated Tear-Line with Authentic Notches (wrapped in IgnorePointer so hit test never fails)
          IgnorePointer(
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.constrainWidth();
                      final count = width.isFinite && width > 0 ? (width / 8).floor() : 0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          count > 0 ? count : 0,
                          (_) => SizedBox(
                            width: 4,
                            height: 1.5,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: AppColors.outlineVariant.withValues(alpha: 0.8)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: 14,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          // Ticket Bottom Stub
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ref.tr('expected_visitors_label'), style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      Text(
                        expectedVisitors,
                        style: const TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: isBuyer
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                          ),
                          onPressed: () => context.push('/fair/${fair.id}'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.storefront, size: 18, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                ref.tr('browse_fair_crafts'),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isApplied ? AppColors.secondary : AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          onPressed: () => _showApplicationSuccessDialog(fair, isHindi),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(isApplied ? Icons.check_circle : Icons.how_to_reg, size: 18, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                isApplied ? ref.tr('applied') : ref.tr('apply_now'),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
