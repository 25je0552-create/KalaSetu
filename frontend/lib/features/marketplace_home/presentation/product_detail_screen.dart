import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../data/product_repository.dart';
import '../../cart_checkout/presentation/cart_controller.dart';

import '../../../core/services/auth_service.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  final bool? isBuyerContext;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.isBuyerContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final locale = ref.watch(localeProvider);
    final isHindi = locale == AppLocale.hindi;
    final user = ref.watch(authStateProvider);

    String currentPath = '';
    try {
      currentPath = GoRouterState.of(context).uri.path;
    } catch (_) {}

    final isBuyer = isBuyerContext ??
        (currentPath.startsWith('/buyer') ||
            currentPath.startsWith('/customer') ||
            user?.role == UserRole.customer);
    debugPrint('[ProductDetailScreen] Rendered. productId=$productId, isBuyer=$isBuyer');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(ref.tr('craft_detail_title'), style: const TextStyle(fontFamily: 'Literata', fontSize: 18)),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: LanguageTogglePill()),
        ],
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('त्रुटि / Error: $err')),
        data: (p) {
          if (p == null) {
            return Center(child: Text(ref.tr('product_not_found')));
          }

          final primaryName = isHindi ? p.nameHi : p.nameEn;
          final secondaryName = isHindi ? p.nameEn : p.nameHi;
          final primaryDesc = isHindi ? p.descriptionHi : p.descriptionEn;
          final secondaryDesc = isHindi ? p.descriptionEn : p.descriptionHi;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    p.imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (p.isGI)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(6)),
                        child: Text(ref.tr('gi_tagged_badge'), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    Text(
                      '₹${p.price.toInt()}',
                      style: const TextStyle(fontFamily: 'Be Vietnam Pro', fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  primaryName,
                  style: const TextStyle(fontFamily: 'Literata', fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                Text(
                  secondaryName,
                  style: const TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.outlineVariant),

                // Artisan Info Card
                PotteryCard(
                  backgroundColor: AppColors.surfaceContainerLow,
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.artisanName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(p.cluster, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified, color: AppColors.success, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text(ref.tr('artisan_story_label'), style: const TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(primaryDesc, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Text(secondaryDesc, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 24),

                // Conditional action: Add to Cart ONLY on Buyer side; artisan sees live listing status
                if (isBuyer) ...[
                  TerracottaButton(
                    label: '${ref.tr("add_to_cart_btn")} (₹${p.price.toInt()})',
                    icon: Icons.shopping_bag_outlined,
                    onPressed: () {
                      debugPrint('[ProductDetailScreen] Add to cart pressed: productId=$productId, price=${p.price.toInt()}');
                      ref.read(cartControllerProvider.notifier).addItem(p);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$primaryName ${ref.tr("added_to_cart_msg")}')),
                      );
                      context.push('/buyer/cart');
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isHindi ? 'शिल्पकार लाइव लिस्टिंग' : 'Artisan Live Listing',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isHindi
                                    ? 'स्टॉक: ${p.stock} उपलब्ध | मूल्य: ₹${p.price.toInt()}'
                                    : 'Stock: ${p.stock} units available | Price: ₹${p.price.toInt()}',
                                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.edit_note, size: 16),
                          label: Text(isHindi ? 'बदलें' : 'Edit', style: const TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          onPressed: () {
                            debugPrint('[ProductDetailScreen] Artisan edit listing tapped -> navigating to pricing');
                            context.push('/artisan/add-item/pricing');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
