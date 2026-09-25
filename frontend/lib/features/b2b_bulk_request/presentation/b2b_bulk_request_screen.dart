import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';

class B2bBulkRequestScreen extends ConsumerStatefulWidget {
  const B2bBulkRequestScreen({super.key});

  @override
  ConsumerState<B2bBulkRequestScreen> createState() => _B2bBulkRequestScreenState();
}

class _B2bBulkRequestScreenState extends ConsumerState<B2bBulkRequestScreen> {
  final _companyCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _selectedCraft = 'Gorakhpur Terracotta';

  @override
  void initState() {
    super.initState();
    debugPrint('[B2bBulkRequestScreen] Initialized');
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _quantityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isHindi = locale == AppLocale.hindi;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(ref.tr('b2b_request_title'), style: const TextStyle(fontFamily: 'Literata', fontSize: 18)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageTogglePill(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.handshake_outlined, color: AppColors.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ref.tr('b2b_banner_note'),
                      style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _companyCtrl,
                decoration: InputDecoration(
                  labelText: isHindi ? 'संस्था या कंपनी का नाम' : 'Organization / Buyer Name',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCraft,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: isHindi ? 'वांछित शिल्प श्रेणी' : 'Craft Category',
                ),
                items: [
                  'Gorakhpur Terracotta',
                  'Maheshwar Handloom Silk',
                  'Moradabad Brass Art',
                  'Kashmiri Pashmina',
                ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (val) {
                  debugPrint('[B2bBulkRequestScreen] Craft category changed: $val');
                  setState(() => _selectedCraft = val ?? _selectedCraft);
                },
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _quantityCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isHindi ? 'अनुमानित संख्या (e.g. 50, 200)' : 'Estimated Pieces / Qty (e.g. 50, 200)',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: isHindi ? 'विशेष आवश्यकताएं या कस्टम लोगो' : 'Special Specifications / Custom Branding',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 28),
            TerracottaButton(
              label: isHindi ? 'कोटेशन अनुरोध भेजें' : 'Submit Quotation Request',
              icon: Icons.send,
              onPressed: () {
                debugPrint('[B2bBulkRequestScreen] Quotation request submitted: company="${_companyCtrl.text}", craft="$_selectedCraft", qty="${_quantityCtrl.text}"');
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(isHindi ? 'अनुरोध प्राप्त हुआ!' : 'Request Received!'),
                    content: Text(isHindi
                        ? 'क्लस्टर समन्वयक 24 घंटे में आपसे सीधे संपर्क करेंगे।'
                        : 'A cluster coordinator will connect directly with you within 24 hours.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          debugPrint('[B2bBulkRequestScreen] Request dialog OK pressed -> popping screen');
                          Navigator.pop(context);
                          context.pop();
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
