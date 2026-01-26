import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_design.dart';
import '../models/driver.dart'; // Para Position

Color getStatusColor(String status) {
  switch (status) {
    case 'Disponível':
      return AppColors.disponivel;
    case 'Em Entrega':
      return AppColors.emEntrega;
    case 'Offline':
      return AppColors.offline;
    case 'Emergência':
      return AppColors.emergencia;
    default:
      return AppColors.textPrimary;
  }
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

Position interpolatePosition(
  Position origem,
  Position destino,
  double progress,
) {
  final lat = origem.lat + (destino.lat - origem.lat) * progress;
  final lng = origem.lng + (destino.lng - origem.lng) * progress;
  return Position(lat, lng);
}
