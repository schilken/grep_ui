part of 'device_cubit.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<StorageInfo> devices;
  final int deviceCount;

  const DeviceLoaded({
    required this.devices,
    required this.deviceCount,
  });
  @override
  List<Object> get props => [devices, deviceCount];
}
