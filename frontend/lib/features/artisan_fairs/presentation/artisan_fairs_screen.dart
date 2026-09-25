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

  void _showApplicationSuccessDialog(CraftFair fair, bool isHindi) {
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
                        ref.tr('header_fairs_subtitle'),
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const LanguageTogglePill(),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => context.push('/artisan/profile'),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.person_outline, color: AppColors.primary, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: fairsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Text('त्रुटि: $err'),
        ),
        data: (fairs) {
          var filteredFairs = fairs;
          if (_selectedTabIndex == 1) {
            filteredFairs = fairs.where((f) => !f.applied && !_appliedFairIds.contains(f.id)).toList();
          } else if (_selectedTabIndex == 2) {
            filteredFairs = fairs.where((f) => f.applied || _appliedFairIds.contains(f.id)).toList();
          } else if (_selectedTabIndex == 3) {
            filteredFairs = fairs.where((f) => f.subsidized).toList();
          }

          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            filteredFairs = filteredFairs
                .where((f) =>
                    f.titleHi.toLowerCase().contains(query) ||
                    f.titleEn.toLowerCase().contains(query) ||
                    f.locationHi.toLowerCase().contains(query) ||
                    f.locationEn.toLowerCase().contains(query))
                .toList();
          }

          final appliedCount = fairs.where((f) => f.applied || _appliedFairIds.contains(f.id)).length;

          return SingleChildScrollView(
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
                                    ref.tr('govt_support_badge'),
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
                              ref.tr('fairs_heading'),
                              style: const TextStyle(
                                fontFamily: 'Literata',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.tr('fairs_subheading'),
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
                          onChanged: (val) => setState(() => _searchQuery = val),
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

                // Filter Clay Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTab(0, ref.tr('nav_fairs'), Icons.festival),
                      const SizedBox(width: 8),
                      _buildTab(1, ref.tr('tab_upcoming_fairs'), Icons.event),
                      const SizedBox(width: 8),
                      _buildTab(2, '${ref.tr('tab_my_applications')} ($appliedCount)', Icons.assignment_turned_in),
                      const SizedBox(width: 8),
                      _buildTab(3, ref.tr('tab_govt_subsidies'), Icons.verified),
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
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredFairs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final fair = filteredFairs[index];
                      return _buildTicketCard(fair, isHindi);
                    },
                  ),

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
                              ref.tr('need_help_form'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.tr('help_desc_fairs'),
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isHindi
                                          ? 'कारीगर हेल्पलाइन 1800-200-8899 पर कॉल की जा रही है...'
                                          : 'Calling Artisan Helpline 1800-200-8899...',
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.call, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    ref.tr('talk_artisan_helpline'),
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
          );
        },
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Row(
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
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(CraftFair fair, bool isHindi) {
    final title = isHindi ? fair.titleHi : fair.titleEn;
    final category = isHindi ? fair.categoryHi : fair.categoryEn;
    final badge = isHindi ? fair.badgeHi : fair.badgeEn;
    final daysLeft = isHindi ? fair.daysLeftHi : fair.daysLeftEn;
    final location = isHindi ? fair.locationHi : fair.locationEn;
    final dateRange = isHindi ? fair.dateRangeHi : fair.dateRangeEn;
    final subsidyNote = isHindi ? fair.subsidyNoteHi : fair.subsidyNoteEn;
    final expectedVisitors = isHindi ? fair.expectedVisitorsHi : fair.expectedVisitorsEn;

    final isApplied = fair.applied || _appliedFairIds.contains(fair.id);
    final isBookmarked = _bookmarkedFairIds.contains(fair.id);

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
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 150,
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
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, size: 14, color: Colors.white),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
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
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isBookmarked) {
                            _bookmarkedFairIds.remove(fair.id);
                          } else {
                            _bookmarkedFairIds.add(fair.id);
                          }
                        });
                      },
                      child: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                        color: isBookmarked ? AppColors.primary : AppColors.outline,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
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
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.card_membership, size: 18, color: AppColors.primary),
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
          // Perforated Tear-Line with Authentic Notches
          Row(
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
                    final count = (constraints.constrainWidth() / 8).floor();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        count,
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
          // Ticket Bottom Stub
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApplied ? AppColors.secondary : AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: () => _showApplicationSuccessDialog(fair, isHindi),
                    child: Row(
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
