import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macos_ui/macos_ui.dart';
import 'cubit/device_cubit.dart';
import 'macos_checkbox_list_tile.dart';
import 'models/storage_info.dart';

class DeviceListView extends StatelessWidget {
  const DeviceListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        if (state is DeviceLoaded) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                    controller: ScrollController(),
                    itemCount: state.devices.length,
                    itemBuilder: (context, index) {
                      final device = state.devices[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: MacosCheckBoxListTile(
                            tileColor: device.isMounted
                                ? Colors.green[100]
                                : Colors.transparent,
                            title: Text(device.name),
                            onChanged: (value) => context
                                .read<DeviceCubit>()
                                .toggleDevice(index, value),
                            value: device.isSelected,
                            leading: MacosPulldownButton(
                              icon: CupertinoIcons.ellipsis_circle,
                              items: [
                                MacosPulldownMenuItem(
                                  title: const Text('Select all'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(
                                          StorageAction.selectAll, index),
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Select all others'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(
                                          StorageAction.selectAllOthers, index),
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Unselect all others'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(
                                          StorageAction.unselectAllOthers,
                                          index),
                                ),
                                const MacosPulldownMenuDivider(),
                                MacosPulldownMenuItem(
                                  title: const Text('Show Details'),
                                  onTap: () async {
                                    final storageInfo = await context
                                        .read<DeviceCubit>()
                                        .getStorageInfo(index);
                                    _showOverviewWindow(storageInfo);
                                  },
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Eject Storage'),
                                onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(StorageAction.eject, index),
                                enabled: device.storageType == 'usb',
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Rescan Storage'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(StorageAction.rescan, index),
                                ),
                                MacosPulldownMenuItem(
                                  title: const Text('Remove Data'),
                                  onTap: () => context
                                      .read<DeviceCubit>()
                                      .menuAction(
                                          StorageAction.removeData, index),
                                ),
                              ],
                          ),
                          icon: Icon(
                              device.storageType == 'usb'
                                  ? Icons.usb
                                  : Icons.folder_open,
                              size: 20,
                              color: Colors.black45),
                        ),
                      );
                    }),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${state.devices.length} Storages'),
                  MacosIconButton(
                    backgroundColor: Colors.transparent,
                    icon: const MacosIcon(
//                        size: 32,
                      CupertinoIcons.refresh,
                    ),
                    shape: BoxShape.circle,
                    onPressed: () => context.read<DeviceCubit>().initialize(),
                  ),
//                     MacosIconButton(
//                       backgroundColor: Colors.transparent,
//                       icon: const MacosIcon(
// //                        size: 32,
//                         CupertinoIcons.info,
//                       ),
//                       shape: BoxShape.circle,
//                       onPressed: () => _showOverviewWindow(''),
//                     ),
                ],
              ),
            ],
          );
        } else if (state is DeviceLoading) {
          return const Center(child: CupertinoActivityIndicator());
        } else {
          return const Text('No devices');
        }
      },
    );
  }

  _showOverviewWindow(StorageInfo storageInfo) async {
    final window = await DesktopMultiWindow.createWindow(jsonEncode(
      {
        'args1': 'Overview',
        'args2': 500,
        'args3': true,
        'storageInfo': storageInfo,
      },
    ));
    debugPrint('$window');
    window
      ..setFrame(const Offset(0, 0) & const Size(400, 400))
      ..center()
      ..setTitle('Overview')
      ..show();
  }
}
