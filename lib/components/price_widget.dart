import 'package:flutter/material.dart';
import '../constants/app_design.dart';

class PriceWidget extends StatelessWidget {
  final double preco;
  final String id;

  const PriceWidget({super.key, required this.preco, required this.id});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppBorderRadius.small),
          ),
          child: Text(
            '${AppCurrency.symbol} ${(preco / 1000).toStringAsFixed(1)}k',
            style: const TextStyle(
              fontSize: AppFontSize.large,
              fontWeight: AppFontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'ID: $id',
          style: TextStyle(
            fontSize: AppFontSize.small,
            color: AppColors.textSecondary.withAlpha(180),
            fontWeight: AppFontWeight.medium,
          ),
        ),
      ],
    );
  }
}
