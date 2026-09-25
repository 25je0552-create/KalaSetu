import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';

class B2bBulkRequestScreen extends StatefulWidget {
  const B2bBulkRequestScreen({super.key});

  @override
  State<B2bBulkRequestScreen> createState() => _B2bBulkRequestScreenState();
}

class _B2bBulkRequestScreenState extends State<B2bBulkRequestScreen> {
  final _companyCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _selectedCraft = 'Gorakhpur Terracotta';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('थोक खरीद • B2B Bulk Request', style: TextStyle(fontFamily: 'Literata', fontSize: 18)),
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
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.handshake_outlined, color: AppColors.primary, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'कॉर्पोरेट उपहार व निर्यात हेतु सीधे ग्रामीण कारीगर क्लस्टर से थोक भाव पर संपर्क करें।',
                      style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.onSurface),
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
                decoration: const InputDecoration(
                  labelText: 'संस्था या कंपनी का नाम (Organization/Buyer)',
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
                value: _selectedCraft,
                decoration: const InputDecoration(border: InputBorder.none, labelText: 'वांछित शिल्प (Craft Category)'),
                items: [
                  'Gorakhpur Terracotta',
                  'Maheshwar Handloom Silk',
                  'Moradabad Brass Art',
                  'Kashmiri Pashmina',
                ].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (val) => setState(() => _selectedCraft = val ?? _selectedCraft),
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
                decoration: const InputDecoration(
                  labelText: 'अनुमानित संख्या (Pieces/Quantity, e.g. 50, 200)',
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
                decoration: const InputDecoration(
                  labelText: 'विशेष आवश्यकताएं या कस्टम लोगो (Custom Requirements)',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 28),
            TerracottaButton(
              label: 'कोटेशन अनुरोध भेजें • Submit Request',
              icon: Icons.send,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('अनुरोध प्राप्त हुआ!'),
                    content: const Text('क्लस्टर समन्वयक 24 घंटे में आपसे सीधे संपर्क करेंगे।'),
                    actions: [
                      TextButton(onPressed: () { Navigator.pop(context); context.pop(); }, child: const Text('ठीक है')),
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
