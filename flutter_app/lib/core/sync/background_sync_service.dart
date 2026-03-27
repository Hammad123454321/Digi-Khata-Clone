import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../di/injection.dart';
import 'sync_service.dart';
import 'sync_queue.dart';
import '../storage/local_storage_service.dart';

/// Background sync service for automatic synchronization
class BackgroundSyncService {
  BackgroundSyncService({
    required SyncService syncService,
    required SyncQueue syncQueue,
    required LocalStorageService localStorage,
  })  : _syncService = syncService,
        _syncQueue = syncQueue,
        _localStorage = localStorage,
        _connectivity = Connectivity();

  final SyncService _syncService;
  final SyncQueue _syncQueue;
  final LocalStorageService _localStorage;
  final Connectivity _connectivity;
  final Logger _logger = getIt<Logger>();

  Timer? _syncTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Start background sync with periodic checks
  void startBackgroundSync({
    Duration interval = const Duration(minutes: 15),
  }) {
    // Cancel existing timer if any
    stopBackgroundSync();

    // Perform initial sync
    performSync();

    // Set up periodic sync
    _syncTimer = Timer.periodic(interval, (_) {
      performSync();
    });

    // Listen to connectivity changes
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // Network is available, trigger sync
        performSync();
      }
    });
  }

  /// Stop background sync
  void stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Perform sync operation
  Future<void> performSync() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;

      // Check if online
      final isOnline = await _syncService.isOnline();
      if (!isOnline) {
        return;
      }

      // Perform full sync
      final result = await _syncService.performFullSync();

      if (result.isSuccess) {
        // Update last sync time
        await _localStorage.saveLastSyncAt(DateTime.now().toIso8601String());
      }
    } catch (e) {
      // Log error but don't throw
      _logger.e('Background sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final queueSize = await _syncQueue.getQueueSize();
    final failedCount = await _syncQueue.getDeadLetterCount();
    final lastSyncAt = _localStorage.getLastSyncAt();
    final isOnline = await _syncService.isOnline();

    return {
      'is_online': isOnline,
      'queue_size': queueSize,
      'failed_count': failedCount,
      'last_sync_at': lastSyncAt,
      'is_syncing': _isSyncing,
    };
  }
}
