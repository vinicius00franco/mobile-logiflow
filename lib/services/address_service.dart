import '../models/driver.dart';
import '../services/geocoding_service.dart';

class AddressService {
  final GeocodingService _geocodingService;

  AddressService(this._geocodingService);

  Future<Driver> resolveDriverAddresses(Driver driver) async {
    try {
      final posAddr = await _geocodingService.getAddressFromCoordinates(
        driver.posicao.lat,
        driver.posicao.lng,
      );
      final origAddr = await _geocodingService.getAddressFromCoordinates(
        driver.origem.lat,
        driver.origem.lng,
      );
      final destAddr = await _geocodingService.getAddressFromCoordinates(
        driver.destino.lat,
        driver.destino.lng,
      );

      return driver.copyWith(
        posicaoEndereco: posAddr,
        origemEndereco: origAddr,
        destinoEndereco: destAddr,
      );
    } catch (e) {
      // Falha silenciosa: GeocodingService já possui fallback para coordenadas
      return driver;
    }
  }

  Future<String> getAddressForPosition(Position position) async {
    try {
      return await _geocodingService.getAddressFromCoordinates(
        position.lat,
        position.lng,
      );
    } catch (e) {
      return 'Lat: ${position.lat.toStringAsFixed(4)}, Lng: ${position.lng.toStringAsFixed(4)}';
    }
  }

  Future<Driver> updateDriverPositionAddress(Driver driver) async {
    try {
      final address = await getAddressForPosition(driver.posicao);

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
        // Manter apenas os últimos 50 endereços para evitar crescimento excessivo
        if (newHistory.length > 50) {
          newHistory.removeAt(0);
        }
      }

      return driver.copyWith(
        posicaoEndereco: address,
        historicoEnderecos: newHistory,
      );
    } catch (e) {
      return driver;
    }
  }
}
