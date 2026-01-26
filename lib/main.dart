import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stores/driver_store.dart';
import 'models/driver.dart' as model;
import 'screens/home_screen.dart';
import 'services/logger_service.dart';
import 'repository/driver_repository.dart';
import 'services/route_loader_service.dart';
import 'services/address_service.dart';
import 'services/movement_simulator.dart';
import 'services/geocoding_service.dart';
import 'constants/app_design.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o serviço de logging
  final logger = LoggerService();
  await logger.initialize();
  await logger.cleanOldLogs();

  logger.log('APP', 'Aplicativo iniciado');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LoggerService>(create: (_) => LoggerService()),
        Provider<DriverRepository>(create: (_) => DriverRepository()),
        Provider<RouteLoaderService>(
          create: (context) => RouteLoaderService(
            Provider.of<LoggerService>(context, listen: false),
          ),
        ),
        Provider<AddressService>(
          create: (context) => AddressService(GeocodingService()),
        ),
        Provider<MovementSimulator>(
          create: (context) => MovementSimulator(
            Provider.of<RouteLoaderService>(context, listen: false),
            Provider.of<AddressService>(context, listen: false),
            Provider.of<LoggerService>(context, listen: false),
          ),
        ),
        Provider<DriverStore>(
          create: (context) => DriverStore(
            model.Position(
              -23.5505,
              -46.6333,
            ), // Localização do usuário (São Paulo)
            Provider.of<DriverRepository>(context, listen: false),
            Provider.of<RouteLoaderService>(context, listen: false),
            Provider.of<AddressService>(context, listen: false),
            Provider.of<MovementSimulator>(context, listen: false),
            Provider.of<LoggerService>(context, listen: false),
          ),
          dispose: (_, store) => store.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Monitor de Logística',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
