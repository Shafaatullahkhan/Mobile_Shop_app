import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/connectivity_service.dart';
import '../services/offline_storage_service.dart';
import '../local/models/order_local.dart';
import '../local/models/product_local.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConnectivityService _connectivityService;
  final OfflineStorageService _offlineService;

  OrderRepository({
    required ConnectivityService connectivityService,
    required OfflineStorageService offlineService,
  })  : _connectivityService = connectivityService,
        _offlineService = offlineService;

  // Get all orders (for admin) with offline support
  Stream<List<OrderLocal>> getAllOrders() {
    if (_connectivityService.isConnected) {
      return _firestore
          .collection('orders')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final orders = <OrderLocal>[];
        
        for (final doc in snapshot.docs) {
          try {
            final orderData = doc.data();
            final items = await _getOrderItems(orderData);
            final order = OrderLocal.fromRemote(orderData, doc.id, items);
            orders.add(order);
          } catch (e) {
            debugPrint('Error parsing order ${doc.id}: $e');
          }
        }
        
        // Save to local storage
        await _offlineService.saveOrders(orders);
        
        return orders;
      });
    } else {
      return Stream.value(_offlineService.getOrders());
    }
  }

  // Get user orders with offline support
  Stream<List<OrderLocal>> getUserOrders(String userId) {
    if (_connectivityService.isConnected) {
      return _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
        final orders = <OrderLocal>[];
        
        for (final doc in snapshot.docs) {
          try {
            final orderData = doc.data();
            final items = await _getOrderItems(orderData);
            final order = OrderLocal.fromRemote(orderData, doc.id, items);
            orders.add(order);
          } catch (e) {
            debugPrint('Error parsing order ${doc.id}: $e');
          }
        }
        
        return orders;
      });
    } else {
      return Stream.value(_offlineService.getUserOrders(userId));
    }
  }

  // Create order with offline support
  Future<String> createOrder({
    required String userId,
    required String userName,
    required List<ProductLocal> items,
    required double totalAmount,
    required String status,
    DateTime? expectedDeliveryTime,
  }) async {
    try {
      final orderData = {
        'userId': userId,
        'userName': userName,
        'items': items.map((item) => item.toRemote()).toList(),
        'totalAmount': totalAmount,
        'status': status,
        'timestamp': DateTime.now(),
        'expectedDeliveryTime': expectedDeliveryTime,
      };

      if (_connectivityService.isConnected) {
        // Create online
        final docRef = await _firestore.collection('orders').add(orderData);
        final order = OrderLocal(
          id: docRef.id,
          userId: userId,
          userName: userName,
          items: items,
          totalAmount: totalAmount,
          status: status,
          timestamp: DateTime.now(),
          expectedDeliveryTime: expectedDeliveryTime,
          lastSynced: DateTime.now(),
          isPendingSync: false,
        );
        
        await _offlineService.saveOrder(order);
        debugPrint('Order created online: ${docRef.id}');
        return docRef.id;
      } else {
        // Create offline (pending sync)
        final orderId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
        final order = OrderLocal(
          id: orderId,
          userId: userId,
          userName: userName,
          items: items,
          totalAmount: totalAmount,
          status: status,
          timestamp: DateTime.now(),
          expectedDeliveryTime: expectedDeliveryTime,
          lastSynced: DateTime.now(),
          isPendingSync: true,
        );
        
        await _offlineService.saveOrder(order);
        debugPrint('Order created offline: $orderId');
        return orderId;
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      rethrow;
    }
  }

  // Update order status with offline support
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      if (_connectivityService.isConnected) {
        await _firestore.collection('orders').doc(orderId).update({
          'status': status,
        });
        
        // Update local
        final localOrder = _offlineService.getOrders().firstWhere((order) => order.id == orderId);
        final updatedOrder = localOrder.copyWith(status: status, lastSynced: DateTime.now());
        await _offlineService.saveOrder(updatedOrder);
      } else {
        // Mark for sync when online
        final localOrder = _offlineService.getOrders().firstWhere((order) => order.id == orderId);
        final updatedOrder = localOrder.copyWith(
          status: status,
          isPendingSync: true,
          lastSynced: DateTime.now(),
        );
        await _offlineService.saveOrder(updatedOrder);
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }

  // Sync pending orders
  Future<void> syncPendingOrders() async {
    if (!_connectivityService.isConnected) {
      debugPrint('Cannot sync orders: No internet connection');
      return;
    }

    try {
      final pendingOrders = _offlineService.getOrders()
          .where((order) => order.isPendingSync)
          .toList();

      for (final order in pendingOrders) {
        try {
          if (order.id.startsWith('offline_')) {
            // New order to upload
            final docRef = await _firestore.collection('orders').add(order.toRemote());
            final syncedOrder = order.copyWith(
              id: docRef.id,
              isPendingSync: false,
              lastSynced: DateTime.now(),
            );
            await _offlineService.saveOrder(syncedOrder);
            debugPrint('Synced new order: ${docRef.id}');
          } else {
            // Existing order to update
            await _firestore.collection('orders').doc(order.id).update(order.toRemote());
            final syncedOrder = order.copyWith(
              isPendingSync: false,
              lastSynced: DateTime.now(),
            );
            await _offlineService.saveOrder(syncedOrder);
            debugPrint('Synced updated order: ${order.id}');
          }
        } catch (e) {
          debugPrint('Error syncing order ${order.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error syncing pending orders: $e');
    }
  }

  // Helper method to get order items
  Future<List<ProductLocal>> _getOrderItems(Map<String, dynamic> orderData) async {
    final itemsData = orderData['items'] as List<dynamic>? ?? [];
    final items = <ProductLocal>[];
    
    for (final itemData in itemsData) {
      if (itemData is Map<String, dynamic>) {
        final productId = itemData['id'] as String?;
        if (productId != null) {
          final product = _offlineService.getProduct(productId);
          if (product != null) {
            items.add(product);
          }
        }
      }
    }
    
    return items;
  }
}
