import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import '../../core/sync/sync_service.dart';
import '../../core/sync/sync_queue.dart';
import '../../core/database/local_database.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/localization/app_localizations.dart';

class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  Map<String, dynamic>? _syncStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
    // Refresh every 5 seconds
    Future.delayed(const Duration(seconds: 5), _refreshStatus);
  }

  Future<void> _loadSyncStatus() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final syncService = getIt<SyncService>();
      final syncQueue = getIt<SyncQueue>();
      final localStorage = getIt<LocalStorageService>();

      final isOnline = await syncService.isOnline();
      final queueSize = await syncQueue.getQueueSize();
      final lastSyncAt = localStorage.getLastSyncAt();

      if (mounted) {
        setState(() {
          _syncStatus = {
            'is_online': isOnline,
            'queue_size': queueSize,
            'last_sync_at': lastSyncAt,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _refreshStatus() {
    if (mounted) {
      _loadSyncStatus();
      Future.delayed(const Duration(seconds: 5), _refreshStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_syncStatus == null) {
      return const SizedBox.shrink();
    }

    final loc = AppLocalizations.of(context)!;
    final isOnline = _syncStatus!['is_online'] as bool? ?? false;
    final queueSize = _syncStatus!['queue_size'] as int? ?? 0;
    final lastSyncAt = _syncStatus!['last_sync_at'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline
            ? (queueSize > 0 ? Colors.orange : Colors.green)
            : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline
                ? (queueSize > 0 ? Icons.sync : Icons.check_circle)
                : Icons.cloud_off,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            isOnline
                ? (queueSize > 0 ? '$queueSize ${loc.pending}' : loc.synced)
                : loc.offline,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
