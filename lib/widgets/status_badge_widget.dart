import 'package:flutter/material.dart';
import '../constants/app_design.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String status;

  const StatusBadgeWidget({super.key, required this.status});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disponível':
        return AppColors.disponivel;
      case 'Em Entrega':
        return AppColors.emEntrega;
      case 'Offline':
        return AppColors.offline;
      case 'Emergência':
        return AppColors.emergencia;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: AppFontSize.small,
          fontWeight: AppFontWeight.medium,
        ),
      ),
    );
  }
}
