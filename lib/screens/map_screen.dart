import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../stores/driver_store.dart';
import '../constants/map_constants.dart';
import '../widgets/driver/driver_list_widget.dart';
import '../widgets/map_layers_widget.dart';
import '../widgets/driver/driver_progress_bar.dart';
import '../widgets/driver/select_driver_modal.dart';

// Tela do mapa que exibe a localização dos motoristas e permite interação com o mapa
class MapScreen extends StatefulWidget {
  final String? selectedDriverId;

  const MapScreen({super.key, this.selectedDriverId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

// Estado da tela do mapa, gerencia controladores e estado do mapa
class _MapScreenState extends State<MapScreen> {
  // Controlador para o mapa FlutterMap
  final MapController _mapController = MapController();
  // Controlador para a lista de motoristas em formato de página
  final PageController _pageController = PageController(viewportFraction: 0.85);
  // Estilo atual do mapa (ex: OpenStreetMap)
  String _currentMapStyle = 'OpenStreetMap';
  // Índice do motorista atualmente selecionado na lista
  int _currentDriverIndex = 0;
  // Timer para atualizar câmera quando seguindo motorista
  Timer? _followTimer;

  @override
  void initState() {
    super.initState();
    // Iniciar timer para seguir motorista automaticamente
    _followTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      _updateCameraIfFollowing();
    });
  }

  void _updateCameraIfFollowing() {
    final driverStore = Provider.of<DriverStore>(context, listen: false);
    if (driverStore.followingDriverId != null) {
      final driver = driverStore.drivers.firstWhere(
        (d) => d.id == driverStore.followingDriverId,
        orElse: () => driverStore.drivers.first,
      );
      _mapController.move(LatLng(driver.posicao.lat, driver.posicao.lng), 28.0);
    }
  }

  void _handleFollowButtonPress(DriverStore driverStore) {
    final isFollowing = driverStore.followingDriverId != null;

    if (isFollowing) {
      // Se já está seguindo, para de seguir
      driverStore.toggleFollowDriver(null);
      return;
    }

    // Obter motoristas selecionados
    final selectedDrivers = driverStore.driversSelected;

    if (selectedDrivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nenhum motorista selecionado'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (selectedDrivers.length == 1) {
      // Se houver apenas um motorista selecionado, seguir diretamente
      final driver = selectedDrivers.first;
      driverStore.toggleFollowDriver(driver.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Seguindo ${driver.nome}'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Se houver múltiplos motoristas, mostrar modal
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SelectDriverModal(
          drivers: selectedDrivers,
          onDriverSelected: (driver) {
            driverStore.toggleFollowDriver(driver.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Seguindo ${driver.nome}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      );
    }
  }

  // Método para alterar o estilo do mapa ciclicamente
  void _changeMapStyle() {
    final styles = mapStyles.keys.toList();
    final currentIndex = styles.indexOf(_currentMapStyle);
    final nextIndex = (currentIndex + 1) % styles.length;
    setState(() {
      _currentMapStyle = styles[nextIndex];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Estilo do mapa: $_currentMapStyle'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Método build que constrói a interface da tela
  @override
  Widget build(BuildContext context) {
    // Obtém a instância do DriverStore via Provider
    final driverStore = Provider.of<DriverStore>(context);

    // Scaffold principal com appBar transparente e corpo dividido em coluna
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      // Corpo da tela dividido em coluna: mapa expandido e lista de motoristas abaixo
      body: Column(
        children: [
          // Seção do mapa que ocupa o espaço restante
          Expanded(
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Widget RepaintBoundary para otimizar renderização do mapa
                  RepaintBoundary(
                    child: Observer(
                      builder: (_) => FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(
                            driverStore.userLocation?.lat ?? -23.5505,
                            driverStore.userLocation?.lng ?? -46.6333,
                          ),
                          initialZoom: 12.0,
                          minZoom: 5.0,
                          maxZoom: 18.0,
                        ),
                        children: [
                          // Widget personalizado para camadas do mapa e marcadores
                          MapLayersWidget(
                            // Passa apenas os drivers atualmente selecionados
                            drivers: driverStore.driversSelected,
                            mapStyle: _currentMapStyle,
                            onMarkerTap: (driver) {
                              _mapController.move(
                                LatLng(driver.posicao.lat, driver.posicao.lng),
                                14.0,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Controles posicionados no topo direito do mapa
                  Positioned(
                    top: 80,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Indicador do estilo atual do mapa
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentMapStyle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Botão flutuante para alterar o estilo do mapa
                        FloatingActionButton(
                          heroTag: 'mapStyleButton',
                          onPressed: _changeMapStyle,
                          backgroundColor: Colors.white,
                          tooltip: 'Alterar estilo do mapa',
                          child: const Icon(Icons.map, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        // Botão flutuante para seguir motorista
                        Observer(
                          builder: (_) {
                            final isFollowing =
                                driverStore.followingDriverId != null;
                            final hasSelectedDrivers =
                                driverStore.driversSelected.isNotEmpty;

                            return FloatingActionButton(
                              heroTag: 'followDriverButton',
                              onPressed: hasSelectedDrivers
                                  ? () => _handleFollowButtonPress(driverStore)
                                  : null,
                              backgroundColor: isFollowing
                                  ? Colors.blue
                                  : Colors.white,
                              tooltip: isFollowing
                                  ? 'Parar de seguir'
                                  : 'Seguir veículo',
                              child: Icon(
                                isFollowing
                                    ? Icons.gps_fixed
                                    : Icons.gps_not_fixed,
                                color: isFollowing
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Seção inferior com barra de progresso e lista de motoristas, reagindo a mudanças no store
          Observer(
            builder: (_) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Barra de progresso mostrando o motorista atual
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: DriverProgressBar(
                      totalDrivers: driverStore.drivers.length,
                      currentIndex: _currentDriverIndex,
                    ),
                  ),
                  // Lista horizontal de motoristas com PageView
                  DriverListWidget(
                    drivers: driverStore.drivers,
                    selectedDriverIds: driverStore.selectedDriverIds,
                    pageController: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentDriverIndex = index;
                      });
                      final driver = driverStore.drivers[index];
                      _mapController.move(
                        LatLng(driver.posicao.lat, driver.posicao.lng),
                        14.0,
                      );
                    },
                    onDriverTap: (driver) {
                      final index = driverStore.drivers.indexOf(driver);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onSelectionToggle: (driver, selected) {
                      driverStore.toggleDriverSelection(driver.id);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Método dispose para liberar recursos dos controladores
  @override
  void dispose() {
    _followTimer?.cancel();
    _mapController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
