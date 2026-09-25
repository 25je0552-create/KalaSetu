import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/language_select_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/otp_verify_screen.dart';
import '../../features/auth/presentation/role_select_screen.dart';
import '../../features/artisan_home/presentation/artisan_home_screen.dart';
import '../../features/artisan_fairs/presentation/artisan_fairs_screen.dart';
import '../../features/artisan_orders/presentation/artisan_orders_screen.dart';
import '../../features/artisan_earnings/presentation/artisan_earnings_screen.dart';
import '../../features/artisan_profile/presentation/voice_onboarding_screen.dart';
import '../../features/artisan_add_item/presentation/artisan_camera_screen.dart';
import '../../features/artisan_add_item/presentation/photo_review_screen.dart';
import '../../features/artisan_add_item/presentation/voice_describe_screen.dart';
import '../../features/artisan_add_item/presentation/ai_review_screen.dart';
import '../../features/artisan_add_item/presentation/pricing_screen.dart';
import '../../features/marketplace_home/presentation/marketplace_home_screen.dart';
import '../../features/marketplace_home/presentation/product_detail_screen.dart';
import '../../features/marketplace_home/presentation/customer_account_screen.dart';
import '../../features/cart_checkout/presentation/cart_screen.dart';
import '../../features/b2b_bulk_request/presentation/b2b_bulk_request_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authUser = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthRoute = state.uri.path == '/splash' ||
          state.uri.path == '/onboarding-language' ||
          state.uri.path == '/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/otp-verify';

      // Route Guard: unauthenticated requests to /artisan/* or /customer/* redirect to /login
      if (authUser == null && !isAuthRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      // ═══════════════════════════════════════════════════════════
      // SHELL A: AUTH FLOW (Linear, no bottom nav)
      // ═══════════════════════════════════════════════════════════
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding-language',
        builder: (context, state) => const LanguageSelectScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) {
          final phone = state.extra as String? ?? '+91 98765 43210';
          return OtpVerifyScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/role-select',
        builder: (context, state) => const RoleSelectScreen(),
      ),

      // ═══════════════════════════════════════════════════════════
      // SHELL B: ARTISAN SHELL (StatefulShellRoute with Bottom Nav)
      // ═══════════════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.95),
                border: const Border(top: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
              ),
              height: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildArtisanNavItem(
                    context: context,
                    icon: Icons.cottage,
                    label: 'होम',
                    isSelected: navigationShell.currentIndex == 0,
                    onTap: () => navigationShell.goBranch(0),
                  ),
                  _buildArtisanAddItemButton(
                    context: context,
                    onTap: () => context.push('/artisan/add-item/camera'),
                  ),
                  _buildArtisanNavItem(
                    context: context,
                    icon: Icons.festival,
                    label: 'मेले',
                    isSelected: navigationShell.currentIndex == 1,
                    onTap: () => navigationShell.goBranch(1),
                  ),
                  _buildArtisanNavItem(
                    context: context,
                    icon: Icons.payments,
                    label: 'कमाई',
                    isSelected: navigationShell.currentIndex == 2,
                    onTap: () => navigationShell.goBranch(2),
                  ),
                ],
              ),
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/artisan/home',
                builder: (context, state) => const ArtisanHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/artisan/fairs',
                builder: (context, state) => const ArtisanFairsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/artisan/earnings',
                builder: (context, state) => const ArtisanEarningsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Artisan Linear Wizard & Fullscreen Routes (Pushed on root navigator)
      GoRoute(
        path: '/artisan/add-item/camera',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ArtisanCameraScreen(),
      ),
      GoRoute(
        path: '/artisan/add-item/photo-review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PhotoReviewScreen(),
      ),
      GoRoute(
        path: '/artisan/add-item/voice-describe',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VoiceDescribeScreen(),
      ),
      GoRoute(
        path: '/artisan/add-item/ai-review',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiReviewScreen(),
      ),
      GoRoute(
        path: '/artisan/add-item/pricing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: '/artisan/orders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ArtisanOrdersScreen(),
      ),
      GoRoute(
        path: '/artisan/voice-onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VoiceOnboardingScreen(),
      ),

      // ═══════════════════════════════════════════════════════════
      // SHELL C: CUSTOMER SHELL (StatefulShellRoute with Bottom Nav)
      // ═══════════════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              backgroundColor: AppColors.surfaceContainerHigh,
              indicatorColor: AppColors.primary.withOpacity(0.15),
              onDestinationSelected: (idx) => navigationShell.goBranch(idx),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront, color: AppColors.primary), label: 'शिल्प'),
                NavigationDestination(icon: Icon(Icons.festival_outlined), selectedIcon: Icon(Icons.festival, color: AppColors.primary), label: 'मेले'),
                NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag, color: AppColors.primary), label: 'कार्ट'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: AppColors.primary), label: 'खाता'),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customer/home',
                builder: (context, state) => const MarketplaceHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customer/fairs',
                builder: (context, state) => const ArtisanFairsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customer/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customer/account',
                builder: (context, state) => const CustomerAccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // Customer Deep Links & Detail Routes
      GoRoute(
        path: '/customer/product/:productId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final pid = state.pathParameters['productId'] ?? 'prod_1';
          return ProductDetailScreen(productId: pid);
        },
      ),
      GoRoute(
        path: '/customer/b2b/bulk-request',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const B2bBulkRequestScreen(),
      ),
    ],
  );
});

Widget _buildArtisanNavItem({
  required BuildContext context,
  required IconData icon,
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 26, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _buildArtisanAddItemButton({
  required BuildContext context,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          margin: const EdgeInsets.only(top: 2),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color(0x339D3E14), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 2),
        const Text(
          'जोड़ें',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    ),
  );
}
