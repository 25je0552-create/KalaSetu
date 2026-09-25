import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/clay_widgets.dart';

class ArtisanEarningsScreen extends ConsumerWidget {
  const ArtisanEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isHindi = locale == AppLocale.hindi;
    debugPrint('[ArtisanEarningsScreen] Rendered. Available balance: ₹8,720, isHindi: $isHindi');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          ref.tr('earnings_title'),
          style: const TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, fontSize: 19),
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
                  Text(
                    ref.tr('available_balance'),
                    style: const TextStyle(fontSize: 13, color: AppColors.primaryFixed),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹8,720',
                    style: const TextStyle(
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
                      Text(
                        ref.tr('bank_account'),
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryFixedDim),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          ref.tr('wednesday_payout'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              ref.tr('weekly_history'),
              style: const TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Weekly history cards
            _buildWeekRow(
              ref.tr('week_current'),
              '₹6,450',
              '9 ${ref.tr("orders_count_label")}',
              true,
            ),
            _buildWeekRow(
              '${ref.tr("week_prev")} 7',
              '₹6,850',
              '11 ${ref.tr("orders_count_label")}',
              false,
            ),
            _buildWeekRow(
              '${ref.tr("week_prev")} 6',
              '₹5,600',
              '8 ${ref.tr("orders_count_label")}',
              false,
            ),
            _buildWeekRow(
              '${ref.tr("week_prev")} 5',
              '₹3,900',
              '5 ${ref.tr("orders_count_label")}',
              false,
            ),
            _buildWeekRow(
              '${ref.tr("week_prev")} 4',
              '₹6,400',
              '9 ${ref.tr("orders_count_label")}',
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekRow(String week, String amount, String orders, bool isCurrent) {
    return InkWell(
      onTap: () => debugPrint('[ArtisanEarningsScreen] Weekly summary tapped: week=$week, amount=$amount, orders=$orders'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
    ),);
  }
}
