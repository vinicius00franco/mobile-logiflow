import 'package:flutter/material.dart';
import '../../../constants/app_design.dart';

/// Linha de métricas usada no card: distância e tempo
class DriverCardMetrics extends StatelessWidget {
  final String distancia;
  final String tempo;

  const DriverCardMetrics({
    super.key,
    required this.distancia,
    required this.tempo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Metric(label: 'Distância', value: distancia),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Metric(label: 'Tempo', value: tempo),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppFontSize.small,
            fontWeight: AppFontWeight.semiBold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
