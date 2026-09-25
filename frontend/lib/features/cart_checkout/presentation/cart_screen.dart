import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import 'cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartControllerProvider);
    final total = ref.watch(cartTotalAmountProvider);
    final locale = ref.watch(localeProvider);
    final isHindi = locale == AppLocale.hindi;
    debugPrint('[CartScreen] Rendered. cartItemsCount=${cartItems.length}, total=₹${total.toInt()}');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(ref.tr('craft_cart_title'), style: const TextStyle(fontFamily: 'Literata', fontSize: 18)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageTogglePill(),
          ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.outline),
                  const SizedBox(height: 12),
                  Text(ref.tr('cart_empty_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(ref.tr('cart_empty_subtitle'), style: const TextStyle(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: TerracottaButton(
                      label: ref.tr('shop_crafts_btn'),
                      onPressed: () {
                        debugPrint('[CartScreen] Empty cart button tapped -> navigating to /customer/home');
                        context.go('/customer/home');
                      },
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final name = isHindi ? item.product.nameHi : item.product.nameEn;
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('₹${item.product.price.toInt()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () {
                                    debugPrint('[CartScreen] Quantity decreased for product: ${item.product.id}');
                                    ref.read(cartControllerProvider.notifier).updateQuantity(item.product.id, -1);
                                  },
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () {
                                    debugPrint('[CartScreen] Quantity increased for product: ${item.product.id}');
                                    ref.read(cartControllerProvider.notifier).updateQuantity(item.product.id, 1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Bill Details
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${ref.tr("subtotal_label")}:'),
                            Text('₹${total.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${ref.tr("delivery_label")}:'),
                            Text(ref.tr('free_label'), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${ref.tr("total_label")}:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('₹${total.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TerracottaButton(
                    label: '${ref.tr("checkout_btn")} (₹${total.toInt()})',
                    icon: Icons.lock_outline,
                    onPressed: () {
                      debugPrint('[CartScreen] Checkout confirmed for total: ₹${total.toInt()}');
                      ref.read(cartControllerProvider.notifier).clear();
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          title: Text(isHindi ? 'ऑर्डर सफल!' : 'Order Placed!'),
                          content: Text(isHindi
                              ? 'कारीगर को सूचना भेज दी गई है। आपका हस्तशिल्प सुरक्षित पैकेजिंग में भेजा जाएगा।'
                              : 'Artisan has been notified. Your authentic handcrafted art will be dispatched securely.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                debugPrint('[CartScreen] Order success dialog OK pressed -> navigating to /customer/home');
                                Navigator.pop(context);
                                context.go('/customer/home');
                              },
                              child: Text(isHindi ? 'ठीक है' : 'OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
