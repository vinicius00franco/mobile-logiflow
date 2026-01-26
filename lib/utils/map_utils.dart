import 'package:flutter/material.dart';
import '../constants/app_design.dart';

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
