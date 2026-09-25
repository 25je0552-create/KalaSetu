import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../marketplace_home/data/product_repository.dart';
import '../../artisan_profile/data/artisan_repository.dart';
import '../../../mock_data/mock_data_loader.dart';

class ShopCatalogScreen extends ConsumerStatefulWidget {
  final String artisanId;

  const ShopCatalogScreen({
    super.key,
    this.artisanId = 'art_1',
  });

  @override
  ConsumerState<ShopCatalogScreen> createState() => _ShopCatalogScreenState();
}

class _ShopCatalogScreenState extends ConsumerState<ShopCatalogScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final isHindi = ref.watch(localeProvider) == AppLocale.hindi;
    final artisanAsync = ref.watch(artisanByIdProvider(widget.artisanId));
    final productsAsync = ref.watch(artisanProductsProvider(widget.artisanId));

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
                    isHindi ? 'दुकान कैटलॉग' : 'Shop Catalog',
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
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(
          child: Text(isHindi ? 'कैटलॉग लोड करने में विफल: $err' : 'Failed to load catalog: $err'),
        ),
        data: (products) {
          final categories = <String>['All', ...products.map((p) => p.category).toSet()];
          var filtered = products;

          if (_selectedCategory != 'All') {
            filtered = filtered.where((p) => p.category == _selectedCategory).toList();
          }

          if (_searchQuery.trim().isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            filtered = filtered.where((p) {
              return p.nameEn.toLowerCase().contains(q) ||
                  p.nameHi.toLowerCase().contains(q) ||
                  p.category.toLowerCase().contains(q);
            }).toList();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Artisan Shop Header Card
                artisanAsync.when(
                  loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (artisan) {
                    final name = artisan?.name ?? (isHindi ? 'रमेश प्रजापति' : 'Ramesh Prajapati');
                    final craft = artisan?.craftType ?? (isHindi ? 'माटी शिल्पी' : 'Terracotta Artisan');
                    final location = artisan != null
                        ? '${artisan.village}, ${artisan.district}'
                        : (isHindi ? 'औरंगाबाद, गोरखपुर' : 'Aurangabad, Gorakhpur');

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                              color: AppColors.surfaceContainer,
                            ),
                            child: ClipOval(
                              child: Image.network(
                                artisan?.avatarUrl ?? 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=400&q=80',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.storefront, size: 32, color: AppColors.primary),
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
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontFamily: 'Literata',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  '$craft • $location',
                                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFD4A373)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${artisan?.rating ?? 4.9} (${products.length} ${isHindi ? 'शिल्प उपलब्ध' : 'crafts listed'})',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.outline, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: isHindi ? 'इस दुकान में खोजें...' : 'Search within shop catalog...',
                            border: InputBorder.none,
                            hintStyle: const TextStyle(fontSize: 13, color: AppColors.outline),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: AppColors.outline),
                          onPressed: () => setState(() => _searchQuery = ''),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Category Filter Chips
                if (categories.length > 2)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSel = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              cat == 'All' ? (isHindi ? 'सभी सामान' : 'All Items') : cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                color: isSel ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            onSelected: (val) {
                              if (val) setState(() => _selectedCategory = cat);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (categories.length > 2) const SizedBox(height: 16),

                // 4. Products Section Heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isHindi ? 'उपलब्ध शिल्प वस्तुएं' : 'Shop Crafts Collection',
                      style: const TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      '${filtered.length} ${isHindi ? 'वस्तुएं' : 'items'}',
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. Products Grid
                if (filtered.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.outline),
                          const SizedBox(height: 12),
                          Text(
                            isHindi ? 'कोई शिल्प नहीं मिला' : 'No crafts match your search',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      final pName = isHindi ? p.nameHi : p.nameEn;
                      final priceStr = '₹${p.price.toInt()}';
                      final stockStr = '${p.stock} ${ref.tr('stock_left')}';

                      return GestureDetector(
                        onTap: () => context.push('/customer/product/${p.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                      child: Image.network(
                                        p.imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: AppColors.surfaceContainer,
                                          child: const Center(child: Icon(Icons.image, color: AppColors.outline)),
                                        ),
                                      ),
                                    ),
                                    if (p.isGI)
                                      Positioned(
                                        top: 6,
                                        left: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'GI CERTIFIED',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          priceStr,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFD4A373)),
                                            Text(
                                              '${p.rating}',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
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
                                          color: AppColors.onSecondaryFixed,
                                        ),
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
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(
          isHindi ? 'नया शिल्प जोड़ें' : 'Add Craft',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.push('/artisan/add-item/camera'),
      ),
    );
  }
}
