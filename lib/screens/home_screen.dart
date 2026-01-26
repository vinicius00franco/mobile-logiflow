import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import '../stores/driver_store.dart';
import '../constants/app_design.dart';
import '../components/header_widget.dart';
import '../components/driver/card/driver_card_widget.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverStore = Provider.of<DriverStore>(context);

    // Constrói a estrutura principal da tela inicial com Scaffold, incluindo appBar e body
    return Scaffold(
      backgroundColor: AppColors.background,
      // Constrói a barra de aplicativo com título e botão para navegar ao mapa
      appBar: AppBar(
        title: const Text(
          AppTexts.appName,
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: AppFontSize.xlarge,
            fontWeight: AppFontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: AppColors.textLight),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
          ),
        ],
      ),
      // Constrói o corpo da tela com coluna contendo cabeçalho e lista de motoristas
      body: Column(
        children: [
          HeaderWidget(store: driverStore),
          Expanded(
            child: Observer(
              // Constrói uma lista observável de cartões de motorista
              builder: (_) => ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: driverStore.drivers.length,
                itemBuilder: (context, index) {
                  // Para cada motorista, constrói um cartão com navegação ao mapa
                  return Observer(
                    builder: (_) {
                      final driver = driverStore.drivers[index];
                      return DriverCardWidget(
                        driver: driver,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MapScreen(selectedDriverId: driver.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
