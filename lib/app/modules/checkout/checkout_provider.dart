import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/database_service.dart';
import '../../data/models/order_model.dart' as model;
import '../cart/cart_provider.dart';

class CheckoutProvider extends ChangeNotifier {
  final CartProvider cartProvider;
  final DatabaseService _databaseService = DatabaseService();
  bool _isProcessing = false;

  CheckoutProvider({required this.cartProvider});

  bool get isProcessing => _isProcessing;

  Future<void> processPayment(BuildContext context) async {
    if (cartProvider.cartItems.isEmpty) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in to place an order")),
      );
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final order = model.Order(
        id: '',
        userId: user.uid,
        items: List.from(cartProvider.cartItems),
        totalAmount: cartProvider.totalPrice,
        status: 'pending',
        timestamp: DateTime.now(),
      );

      await _databaseService.placeOrder(order);
      
      // Notify Admin
      final userName = user.displayName ?? user.email ?? "Unknown User";
      await _databaseService.addAdminNotification(
        "New order placed by $userName for \$${cartProvider.totalPrice.toStringAsFixed(2)}",
        "order",
      );

      cartProvider.clearCart();
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order placed successfully! Admin has been notified.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment failed: $e")),
        );
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
