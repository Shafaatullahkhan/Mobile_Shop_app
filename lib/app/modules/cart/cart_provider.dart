import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final List<Product> _cartItems = [];
  List<Product> get cartItems => _cartItems;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  double get totalPrice => _cartItems.fold(0, (sum, item) => sum + item.price);
  int get itemCount => _cartItems.length;

  void addToCart(Product product, [BuildContext? context]) {
    _cartItems.add(product);
    notifyListeners();
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${product.name} added to cart"),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF246BFD),
        ),
      );
    }
  }

  void removeFromCart(Product product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<bool> placeOrder(BuildContext context) async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
      return false;
    }

    User? user = _auth.currentUser;
    if (user == null) {
      Navigator.of(context).pushNamed('/auth');
      return false;
    }

    try {
      _isLoading = true;
      notifyListeners();
      
      final orderData = {
        'userId': user.uid,
        'items': _cartItems.map((p) => p.toMap()).toList(),
        'totalPrice': totalPrice,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('orders').add(orderData);
      
      _cartItems.clear();
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
