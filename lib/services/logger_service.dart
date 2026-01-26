import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Serviço de logging para arquivo
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  File? _logFile;
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

  /// Inicializa o arquivo de log
  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final timestamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _logFile = File('${logDir.path}/logistics_monitor_$timestamp.log');

      // Criar arquivo se não existir
      if (!await _logFile!.exists()) {
        await _logFile!.create();
        await _logFile!.writeAsString(
          '=== Logistics Monitor Log - $timestamp ===\n',
        );
      }
    } catch (e) {
      print('Erro ao inicializar logger: $e');
    }
  }

  /// Escreve log com contexto de domínio
  Future<void> log(String domain, String message) async {
    try {
      if (_logFile == null) {
        await initialize();
      }

      final timestamp = _dateFormat.format(DateTime.now());
      final logEntry = '[$timestamp] [$domain] $message\n';

      // Escrever no arquivo
      await _logFile?.writeAsString(logEntry, mode: FileMode.append);

      // Também imprimir no console para debug
      print('[$domain] $message');
    } catch (e) {
      print('Erro ao escrever log: $e');
    }
  }

  /// Limpa logs antigos (mantém últimos 7 dias)
  Future<void> cleanOldLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory('${directory.path}/logs');

      if (await logDir.exists()) {
        final files = logDir.listSync();
        final now = DateTime.now();

        for (var file in files) {
          if (file is File && file.path.endsWith('.log')) {
            final stat = await file.stat();
            final age = now.difference(stat.modified).inDays;

            if (age > 7) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      print('Erro ao limpar logs antigos: $e');
    }
  }
}
