// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DriverStore on _DriverStore, Store {
  Computed<List<Driver>>? _$disponiveisNoRaioComputed;

  @override
  List<Driver> get disponiveisNoRaio =>
      (_$disponiveisNoRaioComputed ??= Computed<List<Driver>>(
        () => super.disponiveisNoRaio,
        name: '_DriverStore.disponiveisNoRaio',
      )).value;
  Computed<List<Driver>>? _$emEntregaComputed;

  @override
  List<Driver> get emEntrega => (_$emEntregaComputed ??= Computed<List<Driver>>(
    () => super.emEntrega,
    name: '_DriverStore.emEntrega',
  )).value;
  Computed<List<Driver>>? _$driversSelectedComputed;

  @override
  List<Driver> get driversSelected =>
      (_$driversSelectedComputed ??= Computed<List<Driver>>(
        () => super.driversSelected,
        name: '_DriverStore.driversSelected',
      )).value;

  late final _$driversAtom = Atom(
    name: '_DriverStore.drivers',
    context: context,
  );

  @override
  List<Driver> get drivers {
    _$driversAtom.reportRead();
    return super.drivers;
  }

  @override
  set drivers(List<Driver> value) {
    _$driversAtom.reportWrite(value, super.drivers, () {
      super.drivers = value;
    });
  }

  late final _$selectedDriverIdsAtom = Atom(
    name: '_DriverStore.selectedDriverIds',
    context: context,
  );

  @override
  ObservableSet<String> get selectedDriverIds {
    _$selectedDriverIdsAtom.reportRead();
    return super.selectedDriverIds;
  }

  @override
  set selectedDriverIds(ObservableSet<String> value) {
    _$selectedDriverIdsAtom.reportWrite(value, super.selectedDriverIds, () {
      super.selectedDriverIds = value;
    });
  }

  late final _$followingDriverIdAtom = Atom(
    name: '_DriverStore.followingDriverId',
    context: context,
  );

  @override
  String? get followingDriverId {
    _$followingDriverIdAtom.reportRead();
    return super.followingDriverId;
  }

  @override
  set followingDriverId(String? value) {
    _$followingDriverIdAtom.reportWrite(value, super.followingDriverId, () {
      super.followingDriverId = value;
    });
  }

  late final _$driversStreamAtom = Atom(
    name: '_DriverStore.driversStream',
    context: context,
  );

  @override
  ObservableStream<List<Driver>> get driversStream {
    _$driversStreamAtom.reportRead();
    return super.driversStream;
  }

  bool _driversStreamIsInitialized = false;

  @override
  set driversStream(ObservableStream<List<Driver>> value) {
    _$driversStreamAtom.reportWrite(
      value,
      _driversStreamIsInitialized ? super.driversStream : null,
      () {
        super.driversStream = value;
        _driversStreamIsInitialized = true;
      },
    );
  }

  late final _$isDriverCardsExpandedAtom = Atom(
    name: '_DriverStore.isDriverCardsExpanded',
    context: context,
  );

  @override
  bool get isDriverCardsExpanded {
    _$isDriverCardsExpandedAtom.reportRead();
    return super.isDriverCardsExpanded;
  }

  @override
  set isDriverCardsExpanded(bool value) {
    _$isDriverCardsExpandedAtom.reportWrite(
      value,
      super.isDriverCardsExpanded,
      () {
        super.isDriverCardsExpanded = value;
      },
    );
  }

  late final _$hasEmergencyAtom = Atom(
    name: '_DriverStore.hasEmergency',
    context: context,
  );

  @override
  bool get hasEmergency {
    _$hasEmergencyAtom.reportRead();
    return super.hasEmergency;
  }

  @override
  set hasEmergency(bool value) {
    _$hasEmergencyAtom.reportWrite(value, super.hasEmergency, () {
      super.hasEmergency = value;
    });
  }

  late final _$_DriverStoreActionController = ActionController(
    name: '_DriverStore',
    context: context,
  );

  @override
  void toggleDriverSelection(String id) {
    final _$actionInfo = _$_DriverStoreActionController.startAction(
      name: '_DriverStore.toggleDriverSelection',
    );
    try {
      return super.toggleDriverSelection(id);
    } finally {
      _$_DriverStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleFollowDriver(String? driverId) {
    final _$actionInfo = _$_DriverStoreActionController.startAction(
      name: '_DriverStore.toggleFollowDriver',
    );
    try {
      return super.toggleFollowDriver(driverId);
    } finally {
      _$_DriverStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleDriverCardsExpansion() {
    final _$actionInfo = _$_DriverStoreActionController.startAction(
      name: '_DriverStore.toggleDriverCardsExpansion',
    );
    try {
      return super.toggleDriverCardsExpansion();
    } finally {
      _$_DriverStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDriverCardsExpanded(bool expanded) {
    final _$actionInfo = _$_DriverStoreActionController.startAction(
      name: '_DriverStore.setDriverCardsExpanded',
    );
    try {
      return super.setDriverCardsExpanded(expanded);
    } finally {
      _$_DriverStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
drivers: ${drivers},
selectedDriverIds: ${selectedDriverIds},
followingDriverId: ${followingDriverId},
driversStream: ${driversStream},
isDriverCardsExpanded: ${isDriverCardsExpanded},
hasEmergency: ${hasEmergency},
disponiveisNoRaio: ${disponiveisNoRaio},
emEntrega: ${emEntrega},
driversSelected: ${driversSelected}
    ''';
  }
}
