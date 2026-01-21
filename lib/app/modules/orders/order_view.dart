import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'order_provider.dart';
import '../../data/app_colors.dart';
import '../../global_widgets/glass_container.dart';
import 'package:intl/intl.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text("My Orders",
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
        child: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            if (orderProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (orderProvider.orders.isEmpty) {
              return const Center(
                child: Text("No orders found",
                    style: TextStyle(color: Colors.white54, fontSize: 18)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                final order = orderProvider.orders[index];
                return _buildOrderCard(order);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(order) {
    final dateStr = DateFormat('MMM dd, yyyy').format(order.timestamp);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #${order.id.substring(0, 8).toUpperCase()}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order.status.toUpperCase(),
                    style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (order.expectedDeliveryTime != null && order.expectedDeliveryTime!.isNotEmpty)
              Text("Expected Delivery: ${order.expectedDeliveryTime}", 
                  style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(dateStr, style: const TextStyle(color: Colors.white38)),
            const Divider(color: Colors.white12, height: 30),
            _buildDeliverabilityTracker(order.status),
            const Divider(color: Colors.white12, height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${order.items.length} Items",
                    style: const TextStyle(color: Colors.white70)),
                Text("\$${order.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverabilityTracker(String status) {
    int currentStep = 0;
    final s = status.toLowerCase();
    if (s == 'pending') currentStep = 1;
    if (s == 'processed') currentStep = 2;
    if (s == 'under way') currentStep = 3;
    if (s == 'delivered') currentStep = 4;

    return Row(
      children: [
        _buildStep(1, "Ordered", currentStep >= 1),
        _buildLine(currentStep >= 2),
        _buildStep(2, "Processed", currentStep >= 2),
        _buildLine(currentStep >= 3),
        _buildStep(3, "Under Way", currentStep >= 3),
        _buildLine(currentStep >= 4),
        _buildStep(4, "Delivered", currentStep >= 4),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white12,
            shape: BoxShape.circle,
            boxShadow: active ? [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 6)] : [],
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: TextStyle(color: active ? Colors.white : Colors.white24, fontSize: 9)),
      ],
    );
  }

  Widget _buildLine(bool active) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.only(bottom: 12),
        color: active ? AppColors.primary : Colors.white12,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orangeAccent;
      case 'processed':
        return Colors.blueAccent;
      case 'under way':
        return Colors.purpleAccent;
      case 'delivered':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.white38;
    }
  }
}
