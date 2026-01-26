import '../models/driver.dart'; // Para Position

// Dados mockados para motoristas
final List<Position> mockOrigens = [
  Position(-23.5505, -46.6333), // Centro
  Position(-23.5629, -46.6544), // Av Paulista
  Position(-23.5475, -46.6361), // República
  Position(-23.5475, -46.7355), // Pinheiros
];

final List<Position> mockDestinos = [
  Position(-23.5880, -46.6592), // Vila Mariana
  Position(-23.5328, -46.6394), // Santana
  Position(-23.5740, -46.6826), // Jardins
  Position(-23.6132, -46.6987), // Brooklin
];

final List<String> mockNomes = ['João Silva', 'Maria Santos', 'Pedro Costa', 'Ana Oliveira'];

final List<String> mockVeiculos = ['Moto', 'Carro', 'Moto +', 'Carro +'];

final List<double> mockPrecos = [4000.0, 24000.0, 6000.0, 35000.0];