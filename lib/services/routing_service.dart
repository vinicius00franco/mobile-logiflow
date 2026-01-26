import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/driver.dart';
import 'logger_service.dart';

class RoutingService {
  // API do OSRM (Open Source Routing Machine) - gratuita
  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/driving';
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 10);

  /// Busca a rota real entre origem e destino usando OSRM com retry
  static Future<List<Position>> getRoute(
    Position origem,
    Position destino, {
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/${origem.lng},${origem.lat};${destino.lng},${destino.lat}?geometries=geojson&overview=full',
      );

      LoggerService().log(
        'ROUTING',
        'Buscando rota OSRM: ${origem.lat},${origem.lng} -> ${destino.lat},${destino.lng}',
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          if (coordinates.isEmpty) {
            throw Exception('OSRM retornou rota vazia');
          }

          // Converter coordenadas [lng, lat] para Position
          final route = coordinates.map((coord) {
            return Position(
              coord[1] as double,
              coord[0] as double,
            ); // Note: OSRM retorna [lng, lat]
          }).toList();

          LoggerService().log(
            'ROUTING',
            '✓ Rota carregada com ${route.length} pontos',
          );
          return route;
        } else {
          throw Exception('OSRM: nenhuma rota encontrada');
        }
      } else {
        throw Exception('OSRM HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      LoggerService().log(
        'ROUTING',
        '✗ Erro ao buscar rota (tentativa ${retryCount + 1}/$_maxRetries): $e',
      );

      // Retry se ainda houver tentativas
      if (retryCount < _maxRetries - 1) {
        await Future.delayed(Duration(milliseconds: 500 * (retryCount + 1)));
        return getRoute(origem, destino, retryCount: retryCount + 1);
      }

      // Após todas as tentativas falharem, retornar fallback
      LoggerService().log(
        'ROUTING',
        '⚠️ Usando fallback (linha reta) após $_maxRetries tentativas',
      );
    }

    // Fallback: retornar linha reta se falhar
    return [origem, destino];
  }

  /// Calcula a distância total da rota em km
  static double calculateRouteDistance(List<Position> route) {
    if (route.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += _distanceInKm(route[i], route[i + 1]);
    }
    return totalDistance;
  }

  /// Obtém um ponto na rota baseado no progresso (0.0 a 1.0)
  static Position getPointOnRoute(List<Position> route, double progress) {
    if (route.isEmpty) return Position(0, 0);
    if (progress <= 0.0) return route.first;
    if (progress >= 1.0) return route.last;

    // Calcular distâncias acumuladas
    final distances = <double>[0.0];
    double totalDistance = 0.0;

    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += _distanceInKm(route[i], route[i + 1]);
      distances.add(totalDistance);
    }

    // Encontrar o segmento correspondente ao progresso
    final targetDistance = totalDistance * progress;

    for (int i = 0; i < distances.length - 1; i++) {
      if (targetDistance >= distances[i] &&
          targetDistance <= distances[i + 1]) {
        // Interpolar dentro deste segmento
        final segmentProgress =
            (targetDistance - distances[i]) / (distances[i + 1] - distances[i]);

        final p1 = route[i];
        final p2 = route[i + 1];

        return Position(
          p1.lat + (p2.lat - p1.lat) * segmentProgress,
          p1.lng + (p2.lng - p1.lng) * segmentProgress,
        );
      }
    }

    return route.last;
  }

  static double _distanceInKm(Position a, Position b) {
    const double earthRadius = 6371;
    final dLat = (b.lat - a.lat) * pi / 180;
    final dLng = (b.lng - a.lng) * pi / 180;
    final lat1 = a.lat * pi / 180;
    final lat2 = b.lat * pi / 180;

    final aCalc =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLng / 2) * sin(dLng / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(aCalc), sqrt(1 - aCalc));
    return earthRadius * c;
  }
}
