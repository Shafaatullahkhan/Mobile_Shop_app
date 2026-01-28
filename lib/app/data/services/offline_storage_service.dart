import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../local/models/product_local.dart';
import '../local/models/order_local.dart';
import '../local/models/user_local.dart';
import '../local/models/favorite_local.dart';
import '../local/hive_adapters.dart';

class OfflineStorageService {
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _userIdKey = 'current_user_id';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _cartItemsKey = 'cart_items';

  // SharedPreferences instance
  SharedPreferences? _prefs;

  // Initialize the offline storage
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await HiveAdapters.registerAdapters();
      await HiveAdapters.openBoxes();
      debugPrint('Offline storage initialized successfully');
    } catch (e) {
      debugPrint('Error initializing offline storage: $e');
      rethrow;
    }
  }

  // Close all storage boxes
  Future<void> dispose() async {
    try {
      await HiveAdapters.closeBoxes();
      debugPrint('Offline storage closed successfully');
    } catch (e) {
      debugPrint('Error closing offline storage: $e');
    }
  }

  // ========== USER DATA ==========
  
  Future<void> saveCurrentUser(UserLocal user) async {
    try {
      await HiveAdapters.usersBox.put(user.id, user);
      await _prefs?.setString(_userIdKey, user.id);
      debugPrint('User saved locally: ${user.id}');
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  UserLocal? getCurrentUser() {
    try {
      final userId = _prefs?.getString(_userIdKey);
      if (userId != null) {
        return HiveAdapters.usersBox.get(userId);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  Future<void> clearCurrentUser() async {
    try {
      final userId = _prefs?.getString(_userIdKey);
      if (userId != null) {
        await HiveAdapters.usersBox.delete(userId);
      }
      await _prefs?.remove(_userIdKey);
      debugPrint('Current user cleared');
    } catch (e) {
      debugPrint('Error clearing current user: $e');
    }
  }

  // ========== PRODUCT DATA ==========

  Future<void> saveProducts(List<ProductLocal> products) async {
    try {
      final box = HiveAdapters.productsBox;
      for (final product in products) {
        await box.put(product.id, product);
      }
      debugPrint('Saved ${products.length} products locally');
    } catch (e) {
      debugPrint('Error saving products: $e');
    }
  }

  List<ProductLocal> getProducts() {
    try {
      return HiveAdapters.productsBox.values.toList();
    } catch (e) {
      debugPrint('Error getting products: $e');
      return [];
    }
  }

  ProductLocal? getProduct(String productId) {
    try {
      return HiveAdapters.productsBox.get(productId);
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  Future<void> saveProduct(ProductLocal product) async {
    try {
      await HiveAdapters.productsBox.put(product.id, product);
      debugPrint('Product saved locally: ${product.id}');
    } catch (e) {
      debugPrint('Error saving product: $e');
    }
  }

  // ========== ORDER DATA ==========

  Future<void> saveOrders(List<OrderLocal> orders) async {
    try {
      final box = HiveAdapters.ordersBox;
      for (final order in orders) {
        await box.put(order.id, order);
      }
      debugPrint('Saved ${orders.length} orders locally');
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  List<OrderLocal> getOrders() {
    try {
      return HiveAdapters.ordersBox.values.toList();
    } catch (e) {
      debugPrint('Error getting orders: $e');
      return [];
    }
  }

  List<OrderLocal> getUserOrders(String userId) {
    try {
      return HiveAdapters.ordersBox.values
          .where((order) => order.userId == userId)
          .toList();
    } catch (e) {
      debugPrint('Error getting user orders: $e');
      return [];
    }
  }

  Future<void> saveOrder(OrderLocal order) async {
    try {
      await HiveAdapters.ordersBox.put(order.id, order);
      debugPrint('Order saved locally: ${order.id}');
    } catch (e) {
      debugPrint('Error saving order: $e');
    }
  }

  // ========== FAVORITES DATA ==========

  Future<void> saveFavorite(FavoriteLocal favorite) async {
    try {
      await HiveAdapters.favoritesBox.put('${favorite.userId}_${favorite.productId}', favorite);
      debugPrint('Favorite saved locally: ${favorite.productId}');
    } catch (e) {
      debugPrint('Error saving favorite: $e');
    }
  }

  Future<void> removeFavorite(String userId, String productId) async {
    try {
      await HiveAdapters.favoritesBox.delete('${userId}_${productId}');
      debugPrint('Favorite removed locally: $productId');
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }

  List<String> getUserFavoriteProductIds(String userId) {
    try {
      return HiveAdapters.favoritesBox.values
          .where((fav) => fav.userId == userId)
          .map((fav) => fav.productId)
          .toList();
    } catch (e) {
      debugPrint('Error getting user favorites: $e');
      return [];
    }
  }

  List<ProductLocal> getUserFavoriteProducts(String userId) {
    try {
      final favoriteIds = getUserFavoriteProductIds(userId);
      return HiveAdapters.productsBox.values
          .where((product) => favoriteIds.contains(product.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting user favorite products: $e');
      return [];
    }
  }

  bool isProductFavorite(String userId, String productId) {
    try {
      return HiveAdapters.favoritesBox.containsKey('${userId}_${productId}');
    } catch (e) {
      debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  // ========== SYNC MANAGEMENT ==========

  Future<void> updateLastSyncTime() async {
    try {
      await _prefs?.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('Last sync time updated');
    } catch (e) {
      debugPrint('Error updating last sync time: $e');
    }
  }

  DateTime? getLastSyncTime() {
    try {
      final timestamp = _prefs?.getInt(_lastSyncKey);
      return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
    } catch (e) {
      debugPrint('Error getting last sync time: $e');
      return null;
    }
  }

  bool needsSync({Duration maxAge = const Duration(hours: 1)}) {
    try {
      final lastSync = getLastSyncTime();
      if (lastSync == null) return true;
      return DateTime.now().difference(lastSync) > maxAge;
    } catch (e) {
      debugPrint('Error checking sync need: $e');
      return true;
    }
  }

  // ========== CART MANAGEMENT ==========

  Future<void> saveCartItems(List<Map<String, dynamic>> cartItems) async {
    try {
      // Convert to JSON string for storage
      final cartJson = cartItems.map((item) => item.toString()).toList();
      await _prefs?.setStringList(_cartItemsKey, cartJson);
      debugPrint('Cart items saved locally: ${cartItems.length} items');
    } catch (e) {
      debugPrint('Error saving cart items: $e');
    }
  }

  List<Map<String, dynamic>> getCartItems() {
    try {
      final cartJson = _prefs?.getStringList(_cartItemsKey) ?? [];
      // For now, return empty list - cart items will be handled differently
      debugPrint('Retrieved ${cartJson.length} cart items from storage');
      return [];
    } catch (e) {
      debugPrint('Error getting cart items: $e');
      return [];
    }
  }

  Future<void> clearCartItems() async {
    try {
      await _prefs?.remove(_cartItemsKey);
      debugPrint('Cart items cleared');
    } catch (e) {
      debugPrint('Error clearing cart items: $e');
    }
  }

  // ========== APP STATE ==========

  bool get isFirstLaunch {
    try {
      return _prefs?.getBool(_isFirstLaunchKey) ?? true;
    } catch (e) {
      debugPrint('Error checking first launch: $e');
      return true;
    }
  }

  Future<void> setFirstLaunchCompleted() async {
    try {
      await _prefs?.setBool(_isFirstLaunchKey, false);
      debugPrint('First launch completed');
    } catch (e) {
      debugPrint('Error setting first launch: $e');
    }
  }

  // ========== STORAGE MANAGEMENT ==========

  Future<void> clearAllData() async {
    try {
      await HiveAdapters.productsBox.clear();
      await HiveAdapters.ordersBox.clear();
      await HiveAdapters.usersBox.clear();
      await HiveAdapters.favoritesBox.clear();
      await _prefs?.clear();
      debugPrint('All offline data cleared');
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    }
  }

  // Get storage statistics
  Map<String, dynamic> getStorageStats() {
    return {
      'products': HiveAdapters.productsBox.length,
      'orders': HiveAdapters.ordersBox.length,
      'users': HiveAdapters.usersBox.length,
      'favorites': HiveAdapters.favoritesBox.length,
      'lastSync': getLastSyncTime()?.toIso8601String(),
      'needsSync': needsSync(),
    };
  }

  // Getters for boxes
  static Box<ProductLocal> get productsBox => Hive.box<ProductLocal>('products');
  static Box<OrderLocal> get ordersBox => Hive.box<OrderLocal>('orders');
  static Box<UserLocal> get usersBox => Hive.box<UserLocal>('users');
  static Box<FavoriteLocal> get favoritesBox => Hive.box<FavoriteLocal>('favorites');
}

// Extension to add getters to OfflineStorageService
extension OfflineStorageServiceExtension on OfflineStorageService {
  Box<FavoriteLocal> get favoritesBox => HiveAdapters.favoritesBox;
}
