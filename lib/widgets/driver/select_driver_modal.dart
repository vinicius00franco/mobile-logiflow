import 'package:flutter/material.dart';
import '../../models/driver.dart';
import '../../constants/app_design.dart';

/// Modal para selecionar qual motorista seguir quando há múltiplos selecionados
class SelectDriverModal extends StatelessWidget {
  final List<Driver> drivers;
  final Function(Driver) onDriverSelected;

  const SelectDriverModal({
    super.key,
    required this.drivers,
    required this.onDriverSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.large),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do modal
          Row(
            children: [
              Icon(Icons.gps_fixed, color: AppColors.emEntrega, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Selecione o motorista para seguir',
                style: TextStyle(
                  fontSize: AppFontSize.large,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Divider(height: 1),
          SizedBox(height: AppSpacing.sm),

          // Lista de motoristas
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(driver.status),
                  child: Icon(
                    _getVehicleIcon(driver.veiculo),
                    color: AppColors.textLight,
                    size: 20,
                  ),
                ),
                title: Text(
                  driver.nome,
                  style: TextStyle(
                    fontWeight: AppFontWeight.semiBold,
                    fontSize: AppFontSize.medium,
                  ),
                ),
                subtitle: Text(
                  '${driver.veiculo} • ${driver.status}',
                  style: TextStyle(
                    fontSize: AppFontSize.small,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  onDriverSelected(driver);
                },
              );
            },
          ),

          SizedBox(height: AppSpacing.sm),

          // Botão cancelar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.medium),
                ),
              ),
              child: Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Em Entrega':
        return AppColors.emEntrega;
      case 'Disponível':
        return AppColors.disponivel;
      case 'Emergência':
        return AppColors.emergencia;
      default:
        return AppColors.offline;
    }
  }

  IconData _getVehicleIcon(String veiculo) {
    if (veiculo.toLowerCase().contains('moto')) {
      return VehicleIcons.moto;
    } else if (veiculo.toLowerCase().contains('carro')) {
      return VehicleIcons.carro;
    }
    return VehicleIcons.caminhao;
  }
}
