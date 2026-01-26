import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import '../constants/app_design.dart';
import '../models/driver.dart';
import '../stores/driver_store.dart';

/// Widget para exibir o histórico de endereços percorridos pelo motorista
/// Atualiza automaticamente quando novos endereços são adicionados
class AddressHistoryWidget extends StatelessWidget {
  final String driverId;

  const AddressHistoryWidget({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    final store = Provider.of<DriverStore>(context, listen: false);

    return Observer(
      builder: (context) {
        // Busca o driver atualizado do store a cada rebuild
        final driver = store.drivers.firstWhere(
          (d) => d.id == driverId,
          orElse: () => store.drivers.first,
        );
        final history = driver.historicoEnderecos;

        if (history.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Nenhum histórico de endereços disponível',
                style: TextStyle(
                  fontSize: AppFontSize.medium,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        return Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Histórico de Endereços',
                      style: TextStyle(
                        fontSize: AppFontSize.large,
                        fontWeight: AppFontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${history.length} locais',
                      style: TextStyle(
                        fontSize: AppFontSize.small,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: history.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    // Mostrar em ordem reversa (mais recente primeiro)
                    final entry = history[history.length - 1 - index];
                    return _HistoryEntryCard(entry: entry, index: index);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Card individual de entrada do histórico
class _HistoryEntryCard extends StatelessWidget {
  final AddressHistoryEntry entry;
  final int index;

  const _HistoryEntryCard({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: index == 0
            ? AppColors.disponivel.withAlpha(25)
            : AppColors.background,
        borderRadius: BorderRadius.circular(AppBorderRadius.small),
        border: Border.all(
          color: index == 0
              ? AppColors.disponivel.withAlpha(100)
              : AppColors.textSecondary.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                index == 0 ? Icons.location_on : Icons.location_on_outlined,
                size: 16,
                color: index == 0
                    ? AppColors.disponivel
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  entry.address,
                  style: TextStyle(
                    fontSize: AppFontSize.small,
                    fontWeight: index == 0
                        ? AppFontWeight.medium
                        : AppFontWeight.regular,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.schedule, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _formatTimestamp(entry.timestamp),
                style: TextStyle(
                  fontSize: AppFontSize.small,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.pin_drop, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Lat: ${entry.position.lat.toStringAsFixed(6)}, Lng: ${entry.position.lng.toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: AppFontSize.small,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'agora';
    } else if (diff.inMinutes < 60) {
      return 'há ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'há ${diff.inHours} h';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
