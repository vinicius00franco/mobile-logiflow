import 'package:flutter/material.dart';
import '../../../constants/app_design.dart';
import '../../../models/driver.dart';
import '../../../utils/map_utils.dart';

/// Cabeçalho do card do motorista: checkbox de seleção, indicador de status,
/// nome, veículo, preço e ícone de expansão.
class DriverCardHeader extends StatelessWidget {
  final Driver driver;
  final bool isSelected;
  final bool isExpanded;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback onExpandToggle;

  const DriverCardHeader({
    super.key,
    required this.driver,
    required this.isSelected,
    required this.isExpanded,
    this.onSelectionChanged,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onSelectionChanged?.call(!isSelected),
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              child: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18,
                color: isSelected
                    ? getStatusColor(driver.status)
                    : AppColors.textSecondary,
              ),
            ),
          ),

          // Indicador de status
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: getStatusColor(driver.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Nome, veículo e preço
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        driver.nome,
                        style: const TextStyle(
                          fontSize: AppFontSize.medium,
                          fontWeight: AppFontWeight.semiBold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'R\$ ${driver.preco.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: AppFontSize.small,
                        fontWeight: AppFontWeight.semiBold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Text(
                  driver.veiculo,
                  style: const TextStyle(
                    fontSize: AppFontSize.small,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Ícone de expansão
          GestureDetector(
            onTap: onExpandToggle,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
