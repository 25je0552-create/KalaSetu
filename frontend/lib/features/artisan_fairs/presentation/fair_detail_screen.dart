import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/services/auth_service.dart';
import '../data/fair_repository.dart';
import '../../artisan_profile/data/artisan_repository.dart';
import '../../marketplace_home/data/product_repository.dart';
import '../../../mock_data/mock_data_loader.dart';

class FairDetailScreen extends ConsumerStatefulWidget {
  final String fairId;

  const FairDetailScreen({
    super.key,
    required this.fairId,
  });

  @override
  ConsumerState<FairDetailScreen> createState() => _FairDetailScreenState();
}

class _FairDetailScreenState extends ConsumerState<FairDetailScreen> {
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[FairDetailScreen] Initialized for fairId: ${widget.fairId}');
  }

  void _showApplyDialog(CraftFair fair, bool isHindi) {
    debugPrint('[FairDetailScreen] Opening stall application dialog for fair: ${fair.id}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceBright,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: AppColors.onSecondaryContainer, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              isHindi ? 'स्टॉल आवेदन जमा हुआ!' : 'Stall Application Submitted!',
              style: const TextStyle(
                fontFamily: 'Literata',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isHindi
                  ? '${fair.titleHi} में आपके स्टॉल का आवेदन नोडल अधिकारी को भेज दिया गया है।'
                  : 'Your stall request for ${fair.titleEn} has been submitted for verification.',
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TerracottaButton(
              label: isHindi ? 'ठीक है' : 'Done',
              onPressed: () {
                debugPrint('[FairDetailScreen] Stall application completed for fair: ${fair.id}');
                setState(() => _isApplied = true);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fairAsync = ref.watch(fairDetailProvider(widget.fairId));
    final isHindi = ref.watch(localeProvider) == AppLocale.hindi;
    final user = ref.watch(authStateProvider);
    final isArtisan = user?.role != UserRole.customer;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
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
                      debugPrint('[FairDetailScreen] Back button tapped');
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/artisan/fairs');
                      }
                    },
                  ),
                  Text(
                    isHindi ? 'मेले का विवरण' : 'Fair Details',
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
      body: fairAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text(isHindi ? 'त्रुटि: $err' : 'Error: $err')),
        data: (fair) {
          if (fair == null) {
            return Center(
              child: Text(isHindi ? 'मेला उपलब्ध नहीं है' : 'Fair not found'),
            );
          }

          final title = isHindi ? fair.titleHi : fair.titleEn;
          final category = isHindi ? fair.categoryHi : fair.categoryEn;
          final location = isHindi ? fair.locationHi : fair.locationEn;
          final dates = isHindi ? fair.dateRangeHi : fair.dateRangeEn;
          final subsidy = isHindi ? fair.subsidyNoteHi : fair.subsidyNoteEn;
          final description = (isHindi ? fair.descriptionHi : fair.descriptionEn).isNotEmpty
              ? (isHindi ? fair.descriptionHi : fair.descriptionEn)
              : (isHindi
                  ? '$title भारत के प्रतिष्ठित शिल्पकारों और बुनकरों का समागम है।'
                  : '$title brings together celebrated master artisans and craft clusters from across the nation.');
          final hasApplied = _isApplied || fair.applied;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Banner Image with overlay details
                Stack(
                  children: [
                    Image.network(
                      fair.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220,
                        color: AppColors.surfaceContainer,
                        child: const Center(child: Icon(Icons.festival, size: 54, color: AppColors.outline)),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isHindi ? fair.badgeHi : fair.badgeEn,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isHindi ? fair.daysLeftHi : fair.daysLeftEn,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Date & Location Key Info Cards
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    dates,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.place_outlined, size: 18, color: AppColors.secondary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.groups_outlined, size: 18, color: Color(0xFFD4A373)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isHindi ? fair.expectedVisitorsHi : fair.expectedVisitorsEn,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryFixed,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${fair.participatingShopsCount} ${isHindi ? 'दुकानें' : 'Shops'}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSecondaryFixed),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Government Subsidy Banner
                      if (subsidy.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0E4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.verified, size: 20, color: AppColors.secondary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isHindi ? 'सरकारी प्रोत्साहन व सहायता' : 'Government Subsidy & Support',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subsidy,
                                      style: const TextStyle(fontSize: 12, height: 1.3, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),

                      // Fair Overview Description
                      Text(
                        isHindi ? 'मेले के बारे में' : 'About the Fair',
                        style: const TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),

                      // 2. Participating Shops / Artisans Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isHindi ? 'प्रतिभागी शिल्पकार एवं दुकानें' : 'Participating Shops & Artisans',
                            style: const TextStyle(
                              fontFamily: 'Literata',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            '${fair.participatingShopIds.length} ${isHindi ? 'शिल्पी' : 'artisans'}',
                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Participating Artisans Cards List
                      if (fair.participatingShopIds.isEmpty)
                        Text(isHindi ? 'प्रतिभागी सूची जल्द जारी होगी' : 'Artisan list will be published shortly')
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: fair.participatingShopIds.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final aid = fair.participatingShopIds[index];
                            final artisanAsync = ref.watch(artisanByIdProvider(aid));

                            return artisanAsync.when(
                              loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (artisan) {
                                if (artisan == null) return const SizedBox.shrink();
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.network(
                                          artisan.avatarUrl,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 44,
                                            height: 44,
                                            color: AppColors.surfaceContainer,
                                            child: const Icon(Icons.person, color: AppColors.primary),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              artisan.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            Text(
                                              '${artisan.craftType} • ${artisan.district}',
                                              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Clickable link to their Shop Catalog (Task 1)
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        onPressed: () {
                                          debugPrint('[FairDetailScreen] View Shop clicked for artisan: ${artisan.id}');
                                          context.push('/artisan/shop-catalog/${artisan.id}');
                                        },
                                        child: Text(
                                          isHindi ? 'दुकान देखें' : 'View Shop',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      const SizedBox(height: 24),

                      // 3. Featured Products from Participating Artisans
                      Text(
                        isHindi ? 'मेले में प्रदर्शित शिल्प' : 'Featured Fair Crafts',
                        style: const TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ref.watch(featuredProductsProvider).when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (products) {
                              final fairProducts = products.where((p) => fair.participatingShopIds.contains(p.artisanId)).toList();
                              if (fairProducts.isEmpty) {
                                return Text(isHindi ? 'उत्पाद जल्द उपलब्ध होंगे' : 'Products will be listed soon');
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.74,
                                ),
                                itemCount: fairProducts.length,
                                itemBuilder: (context, idx) {
                                  final p = fairProducts[idx];
                                  final pName = isHindi ? p.nameHi : p.nameEn;

                                  return GestureDetector(
                                    onTap: () {
                                      debugPrint('[FairDetailScreen] Featured product card tapped: id=${p.id}, name="${p.nameEn}"');
                                      context.push('/customer/product/${p.id}');
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                              child: Image.network(
                                                p.imageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image)),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  pName,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '₹${p.price.toInt()}',
                                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      const SizedBox(height: 32),

                      // Action Button (Artisan application / Buyer exploration)
                      if (isArtisan)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasApplied ? AppColors.secondary : AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: Icon(hasApplied ? Icons.task_alt : Icons.store_mall_directory),
                            label: Text(
                              hasApplied
                                  ? (isHindi ? 'आवेदन जमा हो चुका है' : 'Stall Applied (Verified)')
                                  : (isHindi ? 'इस मेले में स्टॉल लगाएं' : 'Apply for Fair Stall'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            onPressed: hasApplied ? null : () => _showApplyDialog(fair, isHindi),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
