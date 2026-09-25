import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/clay_widgets.dart';

class CustomerAccountScreen extends ConsumerWidget {
  const CustomerAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    debugPrint('[CustomerAccountScreen] Rendered for user: ${user?.name ?? "Guest"}');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('खाता • Account', style: TextStyle(fontFamily: 'Literata', fontSize: 18)),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: LanguageTogglePill()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
                child: const Icon(Icons.person, size: 40, color: AppColors.onSecondaryContainer),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.name ?? 'अमित शर्मा (Amit Sharma)',
              style: const TextStyle(fontFamily: 'Literata', fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? user?.phone ?? '+91 98765 43210',
              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 28),

            // Switch to Artisan Track Button
            PotteryCard(
              backgroundColor: AppColors.surfaceContainerLow,
              onTap: () {
                debugPrint('[CustomerAccountScreen] Role switch to Artisan -> navigating to /artisan/home');
                ref.read(authStateProvider.notifier).selectRole(UserRole.artisan);
                context.go('/artisan/home');
              },
              child: const Row(
                children: [
                  Icon(Icons.swap_horiz, color: AppColors.primary, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('कारीगर ट्रैक में जाएं (Switch to Artisan)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('अपनी दुकान, मेले और नया सामान प्रबंधित करें', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 16),

            PotteryCard(
              onTap: () {
                debugPrint('[CustomerAccountScreen] Sign out confirmed -> navigating to /login');
                ref.read(authStateProvider.notifier).signOut();
                context.go('/login');
              },
              child: const Row(
                children: [
                  Icon(Icons.logout, color: AppColors.error, size: 22),
                  SizedBox(width: 12),
                  Text('लॉग आउट करें (Sign Out)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
