import 'dart:math';
import '../models/driver.dart';
import '../data/mock_drivers_data.dart';

class DriverRepository {
  static List<Driver> createInitialDrivers() {
    final origens = mockOrigens;
    final destinos = mockDestinos;
    final nomes = mockNomes;
    final veiculos = mockVeiculos;
    final precos = mockPrecos;

    final drivers = <Driver>[];
    for (int i = 0; i < 4; i++) {
      final origem = origens[i];
      final destino = destinos[i];
      final distancia = _calculateDistance(origem, destino);
      final tempoEstimado = (distancia * 3).round();

      drivers.add(
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
    return drivers;
  }

  static double _calculateDistance(Position a, Position b) {
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
}
