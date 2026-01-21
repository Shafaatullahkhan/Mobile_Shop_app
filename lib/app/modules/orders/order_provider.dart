import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/database_service.dart';
import '../../data/models/order_model.dart' as model;

class OrderProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<model.Order> _orders = [];
  List<model.Order> get orders => _orders;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  OrderProvider() {
    _fetchOrders();
  }

  void _fetchOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    _databaseService.getOrders(user.uid).listen((orderList) {
      _orders = orderList;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Error fetching orders: $e");
      _isLoading = false;
      notifyListeners();
    });
  }
}
