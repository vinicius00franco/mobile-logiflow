import 'package:flutter/material.dart';
import '../../constants/app_design.dart';
import '../../models/driver.dart' as model;
import 'card/driver_card_compact.dart';

/// Widget otimizado para exibir lista horizontal de motoristas com PageView
///
/// Otimizações de performance:
/// - PageView com viewportFraction para pre-render de cards adjacentes
/// - ValueNotifier para estado de expansão individual de cada card
/// - RepaintBoundary nos cards para isolar rebuilds
/// - Altura reduzida (120px collapsed, até 280px expanded)
class DriverListWidget extends StatefulWidget {
  final List<model.Driver> drivers;
  final Set<String> selectedDriverIds;
  final Function(model.Driver) onDriverTap;
  final Function(int)? onPageChanged;
  final Function(model.Driver, bool)? onSelectionToggle;
  final PageController? pageController;

  const DriverListWidget({
    super.key,
    required this.drivers,
    required this.selectedDriverIds,
    required this.onDriverTap,
    this.onPageChanged,
    this.onSelectionToggle,
    this.pageController,
  });

  @override
  State<DriverListWidget> createState() => _DriverListWidgetState();
}

// Estado do widget, gerencia notifiers para expansão dos cards
class _DriverListWidgetState extends State<DriverListWidget> {
  // Lista de ValueNotifier para controlar expansão individual de cada card
  // Inicializa vazia para podermos reutilizá-la e evitar checagens com "late"
  List<ValueNotifier<bool>> _expansionNotifiers = [];

  // Inicializa os notifiers quando o widget é criado
  @override
  void initState() {
    super.initState();
    _initializeExpansionNotifiers();
  }

  // Atualiza os notifiers se a lista de motoristas mudou
  @override
  void didUpdateWidget(DriverListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drivers.length != widget.drivers.length) {
      _initializeExpansionNotifiers();
    }
  }

  // Cria uma lista de ValueNotifier para cada motorista, inicializados como false
  void _initializeExpansionNotifiers() {
    // Se já existirem notifiers, descarte-os para evitar vazamentos
    for (var n in _expansionNotifiers) {
      n.dispose();
    }

    // Cria notifiers e adiciona listener para reconstruir a lista quando
    // qualquer card muda seu estado de expansão
    _expansionNotifiers = List.generate(widget.drivers.length, (index) {
      final notifier = ValueNotifier<bool>(false);
      notifier.addListener(() {
        if (mounted) setState(() {});
      });
      return notifier;
    });
  }

  // Libera os recursos dos notifiers ao destruir o widget
  @override
  void dispose() {
    for (var notifier in _expansionNotifiers) {
      notifier.dispose();
    }
    super.dispose();
  }

  // Constrói a interface do widget: container com sombra e PageView
  @override
  Widget build(BuildContext context) {
    // Calcula altura dinâmica: se algum card estiver expandido, usa altura maior
    double containerHeight() {
      const collapsed = 120.0; // altura dos cards colapsados
      const expanded = 280.0; // altura quando um card estiver expandido
      return _expansionNotifiers.any((n) => n.value) ? expanded : collapsed;
    }

    return Container(
      height: containerHeight(),
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
              onPageChanged: (index) {
                // Fecha outros cards ao mudar de página
                for (int i = 0; i < _expansionNotifiers.length; i++) {
                  if (i != index && _expansionNotifiers[i].value) {
                    _expansionNotifiers[i].value = false;
                  }
                }
                widget.onPageChanged?.call(index);
              },
              padEnds: false,
              itemCount: widget.drivers.length,
              itemBuilder: (context, index) {
                final driver = widget.drivers[index];
                final isSelected = widget.selectedDriverIds.contains(driver.id);

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
                    expansionNotifier: _expansionNotifiers[index],
                    onTap: () => widget.onDriverTap(driver),
                    onSelectionChanged: (selected) =>
                        widget.onSelectionToggle?.call(driver, selected),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
