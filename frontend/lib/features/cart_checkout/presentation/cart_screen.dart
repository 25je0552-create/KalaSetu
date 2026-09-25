import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import 'cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartControllerProvider);
    final total = ref.watch(cartTotalAmountProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('शिल्प कार्ट • Craft Cart', style: TextStyle(fontFamily: 'Literata', fontSize: 18)),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.outline),
                  const SizedBox(height: 12),
                  const Text('आपकी कार्ट खाली है', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('कारीगरों की कलाकृतियों को कार्ट में जोड़ें', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: TerracottaButton(
                      label: 'शिल्प देखें (Shop)',
                      onPressed: () => context.go('/customer/home'),
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
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
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
                                  Text(item.product.nameHi, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('₹${item.product.price.toInt()}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () => ref.read(cartControllerProvider.notifier).updateQuantity(item.product.id, -1),
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () => ref.read(cartControllerProvider.notifier).updateQuantity(item.product.id, 1),
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
                            const Text('शिल्प मूल्य (Items total):'),
                            Text('₹${total.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('डिलीवरी (Rural cluster dispatch):'),
                            Text('निःशुल्क (FREE)', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('कुल राशि (Total):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('₹${total.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TerracottaButton(
                    label: 'ऑर्डर करें • Place Order (₹${total.toInt()})',
                    icon: Icons.lock_outline,
                    onPressed: () {
                      ref.read(cartControllerProvider.notifier).clear();
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          title: const Text('ऑर्डर सफल! (Order Placed)'),
                          content: const Text('कारीगर को सूचना भेज दी गई है। आपका हस्तशिल्प सुरक्षित पैकेजिंग में भेजा जाएगा।'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.go('/customer/home');
                              },
                              child: const Text('ठीक है'),
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
