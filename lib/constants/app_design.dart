import 'package:flutter/material.dart';

// Cores principais (estilo Uber/Gojek)
class AppColors {
  static const primary = Color(0xFF000000); // Preto
  static const secondary = Color(0xFF00D9A3); // Verde
  static const accent = Color(0xFF1DB954); // Verde claro
  static const background = Color(0xFFF5F5F5); // Cinza claro
  static const cardBackground = Color(0xFFFFFFFF);

  // Status
  static const disponivel = Color(0xFF4CAF50); // Verde
  static const emEntrega = Color(0xFF2196F3); // Azul
  static const offline = Color(0xFF9E9E9E); // Cinza
  static const emergencia = Color(0xFFF44336); // Vermelho

  // Textos
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF757575);
  static const textLight = Color(0xFFFFFFFF);

  // Component colors
  static const progressActive = Color(0xFF2196F3); // Azul padrão para progresso
  static const progressInactive = Color(
    0xFFE0E0E0,
  ); // Cinza claro para progresso inativo

  // Shadows (alpha variations)
  static const shadow15 = Color(0x0F000000); // preto com alpha 15
  static const shadow25 = Color(0x19000000); // preto com alpha 25
  static const shadow50 = Color(0x32000000); // preto com alpha 50
  static const shadow100 = Color(0x64000000); // preto com alpha 100

  // Greys usados no mapa
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey800 = Color(0xFF424242);

  // Utilitários
  static const transparent = Color(0x00000000);

  // Preto com opacidades comuns
  static const black70 = Color.fromRGBO(0, 0, 0, 0.7);
}

// Espaçamentos
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

// Tamanhos de fonte
class AppFontSize {
  static const small = 12.0;
  static const medium = 14.0;
  static const large = 16.0;
  static const xlarge = 20.0;
  static const xxlarge = 24.0;
}

// Pesos de fonte
class AppFontWeight {
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
}

// Border Radius
class AppBorderRadius {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const xlarge = 24.0;
}

// Ícones por tipo de veículo
class VehicleIcons {
  static const moto = Icons.two_wheeler_rounded;
  static const carro = Icons.directions_car_filled_rounded;
  static const van = Icons.airport_shuttle_rounded;
  static const caminhao = Icons.local_shipping_rounded;
}

// Moeda
class AppCurrency {
  static const String symbol = 'R\$';
}

// Textos Gerais do Sistema
class AppTexts {
  static const appName = 'LogiFlow';
  static const welcomeManager = 'Olá, Gestor';
  static const fleetStatus = 'Status da frota hoje';
}
