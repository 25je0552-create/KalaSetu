import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';
import 'add_item_wizard_controller.dart';

class AiReviewScreen extends ConsumerStatefulWidget {
  const AiReviewScreen({super.key});

  @override
  ConsumerState<AiReviewScreen> createState() => _AiReviewScreenState();
}

class _AiReviewScreenState extends ConsumerState<AiReviewScreen> {
  final TextEditingController _titleHiCtrl = TextEditingController(text: 'पारंपरिक हाथ की बनी महेश्वरी साड़ी');
  final TextEditingController _titleEnCtrl = TextEditingController(text: 'Traditional Handwoven Maheshwari Saree');
  final TextEditingController _descHiCtrl = TextEditingController(
    text: 'नर्मदा तट के बुनकरों द्वारा हथकरघे पर तैयार प्राकृतिक नील और हल्दी रंगों से रंजित शुद्ध सिल्क-कॉटन साड़ी।',
  );
  final TextEditingController _descEnCtrl = TextEditingController(
    text: 'Pure silk-cotton saree handwoven on traditional pit looms in Maheshwar, dyed with organic indigo and turmeric.',
  );

  @override
  void initState() {
    super.initState();
    debugPrint('[AiReviewScreen] Initialized. Prepopulated AI title & description ready for review.');
  }

  @override
  void dispose() {
    _titleHiCtrl.dispose();
    _titleEnCtrl.dispose();
    _descHiCtrl.dispose();
    _descEnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = ref.watch(localeProvider) == AppLocale.hindi;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          ref.tr('ai_review_title'),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ref.tr('ai_review_banner'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSecondaryFixed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Localized Title & Description based on active language
              if (isHindi) ...[
                // Hindi Title & Description
                Text(
                  ref.tr('hindi_desc_title'),
                  style: const TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _titleHiCtrl,
                    decoration: InputDecoration(
                      labelText: ref.tr('hindi_title_label'),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _descHiCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: ref.tr('hindi_desc_label'),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ] else ...[
                // English Title & Description (English-only mode)
                Text(
                  ref.tr('english_desc_title'),
                  style: const TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _titleEnCtrl,
                    decoration: InputDecoration(
                      labelText: ref.tr('english_title_label'),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _descEnCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: ref.tr('english_desc_label'),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Extracted Attributes
              Text(ref.tr('craft_attributes_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.check, size: 14, color: AppColors.primary),
                    label: Text(ref.watch(localeProvider) == AppLocale.hindi ? 'सामग्री: शुद्ध सिल्क व सूती धागा' : 'Material: Pure Silk & Cotton'),
                    backgroundColor: AppColors.surfaceContainer,
                  ),
                  Chip(
                    avatar: const Icon(Icons.check, size: 14, color: AppColors.primary),
                    label: Text(ref.watch(localeProvider) == AppLocale.hindi ? 'तकनीक: पारंपरिक हथकरघा' : 'Technique: Pit-loom Weaving'),
                    backgroundColor: AppColors.surfaceContainer,
                  ),
                  Chip(
                    avatar: const Icon(Icons.check, size: 14, color: AppColors.primary),
                    label: Text(ref.watch(localeProvider) == AppLocale.hindi ? 'रंग: प्राकृतिक वनस्पति रंग' : 'Dyes: Natural Indigo & Turmeric'),
                    backgroundColor: AppColors.surfaceContainer,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              TerracottaButton(
                label: ref.tr('set_pricing_btn'),
                icon: Icons.currency_rupee,
                onPressed: () {
                  debugPrint('[AiReviewScreen] Set Pricing tapped. nameHi: "${_titleHiCtrl.text}", nameEn: "${_titleEnCtrl.text}"');
                  ref.read(addItemWizardProvider.notifier).updateDetails(
                    nameHi: _titleHiCtrl.text,
                    nameEn: _titleEnCtrl.text,
                  );
                  context.push('/artisan/add-item/pricing');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
