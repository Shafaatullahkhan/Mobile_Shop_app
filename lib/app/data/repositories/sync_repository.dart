import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/offline_storage_service.dart';
import 'product_repository.dart';
import 'order_repository.dart';
import 'favorite_repository.dart';

class SyncRepository {
  final ConnectivityService _connectivityService;
  final OfflineStorageService _offlineService;
  final ProductRepository _productRepository;
  final OrderRepository _orderRepository;
  final FavoriteRepository _favoriteRepository;

  SyncRepository({
    required ConnectivityService connectivityService,
    required OfflineStorageService offlineService,
    required ProductRepository productRepository,
    required OrderRepository orderRepository,
    required FavoriteRepository favoriteRepository,
  })  : _connectivityService = connectivityService,
        _offlineService = offlineService,
        _productRepository = productRepository,
        _orderRepository = orderRepository,
        _favoriteRepository = favoriteRepository;

  // Full sync process
  Future<SyncResult> performFullSync({String? userId}) async {
    if (!_connectivityService.isConnected) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        syncedItems: 0,
        failedItems: 0,
      );
    }

    debugPrint('Starting full sync process...');
    int syncedItems = 0;
    int failedItems = 0;
    final List<String> errors = [];

    try {
      // 1. Sync products
      try {
        await _productRepository.syncProducts();
        syncedItems++;
        debugPrint('Products synced successfully');
      } catch (e) {
        failedItems++;
        errors.add('Products sync failed: $e');
        debugPrint('Products sync failed: $e');
      }

      // 2. Sync pending orders
      try {
        await _orderRepository.syncPendingOrders();
        syncedItems++;
        debugPrint('Orders synced successfully');
      } catch (e) {
        failedItems++;
        errors.add('Orders sync failed: $e');
        debugPrint('Orders sync failed: $e');
      }

      // 3. Sync favorites (if user is logged in)
      if (userId != null) {
        try {
          await _favoriteRepository.syncPendingFavorites(userId);
          syncedItems++;
          debugPrint('Favorites synced successfully');
        } catch (e) {
          failedItems++;
          errors.add('Favorites sync failed: $e');
          debugPrint('Favorites sync failed: $e');
        }
      }

      await _offlineService.updateLastSyncTime();

      final success = failedItems == 0;
      final message = success 
          ? 'Sync completed successfully' 
          : 'Sync completed with ${failedItems} errors';

      debugPrint('Full sync completed: $syncedItems synced, $failedItems failed');

      return SyncResult(
        success: success,
        message: message,
        syncedItems: syncedItems,
        failedItems: failedItems,
        errors: errors,
      );
    } catch (e) {
      debugPrint('Full sync failed: $e');
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        syncedItems: syncedItems,
        failedItems: failedItems + 1,
        errors: [e.toString()],
      );
    }
  }

  // Auto sync (runs periodically)
  Future<void> autoSync({String? userId}) async {
    if (!_connectivityService.isConnected) {
      debugPrint('Auto sync skipped: No internet connection');
      return;
    }

    if (!_offlineService.needsSync()) {
      debugPrint('Auto sync skipped: Sync not needed');
      return;
    }

    debugPrint('Starting auto sync...');
    await performFullSync(userId: userId);
  }

  // Check sync status
  SyncStatus getSyncStatus() {
    final lastSync = _offlineService.getLastSyncTime();
    final needsSync = _offlineService.needsSync();
    final isConnected = _connectivityService.isConnected;

    return SyncStatus(
      lastSyncTime: lastSync,
      needsSync: needsSync,
      isConnected: isConnected,
      storageStats: _offlineService.getStorageStats(),
    );
  }

  // Force sync specific data type
  Future<SyncResult> syncProducts() async {
    try {
      await _productRepository.syncProducts();
      return SyncResult(
        success: true,
        message: 'Products synced successfully',
        syncedItems: 1,
        failedItems: 0,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Products sync failed: $e',
        syncedItems: 0,
        failedItems: 1,
      );
    }
  }

  Future<SyncResult> syncOrders() async {
    try {
      await _orderRepository.syncPendingOrders();
      return SyncResult(
        success: true,
        message: 'Orders synced successfully',
        syncedItems: 1,
        failedItems: 0,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Orders sync failed: $e',
        syncedItems: 0,
        failedItems: 1,
      );
    }
  }

  Future<SyncResult> syncFavorites(String userId) async {
    try {
      await _favoriteRepository.syncPendingFavorites(userId);
      return SyncResult(
        success: true,
        message: 'Favorites synced successfully',
        syncedItems: 1,
        failedItems: 0,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Favorites sync failed: $e',
        syncedItems: 0,
        failedItems: 1,
      );
    }
  }

  // Clear all local data
  Future<void> clearAllData() async {
    await _offlineService.clearAllData();
    debugPrint('All local data cleared');
  }

  // Get sync statistics
  Map<String, dynamic> getSyncStatistics() {
    final status = getSyncStatus();
    return {
      'lastSync': status.lastSyncTime?.toIso8601String(),
      'needsSync': status.needsSync,
      'isConnected': status.isConnected,
      'storageStats': status.storageStats,
    };
  }
}

// Sync result model
class SyncResult {
  final bool success;
  final String message;
  final int syncedItems;
  final int failedItems;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedItems,
    required this.failedItems,
    this.errors = const [],
  });

  @override
  String toString() {
    return 'SyncResult(success: $success, message: $message, synced: $syncedItems, failed: $failedItems)';
  }
}

// Sync status model
class SyncStatus {
  final DateTime? lastSyncTime;
  final bool needsSync;
  final bool isConnected;
  final Map<String, dynamic> storageStats;

  SyncStatus({
    this.lastSyncTime,
    required this.needsSync,
    required this.isConnected,
    required this.storageStats,
  });

  Duration? get timeSinceLastSync {
    if (lastSyncTime == null) return null;
    return DateTime.now().difference(lastSyncTime!);
  }

  String get lastSyncText {
    if (lastSyncTime == null) return 'Never';
    
    final diff = timeSinceLastSync!;
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }
}
