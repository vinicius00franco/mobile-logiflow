import 'package:flutter/material.dart';
import '../../constants/app_design.dart';

/// Widget de barra de progresso para indicar navegação entre motoristas
///
/// Otimizações de performance:
/// - Usa const constructor sempre que possível
/// - AnimatedContainer para transições suaves sem rebuilds excessivos
class DriverProgressBar extends StatelessWidget {
  final int totalDrivers;
  final int currentIndex;

  const DriverProgressBar({
    super.key,
    required this.totalDrivers,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalDrivers, (index) {
          final isActive = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: isActive ? 30 : 12,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.progressActive
                  : AppColors.progressInactive,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}
