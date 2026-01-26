import 'dart:async';
import 'dart:math';
import 'package:mobx/mobx.dart';
import '../models/driver.dart';
import '../services/routing_service.dart';
import '../services/geocoding_service.dart';
import '../services/logger_service.dart';

part 'driver_store.g.dart';

class DriverStore = _DriverStore with _$DriverStore;

// Classe auxiliar para rastrear deslocamento
class DriverMovement {
  final Driver driver;
  final double progressoRota; // 0.0 a 1.0
  DriverMovement(this.driver, this.progressoRota);
}

abstract class _DriverStore with Store {
  final Position? userLocation;
  late StreamController<String> _controller;
  final Map<String, DriverMovement> _driverMovements = {};
  // Controle de debounce para atualização de endereços (evita muitas requisições)
  final Map<String, DateTime> _lastAddressUpdate = {};
  static const _addressUpdateInterval = Duration(seconds: 10);
  Timer? _movementTimer;

  _DriverStore(this.userLocation) {
    _controller = StreamController<String>.broadcast();

    // Inicializar motoristas com rotas
    _initializeDrivers();

    // Reaction para emergência
    _emergencyDisposer = reaction(
      (_) => drivers.any((d) => d.status == 'Emergência'),
      (hasEmergency) {
        if (hasEmergency) {
          alertaEmergencia();
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

  StreamSubscription<List<Driver>>? _streamSub;
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

  void alertaEmergencia() {
    // Disparar som, snackbar, dialog, etc.
    LoggerService().log('EMERGENCY', 'Alerta de emergência!');
  }

  void _initializeDrivers() async {
    // Localizações reais de São Paulo
    final origens = [
      Position(-23.5505, -46.6333), // Centro
      Position(-23.5629, -46.6544), // Av Paulista
      Position(-23.5475, -46.6361), // República
      Position(-23.5475, -46.7355), // Pinheiros
    ];

    final destinos = [
      Position(-23.5880, -46.6592), // Vila Mariana
      Position(-23.5328, -46.6394), // Santana
      Position(-23.5740, -46.6826), // Jardins
      Position(-23.6132, -46.6987), // Brooklin
    ];

    final nomes = ['João Silva', 'Maria Santos', 'Pedro Costa', 'Ana Oliveira'];
    final veiculos = ['Moto', 'Carro', 'Moto +', 'Carro +'];
    final precos = [4000.0, 24000.0, 6000.0, 35000.0];

    // Criar drivers temporários sem rotas
    final tempDrivers = <Driver>[];
    for (int i = 0; i < 4; i++) {
      final origem = origens[i];
      final destino = destinos[i];
      final distancia = distanceInKm(origem, destino);
      final tempoEstimado = (distancia * 3).round();

      tempDrivers.add(
        Driver(
          id: '${i + 1}',
          nome: nomes[i],
          posicao: origem,
          origem: origem,
          destino: destino,
          status: i == 3 ? 'Disponível' : 'Em Entrega',
          veiculo: veiculos[i],
          preco: precos[i],
          distancia: distancia,
          tempoEstimado: tempoEstimado,
          rota: [origem, destino],
        ),
      );
    }

    drivers = tempDrivers;

    // Inicialmente todos os motoristas são selecionados
    selectedDriverIds = ObservableSet<String>.of(drivers.map((d) => d.id));

    // Buscar rotas reais de forma assíncrona e aguardar conclusão
    _loadRoutesAndStartSimulation();
  }

  /// Carrega todas as rotas e depois inicia simulação de movimento
  Future<void> _loadRoutesAndStartSimulation() async {
    LoggerService().log(
      'ROUTE_LOADER',
      '=== Iniciando carregamento de rotas ===',
    );

    // Carregar rotas em paralelo para todos os motoristas em entrega
    final futures = <Future<void>>[];
    for (int i = 0; i < drivers.length; i++) {
      if (drivers[i].status == 'Em Entrega') {
        LoggerService().log(
          'ROUTE_LOADER',
          'Carregando rota para ${drivers[i].nome}...',
        );
        futures.add(_fetchRouteForDriver(i));
      }
    }

    // Aguardar todas as rotas carregarem em paralelo
    await Future.wait(futures);

    LoggerService().log('ROUTE_LOADER', '=== Todas as rotas carregadas ===');

    // Inicializar movimentos após rotas carregadas
    for (var driver in drivers) {
      _driverMovements[driver.id] = DriverMovement(driver, 0.0);
    }

    // Iniciar simulação
    _startMovementSimulation();
  }

  Future<void> _resolveAddressesForDriver(Driver driver) async {
    try {
      final geo = GeocodingService();
      final posAddr = await geo.getAddressFromCoordinates(
        driver.posicao.lat,
        driver.posicao.lng,
      );
      final origAddr = await geo.getAddressFromCoordinates(
        driver.origem.lat,
        driver.origem.lng,
      );
      final destAddr = await geo.getAddressFromCoordinates(
        driver.destino.lat,
        driver.destino.lng,
      );

      final updatedDriver = driver.copyWith(
        posicaoEndereco: posAddr,
        origemEndereco: origAddr,
        destinoEndereco: destAddr,
      );

      final index = drivers.indexWhere((d) => d.id == driver.id);
      if (index >= 0) {
        final updated = List<Driver>.from(drivers);
        updated[index] = updatedDriver;
        drivers = updated;

        // Atualiza também o rastreamento de movimento
        _driverMovements[driver.id] = DriverMovement(updatedDriver, 0.0);
      }
    } catch (e) {
      // Falha silenciosa: GeocodingService já possui fallback para coordenadas
    }
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

  Future<void> _fetchRouteForDriver(int index) async {
    final driver = drivers[index];
    final rota = await RoutingService.getRoute(driver.origem, driver.destino);
    final distanciaReal = RoutingService.calculateRouteDistance(rota);

    final status = rota.length > 2 ? '✓ OSRM' : '⚠ Fallback';
    LoggerService().log(
      'ROUTE_LOADER',
      '$status ${driver.nome}: ${rota.length} pontos, ${distanciaReal.toStringAsFixed(2)} km',
    );

    final updatedDriver = driver.copyWith(
      rota: rota,
      distancia: distanciaReal,
      tempoEstimado: (distanciaReal * 3).round(),
    );

    final updatedDrivers = List<Driver>.from(drivers);
    updatedDrivers[index] = updatedDriver;
    drivers = updatedDrivers;

    _driverMovements[driver.id] = DriverMovement(updatedDriver, 0.0);
  }

  void _startMovementSimulation() {
    _movementTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final updatedDrivers = <Driver>[];

      for (var driver in drivers) {
        if (driver.status == 'Em Entrega') {
          // Verificação de segurança: garantir que o movimento existe
          final movement = _driverMovements[driver.id];
          if (movement == null) {
            // Se não existe, inicializar e pular esta iteração
            _driverMovements[driver.id] = DriverMovement(driver, 0.0);
            updatedDrivers.add(driver);
            continue;
          }

          var newProgress = movement.progressoRota + 0.02; // 2% a cada segundo

          if (newProgress >= 1.0) {
            // Chegou ao destino, criar nova rota
            newProgress = 0.0;
            final random = Random();
            final newOrigem = driver.destino;
            final newDestino = Position(
              -23.5505 + (random.nextDouble() - 0.5) * 0.2,
              -46.6333 + (random.nextDouble() - 0.5) * 0.2,
            );
            final distancia = distanceInKm(newOrigem, newDestino);

            final updatedDriver = driver.copyWith(
              origem: newOrigem,
              destino: newDestino,
              posicao: newOrigem,
              distancia: distancia,
              tempoEstimado: (distancia * 3).round(),
              rota: [newOrigem, newDestino], // Rota temporária
            );

            _driverMovements[driver.id] = DriverMovement(updatedDriver, 0.0);
            updatedDrivers.add(updatedDriver);

            // Atualizar endereços para a nova origem/destino
            _resolveAddressesForDriver(updatedDriver);

            // Buscar rota real de forma assíncrona (não bloqueia o timer)
            final driverIndex = drivers.indexOf(driver);
            if (driverIndex >= 0) {
              _fetchRouteForDriver(driverIndex).catchError((e) {
                LoggerService().log(
                  'ROUTE_LOADER',
                  'Erro ao buscar nova rota para ${driver.nome}: $e',
                );
              });
            }
          } else {
            // Calcular nova posição seguindo a rota
            final Position newPosicao;
            if (driver.rota.length > 1) {
              // Usar rota real do OSRM
              newPosicao = RoutingService.getPointOnRoute(
                driver.rota,
                newProgress,
              );
            } else {
              // Fallback para interpolação linear se não tiver rota
              newPosicao = _interpolatePosition(
                driver.origem,
                driver.destino,
                newProgress,
              );
            }

            // Calcular distância restante e tempo estimado
            final remainingDistancia = driver.distancia * (1 - newProgress);
            final updatedTempoEstimado = (remainingDistancia * 3).round();

            final updatedDriver = driver.copyWith(
              posicao: newPosicao,
              distancia: remainingDistancia,
              tempoEstimado: updatedTempoEstimado,
            );
            _driverMovements[driver.id] = DriverMovement(
              updatedDriver,
              newProgress,
            );
            updatedDrivers.add(updatedDriver);

            // Atualizar endereço da posição com debounce (a cada 10 segundos)
            final lastUpdate = _lastAddressUpdate[driver.id];
            final now = DateTime.now();
            if (lastUpdate == null ||
                now.difference(lastUpdate) >= _addressUpdateInterval) {
              _lastAddressUpdate[driver.id] = now;
              _updateDriverPositionAddress(updatedDriver);
            }
          }
        } else {
          // Motorista não está em movimento
          updatedDrivers.add(driver);
        }
      }

      drivers = updatedDrivers;
    });
  }

  Position _interpolatePosition(
    Position origem,
    Position destino,
    double progress,
  ) {
    final lat = origem.lat + (destino.lat - origem.lat) * progress;
    final lng = origem.lng + (destino.lng - origem.lng) * progress;
    return Position(lat, lng);
  }

  double distanceInKm(Position a, Position b) {
    // Fórmula de Haversine simples para distância
    const double earthRadius = 6371; // km
    double dLat = (b.lat - a.lat) * pi / 180;
    double dLng = (b.lng - a.lng) * pi / 180;
    double lat1 = a.lat * pi / 180;
    double lat2 = b.lat * pi / 180;

    double aCalc =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLng / 2) * sin(dLng / 2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(aCalc), sqrt(1 - aCalc));
    return earthRadius * c;
  }

  /// Atualiza o endere\u00e7o da posi\u00e7\u00e3o atual e adiciona ao hist\u00f3rico
  Future<void> _updateDriverPositionAddress(Driver driver) async {
    try {
      final geo = GeocodingService();
      final address = await geo.getAddressFromCoordinates(
        driver.posicao.lat,
        driver.posicao.lng,
      );

      // Adicionar ao hist\u00f3rico apenas se for um endere\u00e7o v\u00e1lido (n\u00e3o coordenadas)
      final newHistory = List<AddressHistoryEntry>.from(
        driver.historicoEnderecos,
      );
      if (!address.startsWith('Lat:')) {
        newHistory.add(
          AddressHistoryEntry(
            position: driver.posicao,
            address: address,
            timestamp: DateTime.now(),
          ),
        );
        // Manter apenas os \u00faltimos 50 endere\u00e7os para evitar crescimento excessivo
        if (newHistory.length > 50) {
          newHistory.removeAt(0);
        }
      }

      final updatedDriver = driver.copyWith(
        posicaoEndereco: address,
        historicoEnderecos: newHistory,
      );

      final index = drivers.indexWhere((d) => d.id == driver.id);
      if (index >= 0) {
        final updated = List<Driver>.from(drivers);
        updated[index] = updatedDriver;
        drivers = updated;

        _driverMovements[driver.id] = DriverMovement(
          updatedDriver,
          _driverMovements[driver.id]?.progressoRota ?? 0.0,
        );
      }
    } catch (e) {
      // Falha silenciosa
    }
  }

  void dispose() {
    _streamSub?.cancel();
    _emergencyDisposer();
    _movementTimer?.cancel();
    _controller.close();
  }
}
