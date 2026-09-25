import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';

class ArtisanEarningsScreen extends ConsumerWidget {
  const ArtisanEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'कमाई व भुगतान • Earnings',
          style: TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, fontSize: 19),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LanguageTogglePill(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x209D3E14), blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'कुल प्राप्य राशि (Available Balance)',
                    style: TextStyle(fontSize: 13, color: AppColors.primaryFixed),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '₹८,७२०',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'बैंक खाता: SBI •••• 4892',
                        style: TextStyle(fontSize: 12, color: AppColors.primaryFixedDim),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'प्रत्येक बुधवार भुगतान',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'साप्ताहिक कमाई का इतिहास (Weekly History)',
              style: TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Weekly history cards
            _buildWeekRow('सप्ताह ८ (वर्तमान)', '₹६,४५०', '९ ऑर्डर', true),
            _buildWeekRow('सप्ताह ७', '₹६,८५०', '११ ऑर्डर', false),
            _buildWeekRow('सप्ताह ६', '₹५,६००', '८ ऑर्डर', false),
            _buildWeekRow('सप्ताह ५', '₹३,९००', '५ ऑर्डर', false),
            _buildWeekRow('सप्ताह ४', '₹६,४००', '९ ऑर्डर', false),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekRow(String week, String amount, String orders, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.surfaceContainerLow : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(week, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(orders, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
