import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/connectivity_service.dart';
import '../services/offline_storage_service.dart';
import '../local/models/favorite_local.dart';
import '../local/models/product_local.dart';

class FavoriteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;
  final OfflineStorageService _offlineService;

  FavoriteRepository({
    required ConnectivityService connectivityService,
    required OfflineStorageService offlineService,
  })  : _connectivityService = connectivityService,
        _offlineService = offlineService;

  // Get user favorites with offline support
  Stream<List<ProductLocal>> getUserFavorites(String userId) {
    if (_connectivityService.isConnected) {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .snapshots()
          .asyncMap((snapshot) async {
        final favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
        
        // Update local favorites
        for (final productId in favoriteIds) {
          final favorite = FavoriteLocal(
            userId: userId,
            productId: productId,
            addedAt: DateTime.now(),
            lastSynced: DateTime.now(),
            isPendingSync: false,
          );
          await _offlineService.saveFavorite(favorite);
        }
        
        // Get products from local storage
        return _offlineService.getUserFavoriteProducts(userId);
      });
    } else {
      return Stream.value(_offlineService.getUserFavoriteProducts(userId));
    }
  }

  // Add to favorites with offline support
  Future<void> addToFavorites(String userId, String productId) async {
    try {
      if (_connectivityService.isConnected) {
        // Add online
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(productId)
            .set({'addedAt': DateTime.now()});
        
        // Add to local
        final favorite = FavoriteLocal(
          userId: userId,
          productId: productId,
          addedAt: DateTime.now(),
          lastSynced: DateTime.now(),
          isPendingSync: false,
        );
        await _offlineService.saveFavorite(favorite);
        debugPrint('Added to favorites online: $productId');
      } else {
        // Add offline (pending sync)
        final favorite = FavoriteLocal(
          userId: userId,
          productId: productId,
          addedAt: DateTime.now(),
          lastSynced: DateTime.now(),
          isPendingSync: true,
        );
        await _offlineService.saveFavorite(favorite);
        debugPrint('Added to favorites offline: $productId');
      }
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      rethrow;
    }
  }

  // Remove from favorites with offline support
  Future<void> removeFromFavorites(String userId, String productId) async {
    try {
      if (_connectivityService.isConnected) {
        // Remove online
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .doc(productId)
            .delete();
        
        // Remove from local
        await _offlineService.removeFavorite(userId, productId);
        debugPrint('Removed from favorites online: $productId');
      } else {
        // Remove offline (pending sync)
        await _offlineService.removeFavorite(userId, productId);
        debugPrint('Removed from favorites offline: $productId');
      }
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
    }
  }

  // Check if product is favorited
  bool isProductFavorited(String userId, String productId) {
    return _offlineService.isProductFavorite(userId, productId);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String userId, String productId) async {
    if (isProductFavorited(userId, productId)) {
      await removeFromFavorites(userId, productId);
    } else {
      await addToFavorites(userId, productId);
    }
  }

  // Get favorite product IDs
  List<String> getFavoriteProductIds(String userId) {
    return _offlineService.getUserFavoriteProductIds(userId);
  }

  // Sync pending favorites
  Future<void> syncPendingFavorites(String userId) async {
    if (!_connectivityService.isConnected) {
      debugPrint('Cannot sync favorites: No internet connection');
      return;
    }

    try {
      // Get all local favorites
      final allFavorites = _offlineService.favoritesBox.values
          .where((fav) => fav.userId == userId)
          .toList();

      for (final favorite in allFavorites) {
        if (favorite.isPendingSync) {
          try {
            // This is a new favorite to sync
            await _firestore
                .collection('users')
                .doc(userId)
                .collection('favorites')
                .doc(favorite.productId)
                .set({'addedAt': favorite.addedAt});

            // Update local favorite to mark as synced
            final syncedFavorite = favorite.copyWith(
              isPendingSync: false,
              lastSynced: DateTime.now(),
            );
            await _offlineService.saveFavorite(syncedFavorite);
            
            debugPrint('Synced favorite: ${favorite.productId}');
          } catch (e) {
            debugPrint('Error syncing favorite ${favorite.productId}: $e');
          }
        }
      }

      // Also sync any favorites that might be missing from remote
      final remoteSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      final remoteIds = remoteSnapshot.docs.map((doc) => doc.id).toSet();
      final localIds = allFavorites.map((fav) => fav.productId).toSet();

      // Add any remote favorites that are missing locally
      for (final remoteId in remoteIds) {
        if (!localIds.contains(remoteId)) {
          final favorite = FavoriteLocal(
            userId: userId,
            productId: remoteId,
            addedAt: DateTime.now(),
            lastSynced: DateTime.now(),
            isPendingSync: false,
          );
          await _offlineService.saveFavorite(favorite);
        }
      }

      debugPrint('Favorites sync completed for user: $userId');
    } catch (e) {
      debugPrint('Error syncing favorites: $e');
    }
  }

  // Clear all favorites for user
  Future<void> clearAllFavorites(String userId) async {
    try {
      if (_connectivityService.isConnected) {
        // Clear online
        final favorites = await _firestore
            .collection('users')
            .doc(userId)
            .collection('favorites')
            .get();

        for (final doc in favorites.docs) {
          await doc.reference.delete();
        }
      }

      // Clear local
      final allFavorites = _offlineService.favoritesBox.values
          .where((fav) => fav.userId == userId)
          .toList();

      for (final favorite in allFavorites) {
        await _offlineService.removeFavorite(favorite.userId, favorite.productId);
      }

      debugPrint('Cleared all favorites for user: $userId');
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }

  // Get favorites count
  int getFavoritesCount(String userId) {
    return _offlineService.getUserFavoriteProductIds(userId).length;
  }
}
