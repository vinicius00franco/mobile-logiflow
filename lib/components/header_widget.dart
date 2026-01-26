import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../stores/driver_store.dart';
import '../constants/app_design.dart';

class HeaderWidget extends StatelessWidget {
  final DriverStore store;

  const HeaderWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    // Constrói o cabeçalho principal com fundo arredondado e conteúdo em coluna
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppBorderRadius.large),
          bottomRight: Radius.circular(AppBorderRadius.large),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Constrói a linha superior com nome do app, status da frota e ícone de notificações
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         const Text(
          //           AppTexts.appName,
          //           style: TextStyle(
          //             color: AppColors.accent,
          //             fontSize: AppFontSize.xxlarge,
          //             fontWeight: AppFontWeight.bold,
          //             letterSpacing: -1.0,
          //           ),
          //         ),
          //         const SizedBox(height: AppSpacing.xs),
          //         Text(
          //           AppTexts.fleetStatus,
          //           style: TextStyle(
          //             color: AppColors.textLight.withAlpha(200),
          //             fontSize: AppFontSize.medium,
          //           ),
          //         ),
          //       ],
          //     ),
          //     Container(
          //       padding: const EdgeInsets.all(AppSpacing.sm),
          //       decoration: BoxDecoration(
          //         color: AppColors.textLight.withAlpha(30),
          //         borderRadius: BorderRadius.circular(AppBorderRadius.medium),
          //       ),
          //       child: const Icon(
          //         Icons.notifications_none_rounded,
          //         color: AppColors.textLight,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: AppSpacing.xl),
          // Constrói a linha de estatísticas observáveis da frota (Total, Em Rota, Livres)
          Observer(
            builder: (_) {
              final total = store.drivers.length;
              final emEntrega = store.emEntrega.length;
              final disponiveis = store.drivers.length - emEntrega;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total',
                    total.toString(),
                    Icons.local_shipping,
                  ),
                  _buildStatItem('Em Rota', emEntrega.toString(), Icons.route),
                  _buildStatItem(
                    'Livres',
                    disponiveis.toString(),
                    Icons.check_circle_outline,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Constrói um item de estatística com ícone circular, valor e rótulo
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.textLight.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.textLight, size: 24),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: AppFontSize.large,
            fontWeight: AppFontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textLight.withAlpha(180),
            fontSize: AppFontSize.small,
          ),
        ),
      ],
    );
  }
}
