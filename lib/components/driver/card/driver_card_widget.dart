import 'package:flutter/material.dart';
import '../../../models/driver.dart' as model;
import '../../../constants/app_design.dart';
import '../../vehicle_icon_widget.dart';
import '../driver_info_widget.dart';
import '../../price_widget.dart';

class DriverCardWidget extends StatelessWidget {
  final model.Driver driver;
  final VoidCallback? onTap;

  const DriverCardWidget({super.key, required this.driver, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppBorderRadius.large),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow15,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppBorderRadius.large),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                VehicleIconWidget(
                  veiculo: driver.veiculo,
                  status: driver.status,
                ),
                const SizedBox(width: AppSpacing.md),
                DriverInfoWidget(
                  nome: driver.nome,
                  veiculo: driver.veiculo,
                  status: driver.status,
                  tempoEstimado: driver.tempoEstimado,
                  distancia: driver.distancia,
                ),
                const SizedBox(width: AppSpacing.sm),
                PriceWidget(preco: driver.preco, id: driver.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
