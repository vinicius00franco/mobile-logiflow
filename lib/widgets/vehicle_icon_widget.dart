import 'package:flutter/material.dart';
import '../constants/app_design.dart';

class VehicleIconWidget extends StatelessWidget {
  final String veiculo;
  final String status;

  const VehicleIconWidget({
    super.key,
    required this.veiculo,
    required this.status,
  });

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

  IconData _getVehicleIcon(String veiculo) {
    if (veiculo.toLowerCase().contains('moto')) {
      return VehicleIcons.moto;
    } else if (veiculo.toLowerCase().contains('van')) {
      return VehicleIcons.van;
    } else if (veiculo.toLowerCase().contains('caminhão')) {
      return VehicleIcons.caminhao;
    }
    return VehicleIcons.carro;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(color: statusColor.withAlpha(40), width: 2),
      ),
      child: Center(
        child: Icon(_getVehicleIcon(veiculo), color: statusColor, size: 30),
      ),
    );
  }
}
