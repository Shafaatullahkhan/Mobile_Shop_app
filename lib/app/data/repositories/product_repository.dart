import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/connectivity_service.dart';
import '../services/offline_storage_service.dart';
import '../local/models/product_local.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;
  final OfflineStorageService _offlineService;

  ProductRepository({
    required ConnectivityService connectivityService,
    required OfflineStorageService offlineService,
  })  : _connectivityService = connectivityService,
        _offlineService = offlineService;

  // Get all products with offline support
  Stream<List<ProductLocal>> getAllProducts() {
    if (_connectivityService.isConnected) {
      // Online: Return Firestore stream with sync to local
      return _firestore
          .collection('products')
          .snapshots()
          .asyncMap((snapshot) async {
        final products = snapshot.docs.map((doc) {
          return ProductLocal.fromRemote(doc.data(), doc.id);
        }).toList();
        
        // Save to local storage
        await _offlineService.saveProducts(products);
        await _offlineService.updateLastSyncTime();
        
        return products;
      });
    } else {
      // Offline: Return from local storage
      return Stream.value(_offlineService.getProducts());
    }
  }

  // Get single product with offline support
  Future<ProductLocal?> getProduct(String productId) async {
    try {
      if (_connectivityService.isConnected) {
        // Try online first
        final doc = await _firestore.collection('products').doc(productId).get();
        if (doc.exists) {
          final product = ProductLocal.fromRemote(doc.data()!, doc.id);
          await _offlineService.saveProduct(product);
          return product;
        }
      }
      
      // Fallback to offline
      return _offlineService.getProduct(productId);
    } catch (e) {
      debugPrint('Error getting product: $e');
      return _offlineService.getProduct(productId);
    }
  }

  // Search products with offline support
  Future<List<ProductLocal>> searchProducts(String query) async {
    try {
      if (_connectivityService.isConnected) {
        // Online search
        final snapshot = await _firestore
            .collection('products')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
        
        final products = snapshot.docs.map((doc) {
          return ProductLocal.fromRemote(doc.data(), doc.id);
        }).toList();
        
        return products;
      } else {
        // Offline search
        final allProducts = _offlineService.getProducts();
        return allProducts.where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.brand.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }

  // Get products by category with offline support
  Future<List<ProductLocal>> getProductsByCategory(String category) async {
    try {
      if (_connectivityService.isConnected) {
        final snapshot = await _firestore
            .collection('products')
            .where('category', isEqualTo: category)
            .get();
        
        final products = snapshot.docs.map((doc) {
          return ProductLocal.fromRemote(doc.data(), doc.id);
        }).toList();
        
        return products;
      } else {
        final allProducts = _offlineService.getProducts();
        return allProducts.where((product) => product.category == category).toList();
      }
    } catch (e) {
      debugPrint('Error getting products by category: $e');
      return [];
    }
  }

  // Sync products from remote to local
  Future<void> syncProducts() async {
    if (!_connectivityService.isConnected) {
      debugPrint('Cannot sync: No internet connection');
      return;
    }

    try {
      debugPrint('Starting product sync...');
      final snapshot = await _firestore.collection('products').get();
      
      final products = snapshot.docs.map((doc) {
        return ProductLocal.fromRemote(doc.data(), doc.id);
      }).toList();
      
      await _offlineService.saveProducts(products);
      await _offlineService.updateLastSyncTime();
      
      debugPrint('Product sync completed: ${products.length} products');
    } catch (e) {
      debugPrint('Error syncing products: $e');
    }
  }

  // Check if sync is needed
  bool needsSync() {
    return _offlineService.needsSync();
  }

  // Get cached products count
  int getCachedProductsCount() {
    return _offlineService.getProducts().length;
  }
}
