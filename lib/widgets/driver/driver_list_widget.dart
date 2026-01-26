import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../constants/app_design.dart';
import '../../models/driver.dart' as model;
import '../../stores/driver_store.dart';
import 'card/driver_card_compact.dart';

/// Widget otimizado para exibir lista horizontal de motoristas com PageView
///
/// Otimizações de performance:
/// - PageView com viewportFraction para pre-render de cards adjacentes
/// - Estado de expansão global sincronizado via DriverStore (todos os cards expandem/colapsam juntos)
/// - RepaintBoundary nos cards para isolar rebuilds
/// - Altura reduzida (120px collapsed, até 280px expanded)
class DriverListWidget extends StatefulWidget {
  final List<model.Driver> drivers;
  final Set<String> selectedDriverIds;
  final Function(model.Driver) onDriverTap;
  final Function(int)? onPageChanged;
  final Function(model.Driver, bool)? onSelectionToggle;
  final PageController? pageController;
  final DriverStore driverStore;

  const DriverListWidget({
    super.key,
    required this.drivers,
    required this.selectedDriverIds,
    required this.onDriverTap,
    required this.driverStore,
    this.onPageChanged,
    this.onSelectionToggle,
    this.pageController,
  });

  @override
  State<DriverListWidget> createState() => _DriverListWidgetState();
}

// Estado do widget - não precisa mais gerenciar notifiers individuais
class _DriverListWidgetState extends State<DriverListWidget> {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        // Observa o estado de expansão global do store
        final isExpanded = widget.driverStore.isDriverCardsExpanded;

        // Calcula altura dinâmica baseada no estado global
        const collapsed = 120.0;
        const expanded = 280.0;
        final containerHeight = isExpanded ? expanded : collapsed;

        return Container(
          height: containerHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppBorderRadius.large),
              topRight: Radius.circular(AppBorderRadius.large),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          // Coluna para organizar o espaçamento e o PageView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              // PageView para rolagem horizontal dos cards de motoristas
              Expanded(
                child: PageView.builder(
                  controller: widget.pageController,
                  onPageChanged: widget.onPageChanged,
                  padEnds: false,
                  itemCount: widget.drivers.length,
                  itemBuilder: (context, index) {
                    final driver = widget.drivers[index];
                    final isSelected = widget.selectedDriverIds.contains(
                      driver.id,
                    );

                    // Padding dinâmico: maior nas extremidades para centralizar
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? AppSpacing.md : AppSpacing.xs,
                        right: index == widget.drivers.length - 1
                            ? AppSpacing.md
                            : AppSpacing.xs,
                        bottom: AppSpacing.sm,
                      ),
                      child: DriverCardCompact(
                        driver: driver,
                        isSelected: isSelected,
                        isExpanded: isExpanded,
                        onTap: () => widget.onDriverTap(driver),
                        onSelectionChanged: (selected) =>
                            widget.onSelectionToggle?.call(driver, selected),
                        onExpandToggle: () =>
                            widget.driverStore.toggleDriverCardsExpansion(),
                      ),
                    );
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
