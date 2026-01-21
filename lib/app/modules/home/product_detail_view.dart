import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../cart/cart_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/app_colors.dart';
import '../../global_widgets/glass_container.dart';

class ProductDetailView extends StatefulWidget {
  final Product product;
  const ProductDetailView({super.key, required this.product});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> with SingleTickerProviderStateMixin {
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              borderRadius: 12,
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GlassContainer(
              borderRadius: 12,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.favorite_border, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF1B2339)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Hero(
                      tag: 'product_${widget.product.id}',
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: widget.product.imageUrl.isNotEmpty
                            ? Image.network(widget.product.imageUrl, fit: BoxFit.contain)
                            : const Icon(Icons.phone_iphone, size: 150, color: Colors.white12),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.2),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.product.category,
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                "\$${widget.product.price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TabBar(
                            controller: _tabController,
                            indicatorColor: AppColors.primary,
                            indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white38,
                            tabs: const [
                              Tab(text: "Product"),
                              Tab(text: "Specs"),
                              Tab(text: "Reviews"),
                            ],
                          ),
                          SizedBox(
                            height: 200,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Text(
                                    widget.product.description,
                                    style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 16),
                                  ),
                                ),
                                _buildSpecsTab(),
                                const Center(child: Text("No reviews yet", style: TextStyle(color: Colors.white70))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildFloatingFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                onPressed: () {
                  context.read<CartProvider>().addToCart(widget.product, context);
                },
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsTab() {
    if (widget.product.specifications.isEmpty) {
      return const Center(child: Text("No specifications available", style: TextStyle(color: Colors.white70)));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ListView(
        children: widget.product.specifications.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text("${entry.key}: ", style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
                Text(entry.value.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
