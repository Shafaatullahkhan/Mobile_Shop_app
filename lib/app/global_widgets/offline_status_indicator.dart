import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../data/services/connectivity_service.dart';
import '../data/repositories/sync_repository.dart';
import '../modules/auth/auth_provider.dart' as app;
import '../data/app_colors.dart';

class OfflineStatusIndicator extends StatelessWidget {
  const OfflineStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, _) {
        if (connectivityService.isConnected) {
          return Consumer<SyncRepository>(
            builder: (context, syncRepository, _) {
              final syncStatus = syncRepository.getSyncStatus();
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: syncStatus.needsSync 
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: syncStatus.needsSync 
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.green.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_done,
                      size: 14,
                      color: syncStatus.needsSync ? Colors.orange : Colors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      syncStatus.needsSync ? 'Sync needed' : 'Online',
                      style: TextStyle(
                        color: syncStatus.needsSync ? Colors.orange : Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off,
                  size: 14,
                  color: Colors.red,
                ),
                SizedBox(width: 6),
                Text(
                  'Offline',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, _) {
        if (!connectivityService.isConnected) {
          return const SizedBox.shrink();
        }

        return Consumer<SyncRepository>(
          builder: (context, syncRepository, _) {
            final syncStatus = syncRepository.getSyncStatus();
            
            return PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: syncStatus.needsSync 
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sync,
                  size: 20,
                  color: syncStatus.needsSync ? Colors.orange : Colors.green,
                ),
              ),
              onSelected: (value) async {
                if (value == 'sync_all') {
                  await _performSync(context, syncRepository);
                } else if (value == 'sync_products') {
                  await _performProductsSync(context, syncRepository);
                } else if (value == 'sync_status') {
                  _showSyncStatus(context, syncRepository);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'sync_all',
                  child: Row(
                    children: [
                      Icon(Icons.sync, size: 20),
                      SizedBox(width: 8),
                      Text('Sync All'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sync_products',
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Sync Products'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'sync_status',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 8),
                      Text('Sync Status'),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _performSync(BuildContext context, SyncRepository syncRepository) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: AppColors.surface,
        content: Row(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(width: 20),
            Text("Syncing data...", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    try {
      // Get current user ID if available
      final authProvider = context.read<app.AuthProvider>();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      
      final result = await syncRepository.performFullSync(userId: userId);
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show result
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            result.success ? "Sync Complete" : "Sync Failed",
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.message,
                style: const TextStyle(color: Colors.white70),
              ),
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  "Errors:",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                ...result.errors.map((error) => Text(
                  "• $error",
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                )),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            "Sync Failed",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "An error occurred during sync: $e",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _performProductsSync(BuildContext context, SyncRepository syncRepository) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            SizedBox(width: 20),
            Text("Syncing products..."),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );

    try {
      final result = await syncRepository.syncProducts();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Products sync failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSyncStatus(BuildContext context, SyncRepository syncRepository) {
    final status = syncRepository.getSyncStatus();
    final stats = syncRepository.getSyncStatistics();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Sync Status",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow("Connection", status.isConnected ? "Online" : "Offline"),
            _buildStatusRow("Last Sync", status.lastSyncText),
            _buildStatusRow("Needs Sync", status.needsSync ? "Yes" : "No"),
            const SizedBox(height: 15),
            const Text(
              "Storage Statistics:",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (stats['storageStats'] != null) ...[
              _buildStatusRow("Products", "${stats['storageStats']['products'] ?? 0}"),
              _buildStatusRow("Orders", "${stats['storageStats']['orders'] ?? 0}"),
              _buildStatusRow("Users", "${stats['storageStats']['users'] ?? 0}"),
              _buildStatusRow("Favorites", "${stats['storageStats']['favorites'] ?? 0}"),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
