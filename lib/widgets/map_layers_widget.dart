import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/map_constants.dart';
import '../constants/app_design.dart';
import '../models/driver.dart' as model;
import '../utils/map_utils.dart';

class MapLayersWidget extends StatelessWidget {
  final List<model.Driver> drivers;
  final Function(model.Driver) onMarkerTap;
  final String mapStyle;

  const MapLayersWidget({
    super.key,
    required this.drivers,
    required this.onMarkerTap,
    this.mapStyle = 'OpenStreetMap',
  });

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers(drivers);
    final polylines = _buildPolylines(drivers);

    return Stack(
      children: [
        TileLayer(
          urlTemplate: mapStyles[mapStyle] ?? tileUrlTemplate,
          userAgentPackageName: userAgent,
        ),
        PolylineLayer(polylines: polylines),
        MarkerLayer(markers: markers),
      ],
    );
  }

  List<Marker> _buildMarkers(List<model.Driver> drivers) {
    final markers = <Marker>[];

    for (var driver in drivers) {
      // Marker da posição atual do motorista
      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: LatLng(driver.posicao.lat, driver.posicao.lng),
          child: GestureDetector(
            onTap: () => onMarkerTap(driver),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow50,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    driver.nome.split(' ').first,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _getVehicleIconData(driver.veiculo),
                  color: getStatusColor(driver.status),
                  size: 32,
                  shadows: [
                    Shadow(color: AppColors.shadow100, blurRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      // Marker da origem
      final markerColors = _getMarkerColors(mapStyle);
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(driver.origem.lat, driver.origem.lng),
          child: Container(
            decoration: BoxDecoration(
              color: markerColors['origin']!,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBackground, width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.shadow50, blurRadius: 4),
              ],
            ),
            child: Icon(Icons.location_on, color: AppColors.textLight, size: 20),
          ),
        ),
      );

      // Marker do destino
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(driver.destino.lat, driver.destino.lng),
          child: Container(
            decoration: BoxDecoration(
              color: markerColors['destination']!,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBackground, width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.shadow50, blurRadius: 4),
              ],
            ),
            child: Icon(Icons.flag, color: AppColors.textLight, size: 20),
          ),
        ),
      );
    }

    return markers;
  }

  IconData _getVehicleIconData(String veiculo) {
    final v = veiculo.toLowerCase();
    if (v.contains('moto')) return Icons.two_wheeler_rounded;
    if (v.contains('van')) return Icons.airport_shuttle_rounded;
    if (v.contains('caminhão') || v.contains('caminhao')) {
      return Icons.local_shipping_rounded;
    }
    return Icons.directions_car_filled_rounded;
  }

  List<Polyline> _buildPolylines(List<model.Driver> drivers) {
    final polylines = <Polyline>[];

    for (var driver in drivers) {
      if (driver.status == 'Em Entrega') {
        // Determinar cor da rota baseada no estilo do mapa
        final routeColor = _getRouteColor(mapStyle);

        // Usar rota real do OSRM se disponível (mais de 2 pontos significa rota real)
        if (driver.rota.length > 2) {
          // Rota completa seguindo as ruas
          polylines.add(
            Polyline(
              points: driver.rota
                  .map((point) => LatLng(point.lat, point.lng))
                  .toList(),
              strokeWidth: 4.0,
              color: routeColor,
              borderStrokeWidth: 2.0,
              borderColor: AppColors.cardBackground,
            ),
          );

          // Encontrar o ponto mais próximo da posição atual na rota
          final rotaConvertida = driver.rota
              .map((p) => LatLng(p.lat, p.lng))
              .toList();
          final posicaoConvertida = LatLng(
            driver.posicao.lat,
            driver.posicao.lng,
          );
          int posicaoNaRota = _findClosestPointIndex(
            posicaoConvertida,
            rotaConvertida,
          );

          // Desenhar trajeto restante com transparência
          if (posicaoNaRota < rotaConvertida.length - 1) {
            polylines.add(
              Polyline(
                points: rotaConvertida.sublist(posicaoNaRota),
                strokeWidth: 3.0,
                color: routeColor.withAlpha(128),
              ),
            );
          }
        }
        // Não desenhar fallback (linha reta) no mapa
      }
    }

    return polylines;
  }

  int _findClosestPointIndex(LatLng position, List<LatLng> route) {
    if (route.isEmpty) return 0;

    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < route.length; i++) {
      final distance = _calculateDistance(position, route[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  double _calculateDistance(LatLng a, LatLng b) {
    final dLat = a.latitude - b.latitude;
    final dLng = a.longitude - b.longitude;
    return dLat * dLat +
        dLng *
            dLng; // Distância euclidiana ao quadrado (suficiente para comparação)
  }

  Color _getRouteColor(String mapStyle) {
    // Para mapas claros (Uber Light), usar preto
    // Para mapas escuros (Uber Dark), usar cinza
    if (mapStyle.contains('Dark') || mapStyle.contains('dark')) {
      return AppColors.grey400; // Cinza para mapas escuros
    } else {
      return AppColors.primary; // Preto para mapas claros
    }
  }

  Map<String, Color> _getMarkerColors(String mapStyle) {
    if (mapStyle.contains('Dark') || mapStyle.contains('dark')) {
      // Cores para mapas escuros
      return {
        'origin': AppColors.grey600, // Cinza escuro para origem
        'destination': AppColors.grey500, // Cinza médio para destino
      };
    } else {
      // Cores para mapas claros
      return {
        'origin': AppColors.primary, // Preto para origem
        'destination': AppColors.grey800, // Cinza escuro para destino
      };
    }
  }
}
