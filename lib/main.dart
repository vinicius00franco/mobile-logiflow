import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'stores/driver_store.dart';
import 'models/driver.dart' as model;
import 'screens/home_screen.dart';
import 'services/logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar o serviço de logging
  await LoggerService().initialize();
  await LoggerService().cleanOldLogs();

  LoggerService().log('APP', 'Aplicativo iniciado');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DriverStore>(
          create: (_) => DriverStore(
            model.Position(-23.5505, -46.6333),
          ), // Localização do usuário (São Paulo)
          dispose: (_, store) => store.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Monitor de Logística',
        theme: ThemeData(
          primaryColor: Colors.black,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.black,
            secondary: Colors.green,
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}
