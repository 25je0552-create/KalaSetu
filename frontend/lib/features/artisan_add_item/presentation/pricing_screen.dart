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
  late TextEditingController _priceController;

  double get _laborCost => _laborHours * _hourlyRate;
  double get _minimumFairPrice => _rawMaterial + _laborCost;
  double get _suggestedListingPrice => (_minimumFairPrice * 1.25).roundToDouble();

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: _suggestedListingPrice.toInt().toString());
    debugPrint('[PricingScreen] Initialized. suggestedPrice=$_suggestedListingPrice, rawMaterial=$_rawMaterial, laborHours=$_laborHours');
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    final enteredPrice = double.tryParse(_priceController.text.trim()) ?? _suggestedListingPrice;
    debugPrint('[PricingScreen] Publishing item with price: ₹$enteredPrice, stock: $_stock');
    setState(() => _isPublishing = true);
    ref.read(addItemWizardProvider.notifier).updateDetails(
      rawMaterialCost: _rawMaterial,
      laborHours: _laborHours,
      suggestedPrice: enteredPrice,
      stock: _stock,
    );
    await ref.read(addItemWizardProvider.notifier).publishItem();
    debugPrint('[PricingScreen] Item published successfully. Showing confirmation modal.');

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
                  debugPrint('[PricingScreen] Back to home tapped -> resetting wizard and navigating to /artisan/home');
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                '${ref.tr('suggested_market_price')}:',
                                style: const TextStyle(
                                  fontFamily: 'Literata',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '₹${_suggestedListingPrice.toInt()}',
                            style: const TextStyle(
                              fontFamily: 'Be Vietnam Pro',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Artisan Custom Listing Price Input
              Text(
                ref.tr('your_price_label'),
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ref.tr('price_override_hint'),
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    const Text(
                      '₹',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
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
                            if (_stock > 1) {
                              debugPrint('[PricingScreen] Stock decreased to: ${_stock - 1}');
                              setState(() => _stock--);
                            }
                          },
                        ),
                        Text('$_stock', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () {
                            debugPrint('[PricingScreen] Stock increased to: ${_stock + 1}');
                            setState(() => _stock++);
                          },
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
