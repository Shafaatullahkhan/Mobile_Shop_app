import 'package:flutter/material.dart';
import '../../data/services/database_service.dart';
import '../../data/models/product_model.dart';
import '../../data/models/order_model.dart' as model;
import 'dart:async';

class AdminProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Product> _products = [];
  List<Product> get products => _products;
  
  List<model.Order> _orders = [];
  List<model.Order> get orders => _orders;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> get users => _users;

  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => n['read'] == false).length;

  StreamSubscription? _productSub;
  StreamSubscription? _orderSub;
  StreamSubscription? _userSub;
  StreamSubscription? _notificationSub;

  AdminProvider() {
    _initStreams();
  }

  void _initStreams() {
    _productSub = _databaseService.products.listen((productList) {
      _products = productList;
      notifyListeners();
    });

    _orderSub = _databaseService.getAllOrders().listen((orderList) {
      _orders = orderList;
      notifyListeners();
    });

    _userSub = _databaseService.getUsers().listen((userList) {
      _users = userList;
      notifyListeners();
    });

    _notificationSub = _databaseService.getAdminNotifications().listen((notifs) {
      _notifications = notifs;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _productSub?.cancel();
    _orderSub?.cancel();
    _userSub?.cancel();
    _notificationSub?.cancel();
    super.dispose();
  }

  Future<void> markNotificationRead(String id) async {
    await _databaseService.markNotificationRead(id);
  }

  Future<void> clearAllNotifications() async {
    for (var n in _notifications) {
      await _databaseService.markNotificationRead(n['id']);
    }
  }

  Future<void> addProduct(Product product) async {
    await _databaseService.addProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _databaseService.updateProduct(product);
  }

  Future<void> deleteProduct(String id) async {
    await _databaseService.deleteProduct(id);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _databaseService.updateOrderStatus(orderId, status);
  }

  Future<void> updateOrderDeliveryTime(String orderId, String time) async {
    await _databaseService.updateOrderDeliveryTime(orderId, time);
  }
}
