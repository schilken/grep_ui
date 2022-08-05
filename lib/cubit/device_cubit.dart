import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../event_bus.dart';
import '../files_repository.dart';
import '../models/storage_info.dart';

part 'device_state.dart';

enum StorageAction {
  selectAll,
  selectAllOthers,
  unselectAllOthers,
  showInfo,
  rescan,
  removeData,
  eject,
}

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit(this.filesRepository) : super(DeviceInitial());

  final FilesRepository filesRepository;
  StreamSubscription<DevicesChanged>? _devicesChangedSubscription;

  Future<DeviceCubit> initialize() async {
    emit(DeviceLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    final devices = await filesRepository.readStorageInfos();
    emit(
      DeviceLoaded(
        devices: devices,
        deviceCount: devices.length,
      ),
    );
    _devicesChangedSubscription =
        eventBus.on<DevicesChanged>().listen((event) async {
      print('DeviceCubit event: $event');
      final updatedDevices = await filesRepository.readStorageInfos();
      emit(
        DeviceLoaded(
          devices: updatedDevices,
          deviceCount: updatedDevices.length,
        ),
      );
    });
    await menuAction(StorageAction.selectAll, 0);
    return this;
  }

  Future<void> dispose() async {
    print('>>>>>>>>>> DeviceCubit dispose');
    await _devicesChangedSubscription?.cancel();
  }

  void toggleDevice(
    int index,
    bool? value,
  ) {
    final currentState = state as DeviceLoaded;
    emit(
      DeviceLoaded(
        devices: filesRepository.toggleDevice(index, value),
        deviceCount: currentState.deviceCount,
      ),
    );
  }

  Future<StorageInfo> getStorageInfo(int index) async {
    final storageInfo = await filesRepository.loadStorageInfoForDevice(
        filesRepository.storageInfoForIndex(index));
    return storageInfo;
  }

  Future<dynamic> menuAction(StorageAction action, int index) async {
    print('menuAction: $action');
    switch (action) {
      case StorageAction.selectAll:
      case StorageAction.selectAllOthers:
      case StorageAction.unselectAllOthers:
      case StorageAction.eject:
      case StorageAction.removeData:
        final infoList =
            await filesRepository.executeStorageAction(action, index);
        emit(DeviceLoaded(
          devices: infoList,
          deviceCount: infoList.length,
        ));
        break;
      case StorageAction.showInfo:
        break;
      case StorageAction.rescan:
        eventBus.fire(RescanDevice(index));
        break;
    }
  }
}
