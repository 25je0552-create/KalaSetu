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
  void dispose() {
    _titleHiCtrl.dispose();
    _titleEnCtrl.dispose();
    _descHiCtrl.dispose();
    _descEnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'एआई विवरण समीक्षा • AI Review',
          style: TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, fontSize: 18),
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
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.secondary, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'आपकी आवाज से स्वतः हिंदी व अंग्रेजी में विवरण तैयार किया गया है। आवश्यकतानुसार बदलाव कर सकते हैं।',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSecondaryFixed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hindi Title & Description
              const Text(
                'हिंदी विवरण (Artisan View)',
                style: TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _titleHiCtrl,
                  decoration: const InputDecoration(
                    labelText: 'उत्पाद का नाम (Hindi Title)',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _descHiCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'विस्तृत विवरण (Hindi Story)',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // English Title & Description
              const Text(
                'English Description (Buyer View)',
                style: TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _titleEnCtrl,
                  decoration: const InputDecoration(
                    labelText: 'English Title',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _descEnCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'English Story for Global Buyers',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Extracted Attributes
              const Text('पहचाने गए शिल्प गुण (Craft Attributes)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: Icon(Icons.check, size: 14, color: AppColors.primary),
                    label: Text('सामग्री: शुद्ध सिल्क व सूती धागा'),
                    backgroundColor: AppColors.surfaceContainer,
                  ),
                  Chip(
                    avatar: Icon(Icons.check, size: 14, color: AppColors.primary),
                    label: Text('तकनीक: पारंपरिक हथकरघा (Pit-loom)'),
                    backgroundColor: AppColors.surfaceContainer,
                  ),
                  Chip(
                    avatar: Icon(Icons.check, size: 14, color: AppColors.primary),
                    label: Text('रंग: प्राकृतिक वनस्पति रंग'),
                    backgroundColor: AppColors.surfaceContainer,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              TerracottaButton(
                label: 'मूल्य निर्धारण पर जाएं • Set Pricing',
                icon: Icons.currency_rupee,
                onPressed: () {
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
