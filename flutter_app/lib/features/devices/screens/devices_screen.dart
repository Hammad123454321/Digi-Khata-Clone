import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/sync/sync_service.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../core/localization/app_localizations.dart';
import 'device_pairing_screen.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;
  String? _error;
  bool _isOffline = false;

  final LocalStorageService _storage = getIt<LocalStorageService>();
  final SyncService _syncService = getIt<SyncService>();

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.get(ApiConstants.devices);
      final devices =
          (response.data as List<dynamic>).cast<Map<String, dynamic>>();

      if (mounted) {
        await _storage.saveCachedDevices(devices);
        setState(() {
          _devices = devices;
          _isLoading = false;
          _isOffline = false;
        });
      }
    } catch (e) {
      final cached = _storage.getCachedDevices();
      if (mounted) {
        setState(() {
          _devices = cached ?? [];
          _error = cached == null ? e.toString() : null;
          _isLoading = false;
          _isOffline = cached != null;
        });
      }
    }
  }

  Future<void> _revokeDevice(String deviceId) async {
    final loc = AppLocalizations.of(context)!;
    final isOnline = await _syncService.isOnline();
    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.onlineRequired),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.revokeDevice),
        content: Text(loc.revokeDeviceConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(loc.revoke),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final apiClient = getIt<ApiClient>();
        await apiClient.delete('${ApiConstants.devices}/$deviceId');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.deviceRevokedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          _loadDevices();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                loc.failedToRevokeDevice.replaceAll('{error}', e.toString()),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final dateFormatter = DateFormat.yMMMd(loc.locale.languageCode).add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.pairedDevices),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _error != null
            ? AppErrorWidget(
                message: _error!,
                onRetry: _loadDevices,
              )
            : _devices.isEmpty
                ? EmptyState(
                    icon: Icons.devices,
                    title: loc.noDevices,
                    message: loc.pairDeviceToGetStarted,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _devices.length + (_isOffline ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isOffline && index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    loc.offlineDataMayBeIncomplete,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final device = _devices[_isOffline ? index - 1 : index];
                      final isActive = device['is_active'] == true;
                      final lastSyncAt = device['last_sync_at'] != null
                          ? DateTime.parse(device['last_sync_at'] as String)
                          : null;

                      return AppCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getDeviceIcon(
                                      device['device_type'] as String?),
                                  size: 32,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        device['device_name'] as String? ??
                                            loc.unknownDevice,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        device['device_type'] as String? ??
                                            'unknown',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isActive ? loc.active : loc.inactive,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color:
                                          isActive ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (lastSyncAt != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.sync,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${loc.lastSync}: ${dateFormatter.format(lastSyncAt)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: _isOffline
                                      ? null
                                      : () => _revokeDevice(
                                          device['id'].toString()),
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18),
                                  label: Text(loc.revoke),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final isOnline = await _syncService.isOnline();
          if (!isOnline) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.onlineRequired),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DevicePairingScreen(),
            ),
          );
          if (result == true && mounted) {
            _loadDevices();
          }
        },
        icon: const Icon(Icons.add),
        label: Text(loc.pairDevice),
      ),
    );
  }

  IconData _getDeviceIcon(String? deviceType) {
    switch (deviceType) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      case 'web':
        return Icons.web;
      case 'windows':
        return Icons.desktop_windows;
      case 'macos':
        return Icons.desktop_mac;
      case 'linux':
        return Icons.desktop_windows;
      default:
        return Icons.device_unknown;
    }
  }
}
