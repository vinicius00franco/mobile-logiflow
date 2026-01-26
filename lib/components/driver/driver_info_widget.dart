import 'package:flutter/material.dart';
import '../../constants/app_design.dart';
import '../status_badge_widget.dart';

class DriverInfoWidget extends StatelessWidget {
  final String nome;
  final String veiculo;
  final String status;
  final int tempoEstimado;
  final double distancia;

  const DriverInfoWidget({
    super.key,
    required this.nome,
    required this.veiculo,
    required this.status,
    required this.tempoEstimado,
    required this.distancia,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nome,
                  style: const TextStyle(
                    fontSize: AppFontSize.large,
                    fontWeight: AppFontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              StatusBadgeWidget(status: status),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            veiculo,
            style: TextStyle(
              fontSize: AppFontSize.medium,
              color: AppColors.textSecondary.withAlpha(200),
              fontWeight: AppFontWeight.medium,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildMetric(Icons.access_time_rounded, '$tempoEstimado min'),
              const SizedBox(width: AppSpacing.md),
              _buildMetric(
                Icons.route_outlined,
                '${distancia.toStringAsFixed(1)} km',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: const TextStyle(
            fontSize: AppFontSize.small,
            color: AppColors.textSecondary,
            fontWeight: AppFontWeight.medium,
          ),
        ),
      ],
    );
  }
}
