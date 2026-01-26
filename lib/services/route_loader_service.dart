import '../models/driver.dart';
import '../services/routing_service.dart';
import '../services/logger_service.dart';

class RouteLoaderService {
  final LoggerService _logger;

  RouteLoaderService(this._logger);

  Future<Driver> loadRouteForDriver(Driver driver) async {
    final rota = await RoutingService.getRoute(driver.origem, driver.destino);
    final distanciaReal = RoutingService.calculateRouteDistance(rota);

    final status = rota.length > 2 ? '✓ OSRM' : '⚠ Fallback';
    _logger.log(
      'ROUTE_LOADER',
      '$status ${driver.nome}: ${rota.length} pontos, ${distanciaReal.toStringAsFixed(2)} km',
    );

    return driver.copyWith(
      rota: rota,
      distancia: distanciaReal,
      tempoEstimado: (distanciaReal * 3).round(),
    );
  }
}
