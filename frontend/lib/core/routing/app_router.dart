import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../localization/app_localizations.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/language_select_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/buyer_login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/otp_verify_screen.dart';
import '../../features/auth/presentation/role_select_screen.dart';
import '../../features/artisan_home/presentation/artisan_home_screen.dart';
import '../../features/artisan_home/presentation/shop_catalog_screen.dart';
import '../../features/artisan_fairs/presentation/artisan_fairs_screen.dart';
import '../../features/artisan_fairs/presentation/fair_detail_screen.dart';
import '../../features/artisan_orders/presentation/artisan_orders_screen.dart';
import '../../features/artisan_earnings/presentation/artisan_earnings_screen.dart';
import '../../features/artisan_profile/presentation/artisan_profile_screen.dart';
import '../../features/artisan_profile/presentation/voice_onboarding_screen.dart';
import '../../features/artisan_profile/presentation/artisan_story_text_screen.dart';
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
          state.uri.path == '/buyer/login' ||
          state.uri.path == '/signup' ||
          state.uri.path == '/otp-verify';

      // Route Guard: unauthenticated requests redirect to appropriate login
      if (authUser == null && !isAuthRoute) {
        if (state.uri.path.startsWith('/buyer')) {
          return '/buyer/login';
        }
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
        path: '/buyer/login',
        builder: (context, state) => const BuyerLoginScreen(),
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
            bottomNavigationBar: _ArtisanBottomBar(navigationShell: navigationShell),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/artisan/profile',
                builder: (context, state) => const ArtisanProfileScreen(),
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
      GoRoute(
        path: '/artisan/story-input',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ArtisanStoryTextInputScreen(),
      ),
      GoRoute(
        path: '/artisan/shop-catalog/:artisanId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final aid = state.pathParameters['artisanId'] ?? 'art_1';
          return ShopCatalogScreen(artisanId: aid);
        },
      ),
      GoRoute(
        path: '/artisan/shop-catalog',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final aid = state.uri.queryParameters['id'] ?? 'art_1';
          return ShopCatalogScreen(artisanId: aid);
        },
      ),

      // ═══════════════════════════════════════════════════════════
      // SHELL C: CUSTOMER SHELL (StatefulShellRoute with Bottom Nav)
      // ═══════════════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: _CustomerBottomBar(navigationShell: navigationShell),
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

      // Dedicated Buyer App Routes (/buyer/* namespace)
      GoRoute(
        path: '/buyer/home',
        builder: (context, state) => const MarketplaceHomeScreen(),
      ),
      GoRoute(
        path: '/buyer/product/:productId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final pid = state.pathParameters['productId'] ?? 'prod_1';
          return ProductDetailScreen(productId: pid);
        },
      ),
      GoRoute(
        path: '/buyer/cart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CartScreen(),
      ),

      // Fair Detail Route
      GoRoute(
        path: '/fair/:fairId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final fid = state.pathParameters['fairId'] ?? 'fair_1';
          return FairDetailScreen(fairId: fid);
        },
      ),
    ],
  );
});

class _ArtisanBottomBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _ArtisanBottomBar({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds automatically on language switch
    ref.watch(localeProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.4), width: 0.8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Home
          _buildArtisanNavItem(
            context: context,
            icon: Icons.cottage,
            label: ref.tr('nav_home'),
            isSelected: navigationShell.currentIndex == 0,
            onTap: () => navigationShell.goBranch(0),
          ),

          // 2. Fairs
          _buildArtisanNavItem(
            context: context,
            icon: Icons.festival,
            label: ref.tr('nav_fairs'),
            isSelected: navigationShell.currentIndex == 1,
            onTap: () => navigationShell.goBranch(1),
          ),

          // 3. Separate Voice Recording / Voice Scribe Button in Bottom Bar
          _buildArtisanVoiceRecordButton(
            context: context,
            ref: ref,
            onTap: () {
              _showVoiceActionSheet(context, ref);
            },
          ),

          // 4. Earnings
          _buildArtisanNavItem(
            context: context,
            icon: Icons.payments,
            label: ref.tr('nav_earnings'),
            isSelected: navigationShell.currentIndex == 2,
            onTap: () => navigationShell.goBranch(2),
          ),

          // 5. Profile (separate from Voice Recording)
          _buildArtisanNavItem(
            context: context,
            icon: Icons.person,
            label: ref.tr('nav_profile'),
            isSelected: navigationShell.currentIndex == 3,
            onTap: () => navigationShell.goBranch(3),
          ),
        ],
      ),
    );
  }

  void _showVoiceActionSheet(BuildContext context, WidgetRef ref) {
    final isHindi = ref.read(localeProvider) == AppLocale.hindi;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceBright,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic, color: AppColors.onSecondaryContainer, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isHindi ? 'स्वर सहायता केंद्र (Voice Hub)' : 'Artisan Voice Hub',
                      style: const TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.record_voice_over, color: Colors.white, size: 22),
                  ),
                  title: Text(
                    isHindi ? 'बोलकर नया सामान जोड़ें' : 'Add Item by Voice (Voice Scribe)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isHindi ? 'अपनी बोली में उत्पाद का विवरण रिकॉर्ड करें' : 'Describe your craft in native dialect',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/artisan/add-item/voice-describe');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.graphic_eq, color: Colors.white, size: 22),
                  ),
                  title: Text(
                    isHindi ? 'स्वर परिचय (Voice Profile Intro)' : 'Artisan Voice Introduction',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isHindi ? 'अपना नाम, शिल्प व गाँव का परिचय बोलें' : 'Introduce your name, craft, and village',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.secondary),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/artisan/voice-onboarding');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CustomerBottomBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _CustomerBottomBar({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds on language switch
    ref.watch(localeProvider);

    return NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      backgroundColor: AppColors.surfaceContainerHigh,
      indicatorColor: AppColors.primary.withValues(alpha: 0.15),
      onDestinationSelected: (idx) => navigationShell.goBranch(idx),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.storefront_outlined),
          selectedIcon: const Icon(Icons.storefront, color: AppColors.primary),
          label: ref.tr('nav_crafts'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.festival_outlined),
          selectedIcon: const Icon(Icons.festival, color: AppColors.primary),
          label: ref.tr('nav_fairs'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.shopping_bag_outlined),
          selectedIcon: const Icon(Icons.shopping_bag, color: AppColors.primary),
          label: ref.tr('nav_cart'),
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person, color: AppColors.primary),
          label: ref.tr('nav_account'),
        ),
      ],
    );
  }
}

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
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildArtisanVoiceRecordButton({
  required BuildContext context,
  required WidgetRef ref,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x339D3E14),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
          ),
          child: const Icon(Icons.mic, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 2),
        Text(
          ref.tr('nav_voice_short'),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}
