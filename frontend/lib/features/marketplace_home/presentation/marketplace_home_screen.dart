import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../data/product_repository.dart';
import '../../cart_checkout/presentation/cart_controller.dart';

class MarketplaceHomeScreen extends ConsumerStatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  ConsumerState<MarketplaceHomeScreen> createState() => _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends ConsumerState<MarketplaceHomeScreen> {
  String _selectedCluster = '';
  final List<String> _clusters = [
    'सभी (All)',
    'Gorakhpur Terracotta',
    'Maheshwar Handloom',
    'Moradabad Brass',
    'Kashmir Pashmina'
  ];

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(featuredProductsProvider);
    final cartCount = ref.watch(cartItemCountProvider);
    final locale = ref.watch(localeProvider);
    final isHindi = locale == AppLocale.hindi;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(AppConstants.logoPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text(
              'KalaSetu',
              style: TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          const LanguageTogglePill(),
          const SizedBox(width: 8),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.onSurface),
                if (cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.push('/customer/cart'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.refresh(featuredProductsProvider),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
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
                        decoration: InputDecoration(
                          hintText: ref.tr('marketplace_search_hint'),
                          border: InputBorder.none,
                          hintStyle: const TextStyle(fontSize: 14, color: AppColors.outline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // B2B Wholesale Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined, color: AppColors.secondary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ref.tr('b2b_wholesale_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(ref.tr('b2b_wholesale_subtitle'), style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/customer/b2b/bulk-request'),
                      child: Text(ref.tr('get_quote_btn'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Craft Clusters horizontal filter
              Text(
                ref.tr('craft_clusters_title'),
                style: const TextStyle(fontFamily: 'Literata', fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _clusters.map((c) {
                    final isAll = c.startsWith('सभी');
                    final isSel = _selectedCluster == c || (_selectedCluster.isEmpty && isAll);
                    final displayName = isAll ? ref.tr('all_cluster_filter') : c;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(displayName, style: TextStyle(fontSize: 12, color: isSel ? Colors.white : AppColors.onSurface)),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        onSelected: (_) => setState(() => _selectedCluster = isAll ? '' : c),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Featured Handcrafts Grid
              Text(
                ref.tr('featured_crafts_title'),
                style: const TextStyle(fontFamily: 'Literata', fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (err, _) => Center(child: Text('त्रुटि / Error: $err')),
                data: (products) {
                  final filtered = _selectedCluster.isEmpty
                      ? products
                      : products.where((p) => p.cluster.contains(_selectedCluster)).toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      final name = isHindi ? p.nameHi : p.nameEn;
                      return GestureDetector(
                        onTap: () => context.push('/customer/product/${p.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      p.imageUrl,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  if (p.isGI)
                                    Positioned(
                                      top: 6,
                                      left: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'GI TAG',
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                p.artisanName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹${p.price.toInt()}',
                                    style: const TextStyle(
                                      fontFamily: 'Be Vietnam Pro',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(cartControllerProvider.notifier).addItem(p);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('$name ${ref.tr("added_to_cart_msg")}'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
