import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../marketplace_home/data/product_repository.dart';

class ArtisanHomeScreen extends ConsumerStatefulWidget {
  const ArtisanHomeScreen({super.key});

  @override
  ConsumerState<ArtisanHomeScreen> createState() => _ArtisanHomeScreenState();
}

class _ArtisanHomeScreenState extends ConsumerState<ArtisanHomeScreen> {
  bool _isPlayingAudioGuide = false;

  void _toggleAudioGuide() {
    setState(() {
      _isPlayingAudioGuide = !_isPlayingAudioGuide;
    });
    final isHindi = ref.read(localeProvider) == AppLocale.hindi;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPlayingAudioGuide
              ? (isHindi
                  ? 'ऑडियो गाइड चल रहा है: "नमस्ते रमेश जी, आज आपके 4 नए ऑर्डर तैयार होने हैं..."'
                  : 'Playing audio guide: "Namaste Ramesh ji, today you have 4 new orders to prepare..."')
              : (isHindi ? 'ऑडियो गाइड बंद किया गया' : 'Audio guide stopped'),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(featuredProductsProvider);
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
                        ref.tr('tagline'),
                        style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const LanguageTogglePill(),
                  const SizedBox(width: 10),

                  // Profile Button - Opens Artisan Profile (NOT voice recording!)
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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(featuredProductsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Artisan Welcome Greeting & Audio Guide
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        const SizedBox(height: 4),
                        Text(
                          ref.tr('greeting_ramesh'),
                          style: const TextStyle(
                            fontFamily: 'Literata',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.yard_outlined, size: 16, color: AppColors.tertiary),
                            const SizedBox(width: 4),
                            Text(
                              ref.tr('artisan_craft'),
                              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Audio Guide Companion Button
                  GestureDetector(
                    onTap: _toggleAudioGuide,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _isPlayingAudioGuide ? AppColors.secondaryContainer : AppColors.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 4)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isPlayingAudioGuide ? Icons.pause : Icons.volume_up,
                            color: _isPlayingAudioGuide ? AppColors.onSecondaryContainer : AppColors.primary,
                            size: 24,
                          ),
                          Text(
                            _isPlayingAudioGuide ? ref.tr('pause') : ref.tr('listen'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _isPlayingAudioGuide ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Primary Action: Camera-First Artisan Upload Card
              GestureDetector(
                onTap: () => context.push('/artisan/add-item/camera'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x209D3E14), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_camera_rounded, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.tr('open_camera').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryFixed,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.tr('add_new_item'),
                              style: const TextStyle(
                                fontFamily: 'Literata',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.tr('camera_desc'),
                              style: const TextStyle(fontSize: 12, color: AppColors.primaryFixedDim),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryFixed, size: 24),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Secondary Action: Artisanal Voice Input Card
              GestureDetector(
                onTap: () => context.push('/artisan/add-item/voice-describe'),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mic, size: 26, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  ref.tr('add_by_voice'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.tertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.tr('speak_story'),
                              style: const TextStyle(
                                fontFamily: 'Literata',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              ref.tr('voice_desc'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.graphic_eq, color: AppColors.tertiary, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Summary Tiles (आज का लेखा-जोखा)
              Text(
                ref.tr('today_summary'),
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildMetricTile(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.secondary,
                    period: ref.tr('period_today'),
                    value: '₹3,450',
                    label: ref.tr('today_earnings'),
                    onTap: () => context.push('/artisan/earnings'),
                  ),
                  const SizedBox(width: 8),
                  _buildMetricTile(
                    icon: Icons.shopping_bag_outlined,
                    iconColor: AppColors.primary,
                    period: isHindi ? 'नया' : 'New',
                    value: ref.tr('orders_count_4'),
                    label: ref.tr('new_orders'),
                    onTap: () => context.push('/artisan/orders'),
                  ),
                  const SizedBox(width: 8),
                  _buildMetricTile(
                    icon: Icons.festival_outlined,
                    iconColor: AppColors.tertiary,
                    period: ref.tr('period_week'),
                    value: ref.tr('fairs_count_2'),
                    label: ref.tr('craft_fairs'),
                    onTap: () => context.push('/artisan/fairs'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Studio Craft Gallery (दुकान में उपलब्ध)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.tr('available_in_shop'),
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/artisan/shop-catalog/art_1'),
                    child: Text(
                      '${ref.tr('view_all')} (18)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              productsAsync.when(
                loading: () => const SizedBox(
                  height: 170,
                  child: Row(
                    children: [
                      ShimmerLoadingBox(width: 140, height: 160),
                      SizedBox(width: 12),
                      ShimmerLoadingBox(width: 140, height: 160),
                    ],
                  ),
                ),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(isHindi ? 'सामान लोड करने में समस्या आई' : 'Failed to load crafts'),
                      ),
                      TextButton(
                        onPressed: () => ref.refresh(featuredProductsProvider),
                        child: Text(isHindi ? 'पुनः प्रयास' : 'Retry'),
                      ),
                    ],
                  ),
                ),
                data: (products) => SizedBox(
                  height: 185,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      final pName = isHindi ? p.nameHi : p.nameEn;
                      final priceStr = isHindi ? '₹${p.price.toInt()}' : '₹${p.price.toInt()}';
                      final stockStr = '${p.stock} ${ref.tr('stock_left')}';

                      return GestureDetector(
                        onTap: () => context.push('/customer/product/${p.id}'),
                        child: Container(
                          width: 148,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  p.imageUrl,
                                  height: 95,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 95,
                                    color: AppColors.surfaceContainer,
                                    child: const Icon(Icons.image, color: AppColors.outline),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                pName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    priceStr,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryFixed,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      stockStr,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 6. Direct Artisan Assistance Bar (1800-200-8899)
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
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.support_agent, size: 24, color: AppColors.onSecondaryContainer),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ref.tr('direct_help'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    ref.tr('free'),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ref.tr('talk_to_craft_friend'),
                              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_in_talk, size: 20, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String period,
    required String value,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: 22, color: iconColor),
                  Text(
                    period,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
