import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'checkout_provider.dart';
import '../cart/cart_provider.dart';
import '../../data/app_colors.dart';
import '../../global_widgets/glass_container.dart';

class CheckoutView extends StatelessWidget {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("Checkout",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF1B2339)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer2<CheckoutProvider, CartProvider>(
          builder: (context, checkoutProvider, cartProvider, _) {
            return Column(
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Order Summary",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        GlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: 20,
                          child: Column(
                            children: cartProvider.cartItems.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item.name,
                                        style: const TextStyle(color: Colors.white70)),
                                    Text("\$${item.price.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildTotalSection(context, cartProvider),
                      ],
                    ),
                  ),
                ),
                _buildConfirmButton(context, checkoutProvider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTotalSection(BuildContext context, CartProvider cartProvider) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        children: [
          _buildTotalRow("Subtotal", "\$${cartProvider.totalPrice.toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Delivery", style: TextStyle(color: Colors.white60)),
              Text("Free", style: TextStyle(color: Colors.white)),
            ],
          ),
          const Divider(color: Colors.white12, height: 30),
          _buildTotalRow("Total", "\$${cartProvider.totalPrice.toStringAsFixed(2)}",
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isTotal ? Colors.white : Colors.white60,
                fontSize: isTotal ? 18 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: isTotal ? AppColors.primary : Colors.white,
                fontSize: isTotal ? 22 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context, CheckoutProvider checkoutProvider) {
    return Container(
      padding: const EdgeInsets.all(30),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: checkoutProvider.isProcessing
              ? null
              : () => checkoutProvider.processPayment(context),
          child: checkoutProvider.isProcessing
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Confirm Order",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}
