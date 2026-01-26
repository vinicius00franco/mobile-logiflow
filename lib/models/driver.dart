class Position {
  final double lat;
  final double lng;
  Position(this.lat, this.lng);

  @override
  String toString() => 'Position($lat, $lng)';
}

/// Entrada do histórico de endereços percorridos
class AddressHistoryEntry {
  final Position position;
  final String address;
  final DateTime timestamp;

  AddressHistoryEntry({
    required this.position,
    required this.address,
    required this.timestamp,
  });
}

class Driver {
  final String id;
  final String nome;
  final Position posicao;
  final Position origem;
  final Position destino;
  // Endereços resolvidos (opcionais). Se null, usar coordenadas formatadas.
  final String? posicaoEndereco;
  final String? origemEndereco;
  final String? destinoEndereco;
  // Histórico de endereços percorridos (cronológico)
  final List<AddressHistoryEntry> historicoEnderecos;
  final String status; // "Disponível", "Em Entrega", "Offline", "Emergência"
  final String veiculo;
  final double preco;
  final double distancia; // em km
  final int tempoEstimado; // em minutos
  final List<Position> rota; // Rota completa seguindo as ruas

  Driver({
    required this.id,
    required this.nome,
    required this.posicao,
    required this.origem,
    required this.destino,
    required this.status,
    required this.veiculo,
    required this.preco,
    required this.distancia,
    required this.tempoEstimado,
    this.rota = const [],
    this.posicaoEndereco,
    this.origemEndereco,
    this.destinoEndereco,
    this.historicoEnderecos = const [],
  });

  Driver copyWith({
    String? id,
    String? nome,
    Position? posicao,
    Position? origem,
    Position? destino,
    String? posicaoEndereco,
    String? origemEndereco,
    String? destinoEndereco,
    List<AddressHistoryEntry>? historicoEnderecos,
    String? status,
    String? veiculo,
    double? preco,
    double? distancia,
    int? tempoEstimado,
    List<Position>? rota,
  }) {
    return Driver(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      posicao: posicao ?? this.posicao,
      origem: origem ?? this.origem,
      destino: destino ?? this.destino,
      posicaoEndereco: posicaoEndereco ?? this.posicaoEndereco,
      origemEndereco: origemEndereco ?? this.origemEndereco,
      destinoEndereco: destinoEndereco ?? this.destinoEndereco,
      historicoEnderecos: historicoEnderecos ?? this.historicoEnderecos,
      status: status ?? this.status,
      veiculo: veiculo ?? this.veiculo,
      preco: preco ?? this.preco,
      distancia: distancia ?? this.distancia,
      tempoEstimado: tempoEstimado ?? this.tempoEstimado,
      rota: rota ?? this.rota,
    );
  }
}
