import 'dart:async';
import 'dart:math';
import '../models/driver.dart';
import '../services/route_loader_service.dart';
import '../services/address_service.dart';
import '../services/logger_service.dart';
import '../services/routing_service.dart';
import '../utils/map_utils.dart';

class DriverMovement {
  final Driver driver;
  final double progressoRota; // 0.0 a 1.0
  DriverMovement(this.driver, this.progressoRota);
}

class MovementSimulator {
  final RouteLoaderService _routeLoader;
  final AddressService _addressService;
  final LoggerService _logger;
  final StreamController<List<DriverMovement>> _controller =
      StreamController<List<DriverMovement>>.broadcast();
  final Map<String, DriverMovement> _driverMovements = {};
  final Map<String, DateTime> _lastAddressUpdate = {};
  static const _addressUpdateInterval = Duration(seconds: 10);
  Timer? _movementTimer;

  Stream<List<DriverMovement>> get movements => _controller.stream;

  MovementSimulator(this._routeLoader, this._addressService, this._logger);

  void initializeMovements(List<Driver> drivers) {
    for (var driver in drivers) {
      _driverMovements[driver.id] = DriverMovement(driver, 0.0);
    }
    _emitCurrentMovements();
  }

  void startSimulation() {
    _movementTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final updatedMovements = <DriverMovement>[];

      for (var entry in _driverMovements.entries) {
        final driver = entry.value.driver;
        if (driver.status == 'Em Entrega') {
          var newProgress =
              entry.value.progressoRota + 0.02; // 2% a cada segundo

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
            updatedMovements.add(_driverMovements[driver.id]!);

            // Buscar rota real de forma assíncrona
            _routeLoader
                .loadRouteForDriver(updatedDriver)
                .then((loadedDriver) {
                  _driverMovements[driver.id] = DriverMovement(
                    loadedDriver,
                    0.0,
                  );
                  _emitCurrentMovements();
                })
                .catchError((e) {
                  _logger.log(
                    'ROUTE_LOADER',
                    'Erro ao buscar nova rota para ${driver.nome}: $e',
                  );
                });
          } else {
            // Calcular nova posição seguindo a rota
            final Position newPosicao;
            if (driver.rota.length > 1) {
              newPosicao = RoutingService.getPointOnRoute(
                driver.rota,
                newProgress,
              );
            } else {
              newPosicao = interpolatePosition(
                driver.origem,
                driver.destino,
                newProgress,
              );
            }

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
            updatedMovements.add(_driverMovements[driver.id]!);

            // Atualizar endereço da posição com debounce (a cada 10 segundos)
            final lastUpdate = _lastAddressUpdate[driver.id];
            final now = DateTime.now();
            if (lastUpdate == null ||
                now.difference(lastUpdate) >= _addressUpdateInterval) {
              _lastAddressUpdate[driver.id] = now;
              _addressService.updateDriverPositionAddress(updatedDriver).then((
                updated,
              ) {
                _driverMovements[driver.id] = DriverMovement(
                  updated,
                  newProgress,
                );
                _emitCurrentMovements();
              });
            }
          }
        } else {
          updatedMovements.add(entry.value);
        }
      }

      _emitCurrentMovements();
    });
  }

  void _emitCurrentMovements() {
    _controller.add(_driverMovements.values.toList());
  }

  void dispose() {
    _movementTimer?.cancel();
    _controller.close();
  }
}
