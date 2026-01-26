import 'package:http/http.dart' as http;
import 'dart:convert';

/// Serviço de Geocoding Reverso usando Nominatim (OpenStreetMap)
///
/// Performance e otimizações:
/// - Cache de endereços para evitar requisições repetidas
/// - Timeout de 5 segundos para não bloquear a UI
/// - Formatação consistente de endereços
class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  final _cache = <String, String>{};
  static const _baseUrl = 'https://nominatim.openstreetmap.org/reverse';

  /// Obtém o endereço a partir de coordenadas (lat, lng)
  ///
  /// Usa cache para evitar requisições repetidas.
  /// Retorna formato: "Rua Exemplo, Bairro - Cidade/SP"
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    final cacheKey = '${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}';

    // Verifica cache primeiro
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl?lat=$lat&lon=$lng&format=json&accept-language=pt-BR',
            ),
            headers: {'User-Agent': 'LogisticsMonitor/1.0'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = _formatAddress(data);
        _cache[cacheKey] = address;
        return address;
      }
    } catch (e) {
      // Em caso de erro, retorna coordenadas formatadas
      return _formatCoordinatesAsFallback(lat, lng);
    }

    return _formatCoordinatesAsFallback(lat, lng);
  }

  String _formatAddress(Map<String, dynamic> data) {
    try {
      final address = data['address'] as Map<String, dynamic>?;
      if (address == null) {
        return 'Endereço não encontrado';
      }

      final road = address['road'] ?? '';
      final suburb = address['suburb'] ?? address['neighbourhood'] ?? '';
      final city =
          address['city'] ??
          address['town'] ??
          address['village'] ??
          'São Paulo';
      final state = address['state_code'] ?? 'SP';

      final parts = <String>[];
      if (road.isNotEmpty) parts.add(road);
      if (suburb.isNotEmpty) parts.add(suburb);

      final location = parts.join(', ');
      return location.isNotEmpty ? '$location - $city/$state' : '$city/$state';
    } catch (e) {
      return 'Endereço não disponível';
    }
  }

  String _formatCoordinatesAsFallback(double lat, double lng) {
    return 'Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}';
  }

  /// Limpa o cache de endereços
  void clearCache() {
    _cache.clear();
  }

  /// Retorna o tamanho atual do cache
  int get cacheSize => _cache.length;
}
