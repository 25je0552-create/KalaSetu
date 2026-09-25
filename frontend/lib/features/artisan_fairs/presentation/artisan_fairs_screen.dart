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

  void _showApplicationSuccessDialog(CraftFair fair) {
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
            const Text(
              'आवेदन जमा हुआ',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              fair.titleHi,
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
              child: const Text(
                'आपके पंजीकृत शिल्पी पहचान पत्र के आधार पर आवेदन अग्रसारित कर दिया गया है। 48 घंटे में एसएमएस द्वारा सूचना प्राप्त होगी।',
                style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 20),
            TerracottaButton(
              label: 'ठीक है, धन्यवाद',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fairsAsync = ref.watch(craftFairsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withOpacity(0.9),
            border: const Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.8)),
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
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipOval(
                      child: Image.asset(AppConstants.logoPath, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'KalaSetu',
                        style: TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'कलासेतु शिल्प मेले',
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const LanguageTogglePill(),
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
            filteredFairs = fairs.where((f) => f.applied).toList();
          } else if (_selectedTabIndex == 2) {
            filteredFairs = fairs.where((f) => f.subsidized).toList();
          }

          if (_searchQuery.isNotEmpty) {
            filteredFairs = filteredFairs
                .where((f) =>
                    f.titleHi.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    f.locationHi.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();
          }

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
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
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
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.celebration, size: 14, color: AppColors.onSecondaryFixed),
                                  SizedBox(width: 4),
                                  Text(
                                    'सीधा सरकारी सहयोग',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSecondaryFixed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'शिल्प मेले',
                              style: TextStyle(
                                fontFamily: 'Literata',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'अपने हस्तशिल्प को देश-विदेश के बड़े मंचों तक पहुंचाएं',
                              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 24),
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
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.outline),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: 'शहर, शिल्प या मेले का नाम खोजें...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(fontSize: 14, color: AppColors.outline),
                          ),
                        ),
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
                      _buildTab(0, 'आगामी मेले', Icons.event),
                      const SizedBox(width: 8),
                      _buildTab(1, 'मेरे आवेदन (2)', Icons.assignment_turned_in),
                      const SizedBox(width: 8),
                      _buildTab(2, 'सरकारी अनुदान', Icons.verified),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Exhibition Tickets Stack
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredFairs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final fair = filteredFairs[index];
                    return _buildTicketCard(fair);
                  },
                ),
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
          border: Border.all(color: isSelected ? Colors.transparent : AppColors.outlineVariant.withOpacity(0.4)),
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

  Widget _buildTicketCard(CraftFair fair) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
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
                        fair.badgeHi,
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
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    fair.daysLeftHi,
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
                Text(
                  fair.categoryHi.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  fair.titleHi,
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
                      child: Text(fair.locationHi, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                    Text(fair.dateRangeHi, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
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
                          fair.subsidyNoteHi,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Perforated Tear-Line with Notches
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
                        (_) => const SizedBox(
                          width: 4,
                          height: 1.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: AppColors.outlineVariant),
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
                    const Text('अनुमानित दर्शक', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    Text(
                      fair.expectedVisitorsHi,
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
                      backgroundColor: fair.applied ? AppColors.secondary : AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onPressed: () => _showApplicationSuccessDialog(fair),
                    child: Row(
                      children: [
                        Icon(fair.applied ? Icons.check : Icons.how_to_reg, size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          fair.applied ? 'आवेदन हुआ' : 'आवेदन करें',
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
