import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart' as model;

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
    } catch (e) {
      debugPrint("Error adding product: $e");
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
    } catch (e) {
      debugPrint("Error deleting product: $e");
    }
  }

  Stream<List<Product>> get products {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    }).handleError((error) {
      debugPrint("Error fetching products: $error");
      return <Product>[];
    });
  }

  Future<void> placeOrder(model.Order order) async {
    try {
      await _firestore.collection('orders').add(order.toMap());
    } catch (e) {
      debugPrint("Error placing order: $e");
      rethrow;
    }
  }

  Stream<List<model.Order>> getOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return model.Order.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // Admin Methods
  Stream<List<model.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return model.Order.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'status': status});
    } catch (e) {
      debugPrint("Error updating order status: $e");
    }
  }

  Future<void> updateOrderDeliveryTime(String orderId, String time) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({'expectedDeliveryTime': time});
    } catch (e) {
      debugPrint("Error updating delivery time: $e");
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update(product.toMap());
    } catch (e) {
      debugPrint("Error updating product: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // --- Notification Methods ---
  Future<void> addAdminNotification(String message, String type) async {
    try {
      await _firestore.collection('admin_notifications').add({
        'message': message,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      debugPrint("Error adding notification: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> getAdminNotifications() {
    return _firestore
        .collection('admin_notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  Future<void> markNotificationRead(String id) async {
    await _firestore.collection('admin_notifications').doc(id).update({'read': true});
  }
}
