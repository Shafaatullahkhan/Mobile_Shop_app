import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_provider.dart';
import '../../data/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../global_widgets/glass_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF1B2339)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductsTab(),
                    _buildOrdersTab(),
                    _buildUsersTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () => _showProductDialog(context),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Text(
            "Admin Panel",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Consumer<AdminProvider>(
            builder: (context, admin, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                  onPressed: () => _showNotifications(context, admin),
                ),
                if (admin.unreadNotificationsCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        admin.unreadNotificationsCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context, AdminProvider admin) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Recent Activity",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                if (admin.notifications.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      admin.clearAllNotifications();
                      Navigator.pop(context);
                    },
                    child: const Text("Clear All", style: TextStyle(color: AppColors.primary)),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            if (admin.notifications.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No notifications", style: TextStyle(color: Colors.white38)),
              )),
            ...admin.notifications.take(5).map((n) => ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.primary)),
                  title: Text(n['message'] ?? "", style: TextStyle(color: n['read'] == true ? Colors.white38 : Colors.white, fontSize: 14)),
                  subtitle: Text(n['timestamp'] != null ? DateFormat('HH:mm').format((n['timestamp'] as Timestamp).toDate()) : "Just now", style: const TextStyle(color: Colors.white24, fontSize: 12)),
                  onTap: () {
                    admin.markNotificationRead(n['id']);
                    Navigator.pop(context);
                    _tabController.animateTo(1); // Go to Orders tab
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.primary,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: (index) => setState(() {}),
        tabs: const [
          Tab(text: "Products"),
          Tab(text: "Orders"),
          Tab(text: "Users"),
        ],
      ),
    );
  }

  // --- Products Tab ---
  Widget _buildProductsTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        if (adminProvider.products.isEmpty) {
          return const Center(child: Text("No products found", style: TextStyle(color: Colors.white38)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: adminProvider.products.length,
          itemBuilder: (context, index) {
            final product = adminProvider.products[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: GlassContainer(
                padding: const EdgeInsets.all(15),
                borderRadius: 20,
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(product.imageUrl, fit: BoxFit.contain)
                          : const Icon(Icons.phone_iphone, color: Colors.white24),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text("\$${product.price.toStringAsFixed(0)} - Stock: ${product.stock}",
                              style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                      onPressed: () => _showProductDialog(context, product: product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => _showDeleteConfirm(context, product),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Orders Tab ---
  Widget _buildOrdersTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        if (adminProvider.orders.isEmpty) {
          return const Center(child: Text("No orders yet", style: TextStyle(color: Colors.white38)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: adminProvider.orders.length,
          itemBuilder: (context, index) {
            final order = adminProvider.orders[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: GlassContainer(
                padding: const EdgeInsets.all(15),
                borderRadius: 20,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Order #${order.id.substring(0, 6).toUpperCase()}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => _showStatusPicker(context, order),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(color: _getStatusColor(order.status), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${order.items.length} items • \$${order.totalAmount.toStringAsFixed(0)}",
                            style: const TextStyle(color: Colors.white60, fontSize: 13)),
                        Text(DateFormat('MMM dd, HH:mm').format(order.timestamp),
                            style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Users Tab ---
  Widget _buildUsersTab() {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        if (adminProvider.users.isEmpty) {
          return const Center(child: Text("No users found", style: TextStyle(color: Colors.white38)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: adminProvider.users.length,
          itemBuilder: (context, index) {
            final user = adminProvider.users[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: GlassContainer(
                padding: const EdgeInsets.all(15),
                borderRadius: 15,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (user['role'] == 'admin' ? Colors.amber : AppColors.primary).withOpacity(0.1),
                      child: Icon(user['role'] == 'admin' ? Icons.admin_panel_settings : Icons.person,
                          color: user['role'] == 'admin' ? Colors.amber : AppColors.primary),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user['name'] ?? "No Name", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(user['email'] ?? "No Email", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (user['role'] == 'admin')
                      const Icon(Icons.verified, color: Colors.amber, size: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Helpers & Dialogs ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orangeAccent;
      case 'processed': return Colors.blueAccent;
      case 'under way': return Colors.purpleAccent;
      case 'delivered': return Colors.greenAccent;
      case 'cancelled': return Colors.redAccent;
      default: return Colors.white38;
    }
  }

  void _showStatusPicker(BuildContext context, dynamic order) {
    final timeController = TextEditingController(text: order.expectedDeliveryTime);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Manage Order", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Expected Delivery", style: TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: timeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "e.g. 2-3 Days or Jan 25",
                      hintStyle: const TextStyle(color: Colors.white24),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    context.read<AdminProvider>().updateOrderDeliveryTime(order.id, timeController.text);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Delivery time updated")));
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text("Order Status", style: TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ['Pending', 'Processed', 'Under Way', 'Delivered', 'Cancelled'].map((status) => GestureDetector(
                    onTap: () {
                      context.read<AdminProvider>().updateOrderStatus(order.id, status.toLowerCase());
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: order.status.toLowerCase() == status.toLowerCase() 
                            ? AppColors.primary 
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(status, style: const TextStyle(color: Colors.white)),
                    ),
                  )).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Delete Product?", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to delete ${product.name}?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                context.read<AdminProvider>().deleteProduct(product.id);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, {Product? product}) {
    final nameController = TextEditingController(text: product?.name);
    final descController = TextEditingController(text: product?.description);
    final priceController = TextEditingController(text: product?.price.toString());
    final stockController = TextEditingController(text: product?.stock.toString());
    final categoryController = TextEditingController(text: product?.category);
    final brandController = TextEditingController(text: product?.brand);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(25, 25, 25, MediaQuery.of(context).viewInsets.bottom + 25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product == null ? "Add New Product" : "Edit Product",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildDialogField("Product Name", nameController),
              _buildDialogField("Brand", brandController),
              _buildDialogField("Category (Smartphones, Tablets...)", categoryController),
              _buildDialogField("Description", descController, maxLines: 3),
              Row(
                children: [
                  Expanded(child: _buildDialogField("Price", priceController, isNumber: true)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildDialogField("Stock", stockController, isNumber: true)),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    final newProduct = Product(
                      id: product?.id ?? '',
                      name: nameController.text,
                      description: descController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      stock: int.tryParse(stockController.text) ?? 0,
                      imageUrl: product?.imageUrl ?? '',
                      category: categoryController.text.isEmpty ? 'Smartphones' : categoryController.text,
                      brand: brandController.text,
                      specifications: product?.specifications ?? {},
                    );
                    if (product == null) {
                      context.read<AdminProvider>().addProduct(newProduct);
                    } else {
                      context.read<AdminProvider>().updateProduct(newProduct);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(product == null ? "Add Product" : "Update Product",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primary)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}
