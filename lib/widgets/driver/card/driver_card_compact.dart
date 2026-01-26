import 'package:flutter/material.dart';
import '../../../constants/app_design.dart';
import '../../../models/driver.dart';
import '../../../utils/map_utils.dart';
import 'driver_card_header.dart';
import 'driver_card_metrics.dart';
import '../driver_info_section.dart';
import '../../address_history_widget.dart';

/// Widget otimizado para exibir informações compactas do motorista
/// com expansão para detalhes adicionais sincronizada globalmente.
class DriverCardCompact extends StatelessWidget {
  final Driver driver;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback onTap;

  const DriverCardCompact({
    super.key,
    required this.driver,
    required this.isSelected,
    required this.isExpanded,
    required this.onExpandToggle,
    this.onSelectionChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? getStatusColor(driver.status).withAlpha(25)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
              border: Border.all(
                color: isSelected
                    ? getStatusColor(driver.status)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: double.infinity,
                      maxHeight: isExpanded ? 280.0 : 64.0,
                    ),
                    child: SingleChildScrollView(
                      physics: isExpanded
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DriverCardHeader(
                            driver: driver,
                            isSelected: isSelected,
                            isExpanded: isExpanded,
                            onSelectionChanged: onSelectionChanged,
                            onExpandToggle: onExpandToggle,
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.sm,
                                0,
                                AppSpacing.sm,
                                0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // const SizedBox(height: AppSpacing.xs),
                                  DriverCardMetrics(
                                    distancia:
                                        '${driver.distancia.toStringAsFixed(1)} km',
                                    tempo: '${driver.tempoEstimado} min',
                                  ),
                                  // const Divider(height: 1),
                                  const SizedBox(height: AppSpacing.sm),
                                  DriverInfoSection(
                                    icon: Icons.location_on,
                                    title: 'Posição Atual',
                                    subtitle:
                                        driver.posicaoEndereco ??
                                        _formatCoordinates(driver.posicao),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  DriverInfoSection(
                                    icon: Icons.trip_origin,
                                    title: 'Origem',
                                    subtitle:
                                        driver.origemEndereco ??
                                        _formatCoordinates(driver.origem),
                                    color: AppColors.disponivel,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  DriverInfoSection(
                                    icon: Icons.place,
                                    title: 'Destino',
                                    subtitle:
                                        driver.destinoEndereco ??
                                        _formatCoordinates(driver.destino),
                                    color: AppColors.emergencia,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  // Botão para ver histórico de endereços
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _showAddressHistory(context),
                                      icon: const Icon(Icons.history, size: 16),
                                      label: Text(
                                        'Ver Histórico (${driver.historicoEnderecos.length})',
                                        style: const TextStyle(
                                          fontSize: AppFontSize.small,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.xs,
                                        ),
                                        side: BorderSide(
                                          color: AppColors.textSecondary
                                              .withAlpha(100),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCoordinates(Position position) {
    return 'Lat: ${position.lat.toStringAsFixed(6)}, Lng: ${position.lng.toStringAsFixed(6)}';
  }

  void _showAddressHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.large),
        ),
      ),
      builder: (context) => AddressHistoryWidget(driverId: driver.id),
    );
  }
}
