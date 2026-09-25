import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import 'add_item_wizard_controller.dart';

class PricingScreen extends ConsumerStatefulWidget {
  const PricingScreen({super.key});

  @override
  ConsumerState<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends ConsumerState<PricingScreen> {
  final double _rawMaterial = 1800;
  final double _laborHours = 14;
  final double _hourlyRate = 120;
  int _stock = 1;
  bool _isPublishing = false;

  double get _laborCost => _laborHours * _hourlyRate;
  double get _minimumFairPrice => _rawMaterial + _laborCost;
  double get _suggestedListingPrice => (_minimumFairPrice * 1.25).roundToDouble();

  Future<void> _handlePublish() async {
    setState(() => _isPublishing = true);
    await ref.read(addItemWizardProvider.notifier).publishItem();

    if (mounted) {
      setState(() => _isPublishing = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surfaceBright,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, size: 36, color: AppColors.onSecondaryContainer),
              ),
              const SizedBox(height: 16),
              Text(
                ref.tr('publish_success_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                ref.tr('publish_success_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              TerracottaButton(
                label: ref.tr('back_to_home_btn'),
                onPressed: () {
                  ref.read(addItemWizardProvider.notifier).reset();
                  Navigator.pop(context);
                  context.go('/artisan/home');
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          ref.tr('pricing_title'),
          style: const TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageTogglePill(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fair price notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ref.tr('fair_price_guarantee'),
                        style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Cost Breakdown Calculator
              Text(
                ref.tr('cost_breakdown_title'),
                style: const TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ref.tr('raw_material_label'), style: const TextStyle(fontSize: 14)),
                        Text('₹${_rawMaterial.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.outlineVariant),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${ref.tr("labor_time_label")} (${_laborHours.toInt()}h x ₹${_hourlyRate.toInt()}):', style: const TextStyle(fontSize: 14)),
                        Text('₹${_laborCost.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.outlineVariant),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ref.tr('artisan_margin_label'), style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                        Text(ref.tr('margin_guarantee_badge'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 13)),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1.5, color: AppColors.outlineVariant),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ref.tr('suggested_price_label'),
                          style: const TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${_suggestedListingPrice.toInt()}',
                          style: const TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Inventory Stock Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ref.tr('stock_quantity_label'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: () {
                            if (_stock > 1) setState(() => _stock--);
                          },
                        ),
                        Text('$_stock', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setState(() => _stock++),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              TerracottaButton(
                label: ref.tr('publish_item_btn'),
                icon: Icons.storefront,
                isLoading: _isPublishing,
                onPressed: _handlePublish,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
