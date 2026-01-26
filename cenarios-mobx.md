# MobX + Flutter: Cenários Avançados

Este documento reúne cinco cenários práticos de uso do MobX em apps Flutter, com objetivos, padrões, peculiaridades e ações bem definidas, além de snippets que você pode adaptar.

> Dependências sugeridas: `mobx`, `flutter_mobx`, `mobx_codegen`, `build_runner`, `web_socket_channel`, `geolocator` (ou utilitário de distância), `audioplayers`, `shared_preferences`, `get_it`/`provider`.

---

## 1) Monitor de Logística em Tempo Real (WebSockets e Fluxo Contínuo)

- Objetivo: Atualizar motoristas em tempo real sem interação do usuário.
- Interface: Mapa ou lista de motoristas com status (Disponível, Em Entrega, Offline, Emergência).
- Padrões MobX:
  - `ObservableStream` para dados vindos de WebSocket.
  - `@computed` para filtrar motoristas disponíveis em um raio de 5 km.
  - `reaction` para alerta sonoro/visual quando status virar "Emergência".

### Store base

```dart
import 'dart:async';
import 'package:mobx/mobx.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'driver_store.g.dart';

class LatLng {
  final double lat;
  final double lng;
  LatLng(this.lat, this.lng);
}

class Driver {
  final String id;
  final LatLng posicao;
  final String status; // "Disponível", "Em Entrega", "Offline", "Emergência"
  Driver({required this.id, required this.posicao, required this.status});
}

class DriverStore = _DriverStore with Store;

abstract class _DriverStore with Store {
  final WebSocketChannel channel;
  final LatLng userLocation;
  _DriverStore(this.channel, this.userLocation) {
    driversStream = ObservableStream<List<Driver>>(
      channel.stream.map<List<Driver>>((data) => parseDrivers(data)),
    );

    _streamSub = driversStream.listen((list) => drivers = list);

    _emergencyDisposer = reaction<List<Driver>>(
      (_) => drivers,
      (list) {
        final hasEmergencia = list.any((d) => d.status == 'Emergência');
        if (hasEmergencia) alertaEmergencia();
      },
    );
  }

  @observable
  List<Driver> drivers = [];

  @observable
  late ObservableStream<List<Driver>> driversStream;

  StreamSubscription<List<Driver>>? _streamSub;
  late ReactionDisposer _emergencyDisposer;

  @computed
  List<Driver> get disponiveisNoRaio => drivers
      .where((d) => d.status == 'Disponível')
      .where((d) => distanceInKm(userLocation, d.posicao) <= 5.0)
      .toList(growable: false);

  void alertaEmergencia() {
    // Disparar som, snackbar, dialog, etc.
  }

  List<Driver> parseDrivers(dynamic data) {
    // Converter payload do WebSocket em lista de Driver
    return <Driver>[];
  }

  double distanceInKm(LatLng a, LatLng b) {
    // Implemente com geolocator ou util próprio
    return 0.0;
  }

  void dispose() {
    _streamSub?.cancel();
    _emergencyDisposer();
  }
}
```

---

## 2) Editor de Perfil com "Rascunho" (Deep Nesting e Dirty State)

- Objetivo: Editar dados complexos e descartar mudanças se não salvar.
- Interface: Formulário com múltiplos objetos (Endereço, Telefones, Redes Sociais).
- Padrões MobX:
  - `UserStore` guardando dados originais e um rascunho editável.
  - `ObservableList<PhoneStore>` para telefones.
  - `@computed bool get isDirty` para comparar rascunho vs original.
  - `@action reset()` para restaurar o estado original.

### Store base

```dart
import 'package:mobx/mobx.dart';
part 'user_store.g.dart';

class PhoneStore = _PhoneStore with Store;
abstract class _PhoneStore with Store {
  @observable
  String number = '';

  @observable
  String label = 'Celular';
}

class Address {
  final String street;
  final String city;
  final String zip;
  Address({required this.street, required this.city, required this.zip});
}

class UserData {
  final String name;
  final Address address;
  final List<Map<String, String>> socials; // ex.: [{"twitter": "@user"}]
  final List<PhoneStore> phones;
  UserData({required this.name, required this.address, required this.socials, required this.phones});
}

class UserStore = _UserStore with Store;
abstract class _UserStore with Store {
  _UserStore(this.original) {
    loadDraftFromOriginal();
  }

  final UserData original;

  @observable
  String nameDraft = '';

  @observable
  Address? addressDraft;

  @observable
  ObservableList<PhoneStore> phonesDraft = ObservableList<PhoneStore>();

  @observable
  ObservableList<Map<String, String>> socialsDraft = ObservableList<Map<String, String>>();

  @computed
  bool get isDirty {
    if (nameDraft != original.name) return true;
    if (!_equalsAddress(addressDraft, original.address)) return true;
    if (!_equalsPhones(phonesDraft, original.phones)) return true;
    if (!_equalsSocials(socialsDraft, original.socials)) return true;
    return false;
  }

  @action
  void reset() {
    loadDraftFromOriginal();
  }

  @action
  void loadDraftFromOriginal() {
    nameDraft = original.name;
    addressDraft = original.address;
    phonesDraft = ObservableList.of(
      original.phones.map((p) => PhoneStore()..number = p.number..label = p.label),
    );
    socialsDraft = ObservableList.of(original.socials);
  }

  bool _equalsAddress(Address? a, Address b) {
    if (a == null) return false;
    return a.street == b.street && a.city == b.city && a.zip == b.zip;
  }

  bool _equalsPhones(List<PhoneStore> a, List<PhoneStore> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].number != b[i].number || a[i].label != b[i].label) return false;
    }
    return true;
  }

  bool _equalsSocials(List<Map<String, String>> a, List<Map<String, String>> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].toString() != b[i].toString()) return false; // simplificação
    }
    return true;
  }
}
```

---

## 3) Player de Áudio/Podcast (Estado Global e Background)

- Objetivo: UI refletir estado vindo de fora da árvore de widgets.
- Interface: Barra de reprodução global e tela cheia do player.
- Padrões MobX:
  - `@observable` para progresso (`Duration position`) e estado (`isPlaying`).
  - `autorun` para sincronizar posição/progresso com o plugin de áudio.
  - Store única injetada com `Provider` ou `GetIt` para Play/Pause simultâneo.

### Store base

```dart
import 'dart:async';
import 'package:mobx/mobx.dart';
import 'package:audioplayers/audioplayers.dart';
part 'audio_store.g.dart';

class AudioStore = _AudioStore with Store;
abstract class _AudioStore with Store {
  final AudioPlayer _player = AudioPlayer();

  _AudioStore() {
    _posSub = _player.onPositionChanged.listen((p) => position = p);
    _autorunDisposer = autorun((_) async {
      // Manter o plugin alinhado ao estado MobX
      if (isPlaying) {
        await _player.resume();
      } else {
        await _player.pause();
      }
    });
  }

  @observable
  Duration position = Duration.zero;

  @observable
  bool isPlaying = false;

  late StreamSubscription<Duration> _posSub;
  late ReactionDisposer _autorunDisposer;

  @action
  Future<void> playUrl(String url) async {
    await _player.stop();
    await _player.play(UrlSource(url));
    isPlaying = true;
  }

  @action
  Future<void> toggle() async {
    isPlaying = !isPlaying;
  }

  void dispose() {
    _posSub.cancel();
    _autorunDisposer();
    _player.dispose();
  }
}
```

> Dica: Registre a store global com `GetIt` (`GetIt.I.registerSingleton(AudioStore())`) ou forneça via `Provider` no topo da árvore. Todos os botões observam `isPlaying` e mudam ícone simultaneamente.

---

## 4) Sistema de Busca com Cache e Histórico (Async e Debounce)

- Objetivo: Sugestões enquanto digita com requisições eficientes.
- Interface: Campo de busca + lista de resultados/sugestões.
- Padrões MobX:
  - `ObservableFuture` para estados `Loading/Success/Error` de HTTP.
  - Debounce de 500 ms para evitar rajada de requisições.
  - `ObservableList` para histórico de últimas 5 buscas, persistido em `SharedPreferences`.

### Store base

```dart
import 'dart:async';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'search_store.g.dart';

class SearchStore = _SearchStore with Store;
abstract class _SearchStore with Store {
  Timer? _debounce;

  @observable
  String query = '';

  @observable
  ObservableFuture<List<String>>? resultsFuture;

  @observable
  ObservableList<String> history = ObservableList<String>();

  @action
  void setQuery(String value) {
    query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _runSearch);
  }

  @action
  Future<void> _runSearch() async {
    if (query.trim().isEmpty) return;
    final future = ObservableFuture<List<String>>(fetchResults(query));
    resultsFuture = future;
    final items = await future;
    await _addToHistory(query);
    // lidar com resultados na UI observando resultsFuture.status
  }

  Future<List<String>> fetchResults(String q) async {
    // Chame sua API; retorne uma lista de strings ou modelo
    await Future.delayed(const Duration(milliseconds: 300));
    return List.generate(5, (i) => '$q resultado $i');
  }

  Future<void> _addToHistory(String q) async {
    if (q.isEmpty) return;
    // Atualiza observável
    history.remove(q);
    history.insert(0, q);
    if (history.length > 5) {
      history.removeRange(5, history.length);
    }
    // Persiste
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', history.toList());
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('search_history') ?? [];
    history = ObservableList.of(list);
  }

  void dispose() {
    _debounce?.cancel();
  }
}
```

> Alternativa: Use `reaction(() => query, _runSearch, delay: 500)` para um debounce declarativo.

---

## 5) Wallet de Cripto/Investimentos (Multi-Moedas e Conversão Dinâmica)

- Objetivo: Converter e somar valores conforme moeda base (USD/BRL).
- Interface: Lista de ativos (BTC, ETH, BRL) + seletor de moeda base.
- Padrões MobX:
  - Store central de cotações.
  - `@computed` para saldo total convertido automaticamente ao mudar a base.
  - `when` para notificar "Meta Atingida" quando saldo passar do alvo.

### Stores base

```dart
import 'package:mobx/mobx.dart';
part 'wallet_store.g.dart';

class Asset {
  final String symbol; // ex.: 'BTC', 'ETH', 'BRL'
  final double amount; // quantidade do ativo
  Asset(this.symbol, this.amount);
}

class RatesStore = _RatesStore with Store;
abstract class _RatesStore with Store {
  // cotação por símbolo na moeda base selecionada
  @observable
  Map<String, double> rates = {'BTC': 0.0, 'ETH': 0.0, 'BRL': 1.0};

  @observable
  String base = 'BRL'; // 'USD' ou 'BRL'
}

class PortfolioStore = _PortfolioStore with Store;
abstract class _PortfolioStore with Store {
  final RatesStore ratesStore;
  PortfolioStore(this.ratesStore);

  @observable
  ObservableList<Asset> assets = ObservableList.of([
    Asset('BTC', 0.05), Asset('ETH', 1.2), Asset('BRL', 500.0),
  ]);

  @observable
  double goal = 10000.0; // meta na moeda base

  late ReactionDisposer _goalDisposer;

  @computed
  double get totalInBase {
    return assets.fold<double>(0.0, (sum, a) {
      final price = ratesStore.rates[a.symbol] ?? 0.0;
      return sum + a.amount * price;
    });
  }

  void startWatchingGoal(void Function() onGoal) {
    _goalDisposer = when((_) => totalInBase >= goal, onGoal);
  }

  void dispose() {
    _goalDisposer();
  }
}
```

> Dica: Atualize `rates` periodicamente (HTTP/WebSocket). Ao mudar `base`, recalibre `rates` e a UI refletirá a conversão automaticamente via `@computed`.

---

## Boas Práticas Gerais

- Dispose: Guarde e descarte `ReactionDisposer`, `StreamSubscription` e timers em `dispose()`.
- Codegen: Lembre de rodar `flutter pub run build_runner build --delete-conflicting-outputs` para gerar `*.g.dart` das stores.
- Separação: Mantenha stores enxutas e sem lógica de UI; widgets apenas observam (`Observer`) e chamam `@action`s.
- Testes: Cubra `@computed`, `reaction`/`autorun` e `when` com testes unitários.
