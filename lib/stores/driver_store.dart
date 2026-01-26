import 'dart:async';
import 'package:mobx/mobx.dart';
import '../models/driver.dart';
import '../repository/driver_repository.dart';
import '../services/route_loader_service.dart';
import '../services/address_service.dart';
import '../services/movement_simulator.dart';
import '../services/logger_service.dart';
import '../utils/map_utils.dart';

part 'driver_store.g.dart';

// Ignore linter rule: exposição de tipo privado via MobX class alias
// ignore: library_private_types_in_public_api
class DriverStore = _DriverStore with _$DriverStore;

abstract class _DriverStore with Store {
  final Position? userLocation;
  final DriverRepository _driverRepository;
  final RouteLoaderService _routeLoader;
  final AddressService _addressService;
  final MovementSimulator _movementSimulator;
  final LoggerService _logger;

  late StreamController<String> _controller;

  StreamSubscription<List<DriverMovement>>? _movementSub;

  _DriverStore(
    this.userLocation,
    this._driverRepository,
    this._routeLoader,
    this._addressService,
    this._movementSimulator,
    this._logger,
  ) {
    _controller = StreamController<String>.broadcast();

    // Inicializar motoristas com rotas
    _initializeDrivers();

    // Reaction para emergência
    _emergencyDisposer = reaction(
      (_) => drivers.any((d) => d.status == 'Emergência'),
      (hasEmergency) {
        if (hasEmergency) {
          _onEmergency();
        }
      },
    );

    // Movimento será iniciado após carregamento de rotas em _loadRoutesAndStartSimulation
  }

  @observable
  List<Driver> drivers = [];

  @observable
  ObservableSet<String> selectedDriverIds = ObservableSet<String>();

  @observable
  String? followingDriverId; // ID do motorista sendo seguido

  @observable
  late ObservableStream<List<Driver>> driversStream;

  // Estado global de expansão dos cards de motoristas (sincronizado entre todos)
  @observable
  bool isDriverCardsExpanded = false;

  // Sinalizar emergência para UI
  @observable
  bool hasEmergency = false;

  late ReactionDisposer _emergencyDisposer;

  @computed
  List<Driver> get disponiveisNoRaio => drivers
      .where((d) => d.status == 'Disponível')
      .where(
        (d) =>
            userLocation != null &&
            distanceInKm(userLocation!, d.posicao) <= 5.0,
      )
      .toList(growable: false);

  @computed
  List<Driver> get emEntrega =>
      drivers.where((d) => d.status == 'Em Entrega').toList(growable: false);

  void _onEmergency() {
    hasEmergency = true;
    _logger.log('EMERGENCY', 'Alerta de emergência!');
  }

  void _initializeDrivers() async {
    drivers = DriverRepository.createInitialDrivers();

    // Inicialmente todos os motoristas são selecionados
    selectedDriverIds = ObservableSet<String>.of(drivers.map((d) => d.id));

    // Buscar rotas reais de forma assíncrona e aguardar conclusão
    await _loadRoutesAndStartSimulation();
  }

  Future<void> _loadRoutesAndStartSimulation() async {
    _logger.log('ROUTE_LOADER', '=== Iniciando carregamento de rotas ===');

    // Carregar rotas em paralelo para todos os motoristas em entrega
    final futures = <Future<Driver>>[];
    for (var driver in drivers) {
      if (driver.status == 'Em Entrega') {
        _logger.log('ROUTE_LOADER', 'Carregando rota para ${driver.nome}...');
        futures.add(_routeLoader.loadRouteForDriver(driver));
      }
    }

    // Aguardar todas as rotas carregarem em paralelo
    final loadedDrivers = await Future.wait(futures);

    // Atualizar drivers com rotas carregadas
    final updatedDrivers = List<Driver>.from(drivers);
    for (var loadedDriver in loadedDrivers) {
      final index = updatedDrivers.indexWhere((d) => d.id == loadedDriver.id);
      if (index >= 0) {
        updatedDrivers[index] = loadedDriver;
      }
    }
    drivers = updatedDrivers;

    _logger.log('ROUTE_LOADER', '=== Todas as rotas carregadas ===');

    // Inicializar movimentos após rotas carregadas
    _movementSimulator.initializeMovements(drivers);

    // Subscrever aos movimentos
    _movementSub = _movementSimulator.movements.listen((movements) {
      final updatedDrivers = movements.map((m) => m.driver).toList();
      drivers = updatedDrivers;
    });

    // Iniciar simulação
    _movementSimulator.startSimulation();
  }

  // Retorna apenas os drivers selecionados
  @computed
  List<Driver> get driversSelected => drivers
      .where((d) => selectedDriverIds.contains(d.id))
      .toList(growable: false);

  @action
  void toggleDriverSelection(String id) {
    if (selectedDriverIds.contains(id)) {
      selectedDriverIds.remove(id);
    } else {
      selectedDriverIds.add(id);
    }
  }

  @action
  void toggleFollowDriver(String? driverId) {
    if (followingDriverId == driverId) {
      followingDriverId = null; // Para de seguir
    } else {
      followingDriverId = driverId; // Começa a seguir
    }
  }

  // Alterna o estado de expansão global dos cards de motoristas
  @action
  void toggleDriverCardsExpansion() {
    isDriverCardsExpanded = !isDriverCardsExpanded;
  }

  // Define diretamente o estado de expansão global
  @action
  void setDriverCardsExpanded(bool expanded) {
    isDriverCardsExpanded = expanded;
  }

  void dispose() {
    _movementSub?.cancel();
    _emergencyDisposer();
    _movementSimulator.dispose();
    _controller.close();
  }
}
